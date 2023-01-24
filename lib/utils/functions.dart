import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sheet.dart';

Future<dynamic> verifyTaxPayer(String rnc) async {
  var results = await connection.mappedResultsQuery(
      '''select * from public."TaxPayer" where "tax_payerId" = '$rnc';''');

  if (results.isEmpty) {
    return 'not exists';
  }
  var taxPayer = results.first['TaxPayer'] ?? {};
  if (taxPayer['tax_payerId'] == rnc) {
    return {
      'exists': true,
      'tax_payer_company_name': taxPayer['tax_payer_company_name']
    };
  }
  return {};
}

Future<Map<String, dynamic>?> calcData(
    {String? sheetId, String? bookId}) async {
  try {
    var whereContext = '';

    if (sheetId != null) {
      whereContext = '''"invoice_sheetId" = '$sheetId' ''';
    }
    if (bookId != null) {
      whereContext = '''"invoice_bookId" = '$bookId' ''';
    }

    var results = await connection.mappedResultsQuery('''
       SELECT 
       SUM(TRUNC(cast("TOTAL FACTURADO" AS numeric),2))::text  AS "TOTAL FACTURADO",
       (SELECT 
       SUM(TRUNC(cast("TOTAL FACTURADO" AS numeric),2)) 
       FROM public."PurchaseDetails" WHERE "NCF" NOT LIKE '%B02%' AND $whereContext) AS "TOTAL FACTURADO EN NCFS",
       SUM(TRUNC(cast("TOTAL ITBIS" AS numeric),2))::text AS "TOTAL ITBIS FACTURADO", 
       (SELECT 
       SUM(TRUNC(cast("TOTAL ITBIS" AS numeric),2)) 
       FROM public."PurchaseDetails" WHERE "NCF" NOT LIKE '%B02%' AND $whereContext) AS "TOTAL ITBIS FACTURADO EN NCFS",
       SUM(TRUNC(cast("TOTAL NETO" AS numeric),2))::text AS "TOTAL NETO FACTURADO" ,
       (SELECT 
       SUM(TRUNC(cast("TOTAL NETO" AS numeric),2)) 
       FROM public."PurchaseDetails" WHERE "NCF" NOT LIKE '%B02%' AND $whereContext) AS "TOTAL NETO FACTURADO EN NCFS"
       FROM public."PurchaseDetails"
       WHERE $whereContext;
    ''');
    return results.map((e) => e['']).toList().first;
  } catch (e) {
    return {};
  }
}

Future<List> fecthPurchases(String sheetId) async {
  try {
    return await Purchase.getPurchases(sheetId: sheetId);
  } catch (e) {
    rethrow;
  }
}

Future fetchDataBook({String? bookId, String? sheetId}) async {
  try {
    var data = await Future.wait([
      fetchSheets(bookId ?? ''),
      fecthPurchases(sheetId ?? ''),
      calcData(sheetId: sheetId)
    ]);
    return {'sheets': data[0], 'invoices': data[1], 'invoicesLogs': data[2]};
  } catch (e) {
    return {'sheets': [], 'invoices': [], 'invoicesLogs': {}};
  }
}

Future<List<Sheet>> fetchSheets(String bookId) async {
  try {
    return await Sheet.getSheets(bookId: bookId);
  } catch (e) {
    return [];
  }
}

Future<void> launchFile(String path) async {
  ProcessResult result = await Process.run('cmd', ['/c', 'start', '', path]);
  if (result.exitCode == 0) {
    // good
  } else {
    // bad
  }
}


showLoader(BuildContext context) async {
  showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
            insetAnimationDuration: const Duration(milliseconds: 5),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [CircularProgressIndicator()],
                ),
              ),
            ));
      });
}

Future<List<Map<String,dynamic>?>> generate606(
    {String? sheetId = '', String? filePath = ''}) async {
  await connection.query('''
   DROP TABLE IF EXISTS public."TempTable";
  ''');
  await connection.query('''
   CREATE TABLE public."TempTable"
   AS
   SELECT 
  "EMPRESA",
  "RNC",
   CASE WHEN LENGTH("RNC") < 11 THEN 1 ELSE 2 END,
  "TIPO FACT",
  "NCF",
  "NCF MODIFICADO",
  "FECHA DE COMPROBANTE",
  "FECHA DE PAGO",
  "TOTAL EN SERVICIOS",
  "TOTAL EN BIENES",
  "TOTAL FACTURADO",
  "TOTAL ITBIS",
  "ITBIS RETENIDO",
  "ITBIS SUJETO ART. 349",
  "ITBIS LLEVADO AL COSTO",
  "ITBIS POR ADELANTAR",
  "ITBIS PERCIBIDO EN COMPRAS",
  "ID DE TIPO DE RETENCION ISR",
  "MONTO RETENCION RENTA",
  "ISR PERCIBIDO EN COMPRAS",
  "IMPUESTO SELECTIVO AL CONSUMO",
  "OTROS IMPUESTOS / TASAS",
  "MONTO PROPINA LEGAL",
  "METODO DE PAGO"
   FROM public."PurchaseDetails" 
   WHERE not ("NCF" like '%B02%') 
   and "invoice_sheetId" = '$sheetId'
   ORDER BY "EMPRESA","NCF"
   ''');
  await connection.query('''
  ALTER TABLE public."TempTable" DROP COLUMN "EMPRESA";
  ''');

  var result = await  connection.mappedResultsQuery('''SELECT * FROM public."TempTable";''');

  return result.map((e) => e['TempTable']).toList();
}
