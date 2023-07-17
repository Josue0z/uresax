import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uuid/uuid.dart';
import 'package:uresaxapp/apis/connection.dart';

class Sale {
  String id;
  String companyId;
  String authorId;
  String? authorName;
  String? providerName;
  String? conceptName;
  String rncOrId;
  int idType;
  int conceptId;
  String invoiceNcf;
  int invoiceNcfTypeId;
  int? invoiceNcfModifedTypeId;
  String? invoiceNcfModifed;
  String typeOfIncome;
  DateTime invoiceNcfDate;
  DateTime? retentionDate;
  double total;
  double tax;
  double taxRetentionOthers;
  double perceivedTax;
  double retentionOthers;
  double perceivedISR;
  double selectiveConsumptionTax;
  double otherTaxesFees;
  double legalTipAmount;
  double effective;
  double checkTransferDeposit;
  double debitCreditCard;
  double saleOnCredit;
  double vouchersOrGiftCertificates;
  double swap;
  double otherFormsOfSales;
  double? netTotal;
  String? typeOfIncomeName;

  Sale(
      {required this.id,
      required this.companyId,
      required this.authorId,
      this.authorName,
      required this.rncOrId,
      required this.idType,
      required this.conceptId,
      required this.invoiceNcf,
      required this.invoiceNcfTypeId,
      this.invoiceNcfModifedTypeId,
      required this.invoiceNcfModifed,
      required this.typeOfIncome,
      required this.invoiceNcfDate,
      this.retentionDate,
      required this.total,
      required this.tax,
      required this.taxRetentionOthers,
      required this.perceivedTax,
      required this.retentionOthers,
      required this.perceivedISR,
      required this.selectiveConsumptionTax,
      required this.otherTaxesFees,
      required this.legalTipAmount,
      required this.effective,
      required this.checkTransferDeposit,
      required this.debitCreditCard,
      required this.saleOnCredit,
      required this.vouchersOrGiftCertificates,
      required this.swap,
      required this.otherFormsOfSales,
      this.netTotal,
      this.typeOfIncomeName,
      this.providerName,
      this.conceptName});

  Future create() async {
    try {
      var ncfM =
          invoiceNcfModifed != null ? ''' '$invoiceNcfModifed' ''' : null;

      var rdate = retentionDate != null
          ? ''' '${retentionDate?.format(payload: 'YYYY-MM-DD')}' '''
          : null;

      id = const Uuid().v1();

      await connection.execute('''
         INSERT INTO public."Sale"(
         id,
        "rncOrId",
        "idType",
        "conceptId",
        "invoiceNcfTypeId",
        "invoiceNcf",
        "invoiceNcfModifedTypeId",
        "invoiceNcfModifed",
        "typeOfIncome",
        "invoiceNcfDate",
        "retentionDate", 
         total,
         tax,
         "taxRetentionOthers",
         "perceivedTax",
         "retentionOthers",
         "perceivedISR", 
         "selectiveConsumptionTax", 
         "otherTaxesFees", 
         "legalTipAmount", 
         effective, 
         "checkTransferDeposit", 
         "debitCreditCard", 
         "saleOnCredit", 
         "vouchersOrGiftCertificates", 
         swap, 
         "otherFormsOfSales", 
         "companyId", 
         "authorId")
          VALUES ('$id','$rncOrId', $idType, $conceptId, $invoiceNcfTypeId, '$invoiceNcf', $invoiceNcfModifedTypeId, $ncfM, '$typeOfIncome', '${invoiceNcfDate.format(payload: 'YYYY-MM-DD')}', $rdate, $total, $tax, $taxRetentionOthers, $perceivedTax, $retentionOthers, $perceivedISR, $selectiveConsumptionTax, $otherTaxesFees, $legalTipAmount, $effective, $checkTransferDeposit, $debitCreditCard, $saleOnCredit, $vouchersOrGiftCertificates, $swap, $otherFormsOfSales,'$companyId', '$authorId');
      ''');
    } catch (e) {
      rethrow;
    }
  }

  Future update() async {
    try {
      var ncfM =
          invoiceNcfModifed != null ? ''' '$invoiceNcfModifed' ''' : null;

      var rdate = retentionDate != null
          ? ''' '${retentionDate?.format(payload: 'YYYY-MM-DD')}' '''
          : null;
      await connection.execute('''
        UPDATE public."Sale"
        SET  
        "rncOrId"= '$rncOrId', 
        "idType"=$idType, 
        "invoiceNcf"='$invoiceNcf', 
        "invoiceNcfModifed"=$ncfM,
        "typeOfIncome"='$typeOfIncome', 
        "invoiceNcfDate"='${invoiceNcfDate.format(payload: 'YYYY-MM-DD')}', 
        "retentionDate"=$rdate,
         total=$total,
         tax=$tax, 
        "taxRetentionOthers"=$taxRetentionOthers,
        "perceivedTax"=$perceivedTax, 
        "retentionOthers"=$retentionOthers, 
        "perceivedISR"=$perceivedISR, 
        "selectiveConsumptionTax"=$selectiveConsumptionTax, 
        "otherTaxesFees"=$otherTaxesFees, 
        "legalTipAmount"=$legalTipAmount,
        effective=$effective, 
        "checkTransferDeposit"=$checkTransferDeposit, 
        "debitCreditCard"=$debitCreditCard, 
        "saleOnCredit"=$saleOnCredit, 
        "vouchersOrGiftCertificates"=$vouchersOrGiftCertificates, 
        swap=$swap,
        "otherFormsOfSales"=$otherFormsOfSales,  
        "authorId"='$authorId', 
        "conceptId"=$conceptId, 
        "invoiceNcfTypeId"=$invoiceNcfTypeId, 
        "invoiceNcfModifedTypeId"=$invoiceNcfModifedTypeId
         WHERE "id" = '$id'
     ''');
    } catch (e) {
      rethrow;
    }
  }

  Future delete() async {
    try {
      await connection
          .execute(''' delete from public."Sale" where "id" = '$id' ''');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Sale>> get(
      {String companyId = '',
      String searchWord = '',
      bool searchMode = false,
      required DateTime startDate,
      required DateTime endDate}) async {
    try {
      var searchContext = '';

      if (searchMode) {
        searchContext =
            ''' (lower("authorName") like lower('%$searchWord%') or "conceptName" like '%$searchWord%' or "total"::text like '%$searchWord' or "tax"::text like '%$searchWord' or "providerName" like '%$searchWord%' or "invoiceNcf" like '%$searchWord%' or "rncOrId" like '%$searchWord%' or "invoiceNcfModifed" like '%$searchWord%') and''';
      }

      var c = await connection.mappedResultsQuery(
          ''' select * from public."SalesView" where $searchContext "companyId" = '$companyId' and "invoiceNcfDate" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' order by "invoiceNcfDate", "providerName" ''');
      return c.map((e) => Sale.fromMap(e['']!)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getListPeriods(
      {String id = '', String search = ''}) async {
    try {
      var searchContext = '';
      if (search != '') {
        searchContext =
            ''' and to_char("invoiceNcfDate",'yyyymm') like '%$search%' ''';
      }
      var result = await connection.mappedResultsQuery('''
            SELECT to_char("invoiceNcfDate",'yyyy-mm')
            AS date_label
            FROM public."Sale" 
            WHERE "companyId" = '$id' $searchContext
            GROUP BY to_char("invoiceNcfDate",'yyyy-mm')
            ORDER BY to_char("invoiceNcfDate",'yyyy-mm') DESC
        ''');

      return result.map((e) => e['']!).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getReportViewByTypeIncome(
      {String targetPath = '',
      String reportName = 'REPORTE FISCAL',
      required Company company,
      required DateTime startDate,
      required DateTime endDate,
      QueryContext queryContext = QueryContext.tax}) async {
    try {
      String id = company.id!;

      String queryContextI = 'and';

      if (queryContext == QueryContext.consumption) {
        queryContextI =
            'and ("invoiceNcfTypeId" = 2 or "invoiceNcfTypeId" = 32) and';
      } else if (queryContext == QueryContext.tax) {
        queryContextI =
            'and "invoiceNcfTypeId" != 2 and "invoiceNcfTypeId" != 32 and';
      }

      var where =
          ''' "companyId" = '$id' $queryContextI "invoiceNcfDate" between '${startDate.format(payload: 'YYYY-MM-DD')}' and  '${endDate.format(payload: 'YYYY-MM-DD')}' ''';

      var result = await connection.runTx((c) async {
        await c.query('''SET lc_monetary = 'es_US';''');
        var result = await c.mappedResultsQuery('''
          SELECT 
          "typeOfIncomeName" AS "TIPO DE INGRESO",
          sum("totalGeneral")::money::text AS "TOTAL FACTURADO",
          sum(tax)::money::text AS "TOTAL ITBIS", 
          sum(total)::money::text AS "TOTAL NETO",
          sum("taxRetentionOthers")::money::text AS "ITBIS RETENIDO POR TERCEROS",
          sum("perceivedTax")::money::text AS "ITBIS PERCIBIDO",
          sum("retentionOthers")::money::text AS "RETENCION RENTA POR TERCEROS",
          sum("perceivedISR")::money::text AS "ISR PERCIBIDO",
          sum("selectiveConsumptionTax")::money::text AS "IMPUESTO SELECTIVO AL CONSUMO",
          sum("otherTaxesFees")::money::text AS "OTROS IMPUESTOS O TASAS",
          sum("legalTipAmount")::money::text AS "MONTO PROPINA LEGAL",
          sum("effective")::money::text AS "EFECTIVO",
          sum("checkTransferDeposit")::money::text AS "CHEQUE TRANS O DEPOSITO",
          sum("debitCreditCard")::money::text AS "TARJETA DE DEBITO / CREDITO",
          sum("saleOnCredit")::money::text AS "VENTA A CREDITO",
          sum("vouchersOrGiftCertificates")::money::text AS "BONOS O CERTIFICADOS DE REGALO",
          sum("swap")::money::text AS "PERMUTA",
          sum("otherFormsOfSales")::money::text AS "OTRAS FORMA DE VENTAS"
          FROM public."SalesView"
          WHERE $where
          GROUP BY "typeOfIncomeName" 
          UNION ALL
          SELECT
          'TOTAL GENERAL', 
          sum("totalGeneral")::money::text, 
          sum(tax)::money::text, 
          sum(total)::money::text, 
          sum("taxRetentionOthers")::money::text,
          sum("perceivedTax")::money::text, 
          sum("retentionOthers")::money::text,
          sum("perceivedISR") ::money::text,
          sum("selectiveConsumptionTax")::money::text,
          sum("otherTaxesFees")::money::text,
          sum("legalTipAmount")::money::text,
          sum("effective")::money::text,
          sum("checkTransferDeposit")::money::text,
          sum("debitCreditCard")::money::text,
          sum("saleOnCredit")::money::text,
          sum("vouchersOrGiftCertificates")::money::text,
          sum("swap")::money::text,
          sum("otherFormsOfSales")::money::text
          FROM public."SalesView"
          WHERE $where
        ''');

        return result;
      });

      var r1 = result;

      var data = r1.map((e) => e['']!).toList();


      late Excel excel;

      var file = File(targetPath);

      if (!file.existsSync()) {
        excel = Excel.createExcel();
      } else {
        excel = Excel.decodeBytes(await file.readAsBytes());
      }

      var sheetName =
          '$reportName-${startDate.format(payload: 'YYYYMMDD')}-${endDate.format(payload: 'YYYYMMDD')}';

      excel.delete('Sheet1');

      var sheet = excel[sheetName];

      var list = data;

      var item = list[0];

      var keys = item.keys.toList();

      int endHeaderRowIndex = 3;

      var c =
          sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: 0));

      c.value = sheetName;

      for (int i = 0; i < keys.length; i++) {
        var c = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: i, rowIndex: endHeaderRowIndex));
        c.value = keys[i];
      }

      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var values = item.values.toList();
        for (int j = 0; j < values.length; j++) {
          var val = values[j];
          var c = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: j, rowIndex: (endHeaderRowIndex + 1) + i));
          c.value = val;
        }
      }


      return {
        'data': data,
        'excelBytes': excel.save(),
        'targetPath': targetPath
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getReportViewByConcept(
      {String companyId = '',
      required DateTime startDate,
      required DateTime endDate,
      String reportName = 'REPORTE FISCAL',
      String targetPath = '',
      QueryContext queryContext = QueryContext.tax}) async {
    try {
      String queryContextI = 'and';

      if (queryContext == QueryContext.consumption) {
        queryContextI =
            'and ("invoiceNcfTypeId" = 2 or "invoiceNcfTypeId" = 32) and';
      } else if (queryContext == QueryContext.tax) {
        queryContextI =
            'and "invoiceNcfTypeId" != 2 and "invoiceNcfTypeId" != 32 and';
      }

      var where =
          ''' "companyId" = '$companyId' $queryContextI "invoiceNcfDate" between '${startDate.format(payload: 'YYYY-MM-DD')}' and  '${endDate.format(payload: 'YYYY-MM-DD')}' ''';

      var result = await connection.runTx((c) async {
        await c.query('''SET lc_monetary = 'es_US';''');
        var result = await c.mappedResultsQuery('''
          SELECT 
          "conceptName" AS "CONCEPTO",
          sum("totalGeneral")::money::text AS "TOTAL FACTURADO",
          sum(tax)::money::text AS "TOTAL ITBIS", 
          sum(total)::money::text AS "TOTAL NETO",
          sum("taxRetentionOthers")::money::text AS "ITBIS RETENIDO POR TERCEROS",
          sum("perceivedTax")::money::text AS "ITBIS PERCIBIDO",
          sum("retentionOthers")::money::text AS "RETENCION RENTA POR TERCEROS",
          sum("perceivedISR")::money::text AS "ISR PERCIBIDO",
          sum("selectiveConsumptionTax")::money::text AS "IMPUESTO SELECTIVO AL CONSUMO",
          sum("otherTaxesFees")::money::text AS "OTROS IMPUESTOS O TASAS",
          sum("legalTipAmount")::money::text AS "MONTO PROPINA LEGAL",
          sum("effective")::money::text AS "EFECTIVO",
          sum("checkTransferDeposit")::money::text AS "CHEQUE TRANS O DEPOSITO",
          sum("debitCreditCard")::money::text AS "TARJETA DE DEBITO / CREDITO",
          sum("saleOnCredit")::money::text AS "VENTA A CREDITO",
          sum("vouchersOrGiftCertificates")::money::text AS "BONOS O CERTIFICADOS DE REGALO",
          sum("swap")::money::text AS "PERMUTA",
          sum("otherFormsOfSales")::money::text AS "OTRAS FORMA DE VENTAS"
          FROM public."SalesView"
          WHERE $where
          GROUP BY "conceptName" 
          UNION ALL
          SELECT
          'TOTAL GENERAL', 
          sum("totalGeneral")::money::text, 
          sum(tax)::money::text, 
          sum(total)::money::text, 
          sum("taxRetentionOthers")::money::text,
          sum("perceivedTax")::money::text, 
          sum("retentionOthers")::money::text,
          sum("perceivedISR") ::money::text,
          sum("selectiveConsumptionTax")::money::text,
          sum("otherTaxesFees")::money::text,
          sum("legalTipAmount")::money::text,
          sum("effective")::money::text,
          sum("checkTransferDeposit")::money::text,
          sum("debitCreditCard")::money::text,
          sum("saleOnCredit")::money::text,
          sum("vouchersOrGiftCertificates")::money::text,
          sum("swap")::money::text,
          sum("otherFormsOfSales")::money::text
          FROM public."SalesView"
          WHERE $where
        ''');
        return result;
      });

      late Excel excel;

      var file = File(targetPath);

      if (!file.existsSync()) {
        excel = Excel.createExcel();
      } else {
        excel = Excel.decodeBytes(await file.readAsBytes());
      }

      var sheetName =
          '$reportName-${startDate.format(payload: 'YYYYMMDD')}-${endDate.format(payload: 'YYYYMMDD')}';

      excel.delete('Sheet1');

      var sheet = excel[sheetName];

      var list = result.map((e) => e['']).toList();

      var item = list[0];

      var keys = item?.keys.toList();

      int endHeaderRowIndex = 3;

      var c =
          sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: 0));

      c.value = sheetName;

      for (int i = 0; i < keys!.length; i++) {
        var c = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: i, rowIndex: endHeaderRowIndex));
        c.value = keys[i];
      }

      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var values = item?.values.toList();
        for (int j = 0; j < values!.length; j++) {
          var val = values[j];
          var c = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: j, rowIndex: (endHeaderRowIndex + 1) + i));
          c.value = val;
        }
      }
      return {
        'data': result.map((e) => e['']!).toList(),
        'excelBytes': excel.save(),
        'pdfBytes': [],
        'targetPath': targetPath
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getReportViewByProvider(
      {String companyId = '',
      required DateTime startDate,
      required DateTime endDate,
      String reportName = 'REPORTE FISCAL',
      String targetPath = '',
      QueryContext queryContext = QueryContext.tax}) async {
    try {
      String queryContextI = 'and';

      if (queryContext == QueryContext.consumption) {
        queryContextI =
            'and ("invoiceNcfTypeId" = 2 or "invoiceNcfTypeId" = 32) and';
      } else if (queryContext == QueryContext.tax) {
        queryContextI =
            'and "invoiceNcfTypeId" != 2 and "invoiceNcfTypeId" != 32 and';
      }

      var where =
          ''' "companyId" = '$companyId' $queryContextI "invoiceNcfDate" between '${startDate.format(payload: 'YYYY-MM-DD')}' and  '${endDate.format(payload: 'YYYY-MM-DD')}' ''';

      var result = await connection.runTx((c) async {
        await c.query('''SET lc_monetary = 'es_US';''');
        var result = await c.mappedResultsQuery('''
          SELECT 
          "providerName" AS "CONCEPTO",
          sum("totalGeneral")::money::text AS "TOTAL FACTURADO",
          sum(tax)::money::text AS "TOTAL ITBIS", 
          sum(total)::money::text AS "TOTAL NETO",
          sum("taxRetentionOthers")::money::text AS "ITBIS RETENIDO POR TERCEROS",
          sum("perceivedTax")::money::text AS "ITBIS PERCIBIDO",
          sum("retentionOthers")::money::text AS "RETENCION RENTA POR TERCEROS",
          sum("perceivedISR")::money::text AS "ISR PERCIBIDO",
          sum("selectiveConsumptionTax")::money::text AS "IMPUESTO SELECTIVO AL CONSUMO",
          sum("otherTaxesFees")::money::text AS "OTROS IMPUESTOS O TASAS",
          sum("legalTipAmount")::money::text AS "MONTO PROPINA LEGAL",
          sum("effective")::money::text AS "EFECTIVO",
          sum("checkTransferDeposit")::money::text AS "CHEQUE TRANS O DEPOSITO",
          sum("debitCreditCard")::money::text AS "TARJETA DE DEBITO / CREDITO",
          sum("saleOnCredit")::money::text AS "VENTA A CREDITO",
          sum("vouchersOrGiftCertificates")::money::text AS "BONOS O CERTIFICADOS DE REGALO",
          sum("swap")::money::text AS "PERMUTA",
          sum("otherFormsOfSales")::money::text AS "OTRAS FORMA DE VENTAS"
          FROM public."SalesView"
          WHERE $where
          GROUP BY "providerName" 
          UNION ALL
          SELECT
          'TOTAL GENERAL', 
          sum("totalGeneral")::money::text, 
          sum(tax)::money::text, 
          sum(total)::money::text, 
          sum("taxRetentionOthers")::money::text,
          sum("perceivedTax")::money::text, 
          sum("retentionOthers")::money::text,
          sum("perceivedISR") ::money::text,
          sum("selectiveConsumptionTax")::money::text,
          sum("otherTaxesFees")::money::text,
          sum("legalTipAmount")::money::text,
          sum("effective")::money::text,
          sum("checkTransferDeposit")::money::text,
          sum("debitCreditCard")::money::text,
          sum("saleOnCredit")::money::text,
          sum("vouchersOrGiftCertificates")::money::text,
          sum("swap")::money::text,
          sum("otherFormsOfSales")::money::text
          FROM public."SalesView"
          WHERE $where
        ''');
        return result;
      });

      late Excel excel;

      var file = File(targetPath);

      if (!file.existsSync()) {
        excel = Excel.createExcel();
      } else {
        excel = Excel.decodeBytes(await file.readAsBytes());
      }

      var sheetName =
          '$reportName - ${startDate.format(payload: 'YYYYMMDD')} - ${endDate.format(payload: 'YYYYMMDD')}';

      excel.delete('Sheet1');

      var sheet = excel[sheetName];

      var list = result.map((e) => e['']).toList();

      var item = list[0];

      var keys = item?.keys.toList();

      int endHeaderRowIndex = 3;

      var c =
          sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: 0));

      c.value = sheetName;

      for (int i = 0; i < keys!.length; i++) {
        var c = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: i, rowIndex: endHeaderRowIndex));
        c.value = keys[i];
      }

      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var values = item?.values.toList();
        for (int j = 0; j < values!.length; j++) {
          var val = values[j];
          var c = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: j, rowIndex: (endHeaderRowIndex + 1) + i));
          c.value = val;
        }
      }
      return {
        'data': result.map((e) => e['']!).toList(),
        'excelBytes': excel.save(),
        'pdfBytes': [],
        'targetPath': targetPath
      };
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> to607() {
    return {
      'RNC/CEDULA/PASAPORTE': rncOrId,
      'TIPO DE IDENTIFICACION': idType.toString(),
      'NCF': invoiceNcf,
      'NCF MODIFICADO': invoiceNcfModifed ?? '',
      'TIPO DE INGRESO': typeOfIncome,
      'FECHA DE COMPROBANTE': invoiceNcfDate.format(payload: 'YYYYMMDD'),
      'FECHA DE RETENCION': retentionDate?.format(payload: 'YYYYMMDD') ?? '',
      'MONTO FACTURADO': total.toStringAsFixed(2),
      'ITBIS FACTURADO': tax.toStringAsFixed(2),
      'ITBIS RETENIDO POR TERCEROS': taxRetentionOthers == 0 ? '': taxRetentionOthers.toStringAsFixed(2),
      'ITBIS PERCIBIDO': perceivedTax == 0 ? '': perceivedTax.toStringAsFixed(2),
      'RETENCION RENTA POR TERCEROS': retentionOthers == 0 ? '': retentionOthers.toStringAsFixed(2),
      'ISR PERCIBIDO':perceivedISR == 0 ? '' :perceivedISR.toStringAsFixed(2),
      'IMPUESTO SELECTIVO AL CONSUMO':
        selectiveConsumptionTax == 0 ? '': selectiveConsumptionTax.toStringAsFixed(2),
      'OTROS IMPUESTOS O TASAS':otherTaxesFees == 0 ? '': otherTaxesFees.toStringAsFixed(2),
      'MONTO PROPINA LEGAL':legalTipAmount== 0? '': legalTipAmount.toStringAsFixed(2),
      'EFECTIVO': effective == 0 ? '': effective.toStringAsFixed(2),
      'CHEQUE TRANS O DEPOSITO':checkTransferDeposit == 0 ? '': checkTransferDeposit.toStringAsFixed(2),
      'TARJETA DE DEBITO / CREDITO':debitCreditCard == 0 ? '': debitCreditCard.toStringAsFixed(2),
      'VENTA A CREDITO': saleOnCredit == 0 ? '': saleOnCredit.toStringAsFixed(2),
      'BONOS O CERTIFICADOS DE REGALO':
         vouchersOrGiftCertificates == 0 ? '': vouchersOrGiftCertificates.toStringAsFixed(2),
      'PERMUTA':swap == 0 ? '': swap.toStringAsFixed(2),
      'OTRAS FORMA DE VENTAS': otherFormsOfSales == 0 ? '': otherFormsOfSales.toStringAsFixed(2)
    };
  }

  Map<String, dynamic> toDisplay() {
    return {
      'EDITOR': authorName?.toUpperCase() ?? 'S/N',
      'RNC/CEDULA': rncOrId,
      'CLIENTE': providerName,
      'CONCEPTO': conceptName,
      'NCF': invoiceNcf,
      'NCF MODIFICADO': invoiceNcfModifed ?? 'S/N',
      'TIPO DE INGRESO': typeOfIncomeName,
      'FECHA DE COMPROBANTE': invoiceNcfDate.format(payload: 'DD/MM/YYYY'),
      'FECHA DE RETENCION':
          retentionDate?.format(payload: 'DD/MM/YYYY') ?? 'S/N',
      'MONTO FACTURADO': total.toStringAsFixed(2),
      'ITBIS FACTURADO': tax.toStringAsFixed(2),
      'ITBIS RETENIDO': taxRetentionOthers.toStringAsFixed(2),
      'ITBIS PERCIBIDO': perceivedTax.toStringAsFixed(2),
      'RETENCION RENTA': retentionOthers.toStringAsFixed(2),
      'ISR PERCIBIDO': perceivedISR.toStringAsFixed(2),
      'IMPUESTO SELECTIVO AL CONSUMO':
          selectiveConsumptionTax.toStringAsFixed(2),
      'OTROS IMPUESTOS O TASAS': otherTaxesFees.toStringAsFixed(2),
      'MONTO PROPINA LEGAL': legalTipAmount.toStringAsFixed(2),
      'EFECTIVO': effective.toStringAsFixed(2),
      'CHEQUE TRANS O DEPOSITO': checkTransferDeposit.toStringAsFixed(2),
      'TARJETA DE DEBITO / CREDITO': debitCreditCard.toStringAsFixed(2),
      'VENTA A CREDITO': saleOnCredit.toStringAsFixed(2),
      'BONOS O CERTIFICADOS DE REGALO':
          vouchersOrGiftCertificates.toStringAsFixed(2),
      'PERMUTA': swap.toStringAsFixed(2),
      'OTRAS FORMA DE VENTAS': otherFormsOfSales.toStringAsFixed(2)
    };
  }

  Sale copyWith({
    String? id,
    String? companyId,
    String? authorId,
    String? authorName,
    String? rncOrId,
    int? idType,
    int? conceptId,
    String? invoiceNcf,
    int? invoiceNcfTypeId,
    int? invoiceNcfModifedTypeId,
    String? invoiceNcfModifed,
    String? typeOfIncome,
    DateTime? invoiceNcfDate,
    DateTime? retentionDate,
    double? total,
    double? tax,
    double? taxRetentionOthers,
    double? perceivedTax,
    double? retentionOthers,
    double? perceivedISR,
    double? selectiveConsumptionTax,
    double? otherTaxesFees,
    double? legalTipAmount,
    double? effective,
    double? checkTransferDeposit,
    double? debitCreditCard,
    double? saleOnCredit,
    double? vouchersOrGiftCertificates,
    double? swap,
    double? otherFormsOfSales,
    String? typeOfIncomeName,
  }) {
    return Sale(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      rncOrId: rncOrId ?? this.rncOrId,
      idType: idType ?? this.idType,
      conceptId: conceptId ?? this.conceptId,
      invoiceNcf: invoiceNcf ?? this.invoiceNcf,
      invoiceNcfTypeId: invoiceNcfTypeId ?? this.invoiceNcfTypeId,
      invoiceNcfModifedTypeId:
          invoiceNcfModifedTypeId ?? this.invoiceNcfModifedTypeId,
      invoiceNcfModifed: invoiceNcfModifed ?? this.invoiceNcfModifed,
      typeOfIncome: typeOfIncome ?? this.typeOfIncome,
      invoiceNcfDate: invoiceNcfDate ?? this.invoiceNcfDate,
      retentionDate: retentionDate ?? this.retentionDate,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      taxRetentionOthers: taxRetentionOthers ?? this.taxRetentionOthers,
      perceivedTax: perceivedTax ?? this.perceivedTax,
      retentionOthers: retentionOthers ?? this.retentionOthers,
      perceivedISR: perceivedISR ?? this.perceivedISR,
      selectiveConsumptionTax:
          selectiveConsumptionTax ?? this.selectiveConsumptionTax,
      otherTaxesFees: otherTaxesFees ?? this.otherTaxesFees,
      legalTipAmount: legalTipAmount ?? this.legalTipAmount,
      effective: effective ?? this.effective,
      checkTransferDeposit: checkTransferDeposit ?? this.checkTransferDeposit,
      debitCreditCard: debitCreditCard ?? this.debitCreditCard,
      saleOnCredit: saleOnCredit ?? this.saleOnCredit,
      vouchersOrGiftCertificates:
          vouchersOrGiftCertificates ?? this.vouchersOrGiftCertificates,
      swap: swap ?? this.swap,
      otherFormsOfSales: otherFormsOfSales ?? this.otherFormsOfSales,
      typeOfIncomeName: typeOfIncomeName ?? this.typeOfIncomeName,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'companyId': companyId});
    result.addAll({'authorId': authorId});
    if (authorName != null) {
      result.addAll({'authorName': authorName});
    }
    result.addAll({'rncOrId': rncOrId});
    result.addAll({'idType': idType});
    result.addAll({'conceptId': conceptId});
    result.addAll({'invoiceNcf': invoiceNcf});
    result.addAll({'invoiceNcfTypeId': invoiceNcfTypeId});
    if (invoiceNcfModifedTypeId != null) {
      result.addAll({'invoiceNcfModifedTypeId': invoiceNcfModifedTypeId});
    }
    if (invoiceNcfModifed != null) {
      result.addAll({'invoiceNcfModifed': invoiceNcfModifed});
    }
    result.addAll({'typeOfIncome': typeOfIncome});
    result.addAll({'invoiceNcfDate': invoiceNcfDate.millisecondsSinceEpoch});
    if (retentionDate != null) {
      result.addAll({'retentionDate': retentionDate!.millisecondsSinceEpoch});
    }
    result.addAll({'total': total});
    result.addAll({'tax': tax});
    result.addAll({'taxRetentionOthers': taxRetentionOthers});
    result.addAll({'perceivedTax': perceivedTax});
    result.addAll({'retentionOthers': retentionOthers});
    result.addAll({'perceivedISR': perceivedISR});
    result.addAll({'selectiveConsumptionTax': selectiveConsumptionTax});
    result.addAll({'otherTaxesFees': otherTaxesFees});
    result.addAll({'legalTipAmount': legalTipAmount});
    result.addAll({'effective': effective});
    result.addAll({'checkTransferDeposit': checkTransferDeposit});
    result.addAll({'debitCreditCard': debitCreditCard});
    result.addAll({'saleOnCredit': saleOnCredit});
    result.addAll({'vouchersOrGiftCertificates': vouchersOrGiftCertificates});
    result.addAll({'swap': swap});
    result.addAll({'otherFormsOfSales': otherFormsOfSales});
    if (typeOfIncomeName != null) {
      result.addAll({'typeOfIncomeName': typeOfIncomeName});
    }

    return result;
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? '',
      providerName: map['providerName'],
      companyId: map['companyId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'],
      conceptName: map['conceptName'],
      rncOrId: map['rncOrId'] ?? '',
      idType: map['idType']?.toInt() ?? 0,
      conceptId: map['conceptId']?.toInt() ?? 0,
      invoiceNcf: map['invoiceNcf'] ?? '',
      invoiceNcfTypeId: map['invoiceNcfTypeId']?.toInt() ?? 0,
      invoiceNcfModifedTypeId: map['invoiceNcfModifedTypeId']?.toInt(),
      invoiceNcfModifed: map['invoiceNcfModifed'],
      typeOfIncome: map['typeOfIncome'] ?? '',
      invoiceNcfDate: map['invoiceNcfDate'],
      retentionDate: map['retentionDate'],
      total: double.tryParse(map['total']) ?? 0.0,
      tax: double.tryParse(map['tax']) ?? 0.0,
      taxRetentionOthers: double.tryParse(map['taxRetentionOthers']) ?? 0.0,
      perceivedTax: double.tryParse(map['perceivedTax']) ?? 0.0,
      retentionOthers: double.tryParse(map['retentionOthers']) ?? 0.0,
      perceivedISR: double.tryParse(map['perceivedISR']) ?? 0.0,
      selectiveConsumptionTax:
          double.tryParse(map['selectiveConsumptionTax']) ?? 0.0,
      otherTaxesFees: double.tryParse(map['otherTaxesFees']) ?? 0.0,
      legalTipAmount: double.tryParse(map['legalTipAmount']) ?? 0.0,
      effective: double.tryParse(map['effective']) ?? 0.0,
      checkTransferDeposit: double.tryParse(map['checkTransferDeposit']) ?? 0.0,
      debitCreditCard: double.tryParse(map['debitCreditCard']) ?? 0.0,
      saleOnCredit: double.tryParse(map['saleOnCredit']) ?? 0.0,
      vouchersOrGiftCertificates:
          double.tryParse(map['vouchersOrGiftCertificates']) ?? 0.0,
      swap: double.tryParse(map['swap']) ?? 0.0,
      otherFormsOfSales: double.tryParse(map['otherFormsOfSales']) ?? 0.0,
      typeOfIncomeName: map['typeOfIncomeName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Sale.fromJson(String source) => Sale.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Sale(id: $id, companyId: $companyId, authorId: $authorId, authorName: $authorName, rncOrId: $rncOrId, idType: $idType, conceptId: $conceptId, invoiceNcf: $invoiceNcf, invoiceNcfTypeId: $invoiceNcfTypeId, invoiceNcfModifedTypeId: $invoiceNcfModifedTypeId, invoiceNcfModifed: $invoiceNcfModifed, typeOfIncome: $typeOfIncome, invoiceNcfDate: $invoiceNcfDate, retentionDate: $retentionDate, total: $total, tax: $tax, taxRetentionOthers: $taxRetentionOthers, perceivedTax: $perceivedTax, retentionOthers: $retentionOthers, perceivedISR: $perceivedISR, selectiveConsumptionTax: $selectiveConsumptionTax, otherTaxesFees: $otherTaxesFees, legalTipAmount: $legalTipAmount, effective: $effective, checkTransferDeposit: $checkTransferDeposit, debitCreditCard: $debitCreditCard, saleOnCredit: $saleOnCredit, vouchersOrGiftCertificates: $vouchersOrGiftCertificates, swap: $swap, otherFormsOfSales: $otherFormsOfSales, typeOfIncomeName: $typeOfIncomeName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sale &&
        other.id == id &&
        other.companyId == companyId &&
        other.authorId == authorId &&
        other.authorName == authorName &&
        other.rncOrId == rncOrId &&
        other.idType == idType &&
        other.conceptId == conceptId &&
        other.invoiceNcf == invoiceNcf &&
        other.invoiceNcfTypeId == invoiceNcfTypeId &&
        other.invoiceNcfModifedTypeId == invoiceNcfModifedTypeId &&
        other.invoiceNcfModifed == invoiceNcfModifed &&
        other.typeOfIncome == typeOfIncome &&
        other.invoiceNcfDate == invoiceNcfDate &&
        other.retentionDate == retentionDate &&
        other.total == total &&
        other.tax == tax &&
        other.taxRetentionOthers == taxRetentionOthers &&
        other.perceivedTax == perceivedTax &&
        other.retentionOthers == retentionOthers &&
        other.perceivedISR == perceivedISR &&
        other.selectiveConsumptionTax == selectiveConsumptionTax &&
        other.otherTaxesFees == otherTaxesFees &&
        other.legalTipAmount == legalTipAmount &&
        other.effective == effective &&
        other.checkTransferDeposit == checkTransferDeposit &&
        other.debitCreditCard == debitCreditCard &&
        other.saleOnCredit == saleOnCredit &&
        other.vouchersOrGiftCertificates == vouchersOrGiftCertificates &&
        other.swap == swap &&
        other.otherFormsOfSales == otherFormsOfSales &&
        other.typeOfIncomeName == typeOfIncomeName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        authorId.hashCode ^
        authorName.hashCode ^
        rncOrId.hashCode ^
        idType.hashCode ^
        conceptId.hashCode ^
        invoiceNcf.hashCode ^
        invoiceNcfTypeId.hashCode ^
        invoiceNcfModifedTypeId.hashCode ^
        invoiceNcfModifed.hashCode ^
        typeOfIncome.hashCode ^
        invoiceNcfDate.hashCode ^
        retentionDate.hashCode ^
        total.hashCode ^
        tax.hashCode ^
        taxRetentionOthers.hashCode ^
        perceivedTax.hashCode ^
        retentionOthers.hashCode ^
        perceivedISR.hashCode ^
        selectiveConsumptionTax.hashCode ^
        otherTaxesFees.hashCode ^
        legalTipAmount.hashCode ^
        effective.hashCode ^
        checkTransferDeposit.hashCode ^
        debitCreditCard.hashCode ^
        saleOnCredit.hashCode ^
        vouchersOrGiftCertificates.hashCode ^
        swap.hashCode ^
        otherFormsOfSales.hashCode ^
        typeOfIncomeName.hashCode;
  }
}
