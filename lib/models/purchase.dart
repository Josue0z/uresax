import 'package:uresaxapp/apis/connection.dart';
import 'package:uuid/uuid.dart';

class Purchase {
  String? id;
  String? invoiceRnc;
  int? invoiceTypeId;
  int? invoiceBankingId;
  int? invoicePaymentMethodId;
  int? invoiceConceptId;
  String? invoiceNcf;
  String? invoiceNcfModifed;
  double? invoiceItbis18;
  double? invoiceItbis16;
  double? invoiceTotalServ;
  double? invoiceTotalBin;
  String? invoiceCk;
  String? invoiceNcfDate;
  String? invoiceNcfDay;
  String? invoiceSheetId;
  String? invoiceBookId;
  String? invoiceCompanyId;

  Purchase(
      {this.id,
      this.invoiceRnc,
      this.invoiceConceptId,
      this.invoiceTypeId,
      this.invoicePaymentMethodId,
      this.invoiceNcf,
      this.invoiceNcfDate,
      this.invoiceNcfDay,
      this.invoiceSheetId,
      this.invoiceBookId,
      this.invoiceCompanyId,
      this.invoiceItbis18,
      this.invoiceItbis16,
      this.invoiceTotalServ,
      this.invoiceTotalBin,
      this.invoiceNcfModifed,
      this.invoiceBankingId,
      this.invoiceCk});

  Map<String, dynamic> toMap() {
    return {
      'invoice_rnc': invoiceRnc,
      'invoice_conceptId': invoiceConceptId,
      'invoice_typeId': invoiceTypeId,
      'invoice_bankingId': invoiceBankingId,
      'invoice_payment_methodId': invoicePaymentMethodId,
      'invoice_ncf': invoiceNcf,
      'invoice_ncf_modifed': invoiceNcfModifed,
      'invoice_itbis_16': invoiceItbis16 ?? 0.00,
      'invoice_itbis_18': invoiceItbis18 ?? 0.00,
      'invoice_total_serv': invoiceTotalServ ?? 0.00,
      'invoice_total_bin': invoiceTotalBin ?? 0.00,
      'invoice_ck': invoiceCk,
      'invoice_ncf_date': invoiceNcfDate,
      'invoice_ncf_day': invoiceNcfDay,
      'invoice_sheetId': invoiceSheetId,
      'invoice_bookId': invoiceBookId,
      'invoice_companyId': invoiceCompanyId
    };
  }

  Future<void> checkIfExistsPurchase() async {
    try {
      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM "Purchase" WHERE "invoice_sheetId" = '$invoiceSheetId' and "invoice_rnc" = '$invoiceRnc' and "invoice_ncf" = '$invoiceNcf';''');
      if (result.isNotEmpty) {
         throw 'YA EXISTE ESTA COMPRA EN ESTA HOJA';
      }
    } catch (e) {
      rethrow;
    }
  
  }

  Future<void> create() async {
    try {
      
      await checkIfExistsPurchase();
      var id = const Uuid().v4();
      invoiceNcfModifed ??= '';
      await connection.query(
          ''' INSERT INTO public."Purchase" ("id","invoice_rnc","invoice_conceptId","invoice_sheetId","invoice_bookId","invoice_companyId","invoice_ncf","invoice_ncf_modifed","invoice_typeId","invoice_ck","invoice_bankingId","invoice_payment_methodId","invoice_ncf_date","invoice_ncf_day","invoice_itbis_18","invoice_itbis_16","invoice_total_serv","invoice_total_bin") VALUES('$id','$invoiceRnc',$invoiceConceptId,'$invoiceSheetId','$invoiceBookId','$invoiceCompanyId','$invoiceNcf', '$invoiceNcfModifed', $invoiceTypeId, $invoiceCk, $invoiceBankingId, $invoicePaymentMethodId,'$invoiceNcfDate','$invoiceNcfDay', $invoiceItbis18, $invoiceItbis16, $invoiceTotalServ, $invoiceTotalBin) ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> update() async {
    try {
      await connection.query('''
      UPDATE public."Purchase" SET "invoice_rnc" = '$invoiceRnc', "invoice_conceptId" = $invoiceConceptId, "invoice_ncf" = '$invoiceNcf', "invoice_ncf_modifed" = '$invoiceNcfModifed', "invoice_typeId" = $invoiceTypeId, "invoice_ck" = $invoiceCk, "invoice_bankingId" = $invoiceBankingId, "invoice_payment_methodId" = $invoicePaymentMethodId, "invoice_ncf_day" = '$invoiceNcfDay', "invoice_itbis_16" = $invoiceItbis16, "invoice_itbis_18" = $invoiceItbis18, "invoice_total_serv" = $invoiceTotalServ, "invoice_total_bin" = $invoiceTotalBin WHERE "id" = '$id';
      ''');
      var result = await connection.mappedResultsQuery('''
          SELECT
          "id",
          "RNC",
          "EMPRESA",
          "ID DE CONCEPTO",
          "CONCEPTO",
          "CK" AS "NUMERO DE CHEQUE",
          "ID DE BANCO",
          "BANCO",
          "TIPO",
          "NCF",
          "NOMBRE DE NCF",
          "NCF MODIFICADO",
          "NOMBRE DE NCF MODIFICADO",
          "FECHA" AS "ANO/MES",
          "DIA",
          "TOTAL EN SERVICIOS",
          "TOTAL EN BIENES",
          "TOTAL FACTURADO",
          "TOTAL NETO",
          "ITBIS 18%",
          "ITBIS 16%",
          "TOTAL ITBIS",
          "FORMA DE PAGO",
          "GRAVADA 18%",
          "GRAVADA 16%",
          "TOTAL GRAVADA",
          "EXENTO" 
           FROM public."PurchaseDetails" WHERE "id" = '$id';''');
      return result.first['']!;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete() async {
    try {
      await connection
          .query('''DELETE FROM public."Purchase" WHERE "id" = '$id';''');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>?>> getPurchases(
      {String? sheetId = ''}) async {
    try {
      var results = await connection.mappedResultsQuery('''
          SELECT
          "id",
          "RNC",
          "EMPRESA",
          "ID DE CONCEPTO",
          "CONCEPTO",
          "CK" AS "NUMERO DE CHEQUE",
          "ID DE BANCO",
          "BANCO",
          "TIPO",
          "NCF",
          "NOMBRE DE NCF",
          "NCF MODIFICADO",
          "NOMBRE DE NCF MODIFICADO",
          "FECHA" AS "ANO/MES",
          "DIA",
          "TOTAL EN SERVICIOS",
          "TOTAL EN BIENES",
          "TOTAL FACTURADO",
          "TOTAL NETO",
          "ITBIS 18%",
          "ITBIS 16%",
          "TOTAL ITBIS",
          "FORMA DE PAGO",
          "GRAVADA 18%",
          "GRAVADA 16%",
          "TOTAL GRAVADA",
          "EXENTO"
           FROM
           public."PurchaseDetails" where "invoice_sheetId" = '$sheetId' order by "EMPRESA","NCF";
          ''');
      return results.map((row) => row['']).toList();
    } catch (e) {
      rethrow;
    }
  }
}
