import 'dart:io';
import 'dart:convert';

import '../utils/extra.dart';
import 'package:pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:string_mask/string_mask.dart';
import 'package:excel/excel.dart';
import 'package:text_mask/text_mask.dart';

var formatter = StringMask('#.###.00');

formatRncOrId(String string) {
  return TextMask(pallet: string.length == 9 ? '###-#####-#' : '###-#######-#')
      .getMaskedText(string);
}

class Purchase {
  String? id;
  String? invoiceRnc;
  int? invoiceTypeId;
  int? invoiceBankingId;
  int? invoicePaymentMethodId;
  int? invoiceConceptId;
  int? invoiceRetentionId;
  int? invoiceNcfTypeId;
  int? invoiceNcfModifedTypeId;
  int? invoiceYear;
  int? invoiceMonth;
  String? invoiceNcfDay;
  String? invoiceNcf;
  String? invoiceNcfModifed;
  double? invoiceTax;
  double? invoiceTotalAsService;
  double? invoiceTotalAsGood;
  double? invoiceTaxCon;
  int? invoiceRate;
  int? invoiceCk;
  int? invoicePayYear;
  int? invoicePayMonth;
  int? invoicePayDay;
  int? invoiceTaxRetentionId;
  int? invoiceTaxRetentionRate;
  String? invoiceNcfDate;
  String? invoiceSheetId;
  String? invoiceBookId;
  String? invoiceCompanyId;
  String? invoiceCreatedBy;
  String? invoiceTypeName;
  String? invoiceRetentionName;
  String? invoicePaymentMethodName;
  String? invoiceConceptName;
  String? invoiceBankingName;
  String? invoiceCompanyName;
  String? invoiceAuthor;
  String? invoiceFullNcf;
  String? invoiceFullNcfModifed;
  String? invoiceNcfName;
  String? invoiceNcfModifedName;
  String? ckBeneficiary;
  double? invoiceTaxRetentionValue;
  double? invoiceIsrRetentionValue;
  double? invoiceTotal;
  double? invoiceNetTotal;
  double? invoiceFinalTax;
  double? invoiceLegalTipAmount;
  double? invoiceIsrInPurchases;
  double? invoiceSelectiveConsumptionTax;
  double? invoiceTaxInPurchases;
  double? invoiceOthersTaxes;
  double? rate;
  double? totalInForeignCurrency;
  double? amountPaid;
  double? debt;
  String? checkId;
  String? bankingModel;
  DateTime? invoiceIssueDate;
  DateTime? invoicePayDate;
  bool authorized;
  DateTime? createdAt;
  bool? isCopy;
  bool? isDuplicate;

  Purchase(
      {this.id,
      this.totalInForeignCurrency,
      this.rate,
      this.invoiceRnc,
      this.invoiceTypeId,
      this.invoiceBankingId,
      this.invoicePaymentMethodId,
      this.invoiceConceptId,
      this.invoiceRetentionId,
      this.invoiceNcfTypeId,
      this.invoiceNcfModifedTypeId,
      this.invoiceYear,
      this.invoiceMonth,
      this.invoiceNcfDay,
      this.invoiceNcf,
      this.invoiceNcfModifed,
      this.invoiceTax,
      this.invoiceTotalAsService,
      this.invoiceTotalAsGood,
      this.invoiceCk,
      this.invoiceNcfDate,
      this.invoiceSheetId,
      this.invoiceBookId,
      this.invoiceCompanyId,
      this.invoiceCreatedBy,
      this.invoiceTypeName,
      this.invoiceRetentionName,
      this.invoicePaymentMethodName,
      this.invoiceConceptName,
      this.invoiceBankingName,
      this.invoiceCompanyName,
      this.invoiceAuthor,
      this.invoiceFullNcf,
      this.invoiceFullNcfModifed,
      this.invoiceNcfModifedName,
      this.invoiceRate,
      this.invoicePayYear,
      this.invoicePayMonth,
      this.invoicePayDay,
      this.invoiceTaxRetentionId,
      this.invoiceTaxRetentionRate,
      this.invoiceNcfName,
      this.invoiceTaxRetentionValue,
      this.invoiceIsrRetentionValue,
      this.invoiceTotal,
      this.invoiceNetTotal,
      this.invoiceTaxCon,
      this.invoiceFinalTax,
      this.invoiceLegalTipAmount,
      this.invoiceIsrInPurchases,
      this.invoiceSelectiveConsumptionTax,
      this.invoiceTaxInPurchases,
      this.invoiceOthersTaxes,
      this.authorized = true,
      this.invoiceIssueDate,
      this.invoicePayDate,
      this.ckBeneficiary,
      this.amountPaid,
      this.debt,
      this.createdAt,
      this.checkId,
      this.bankingModel,
      this.isCopy,
      this.isDuplicate});

  static Purchase fromMapOriginal(Map<String, dynamic> p) {
    return Purchase(
        id: p['id'],
        isDuplicate: p['isDuplicate'],
        invoiceCompanyId: p['invoice_companyId'],
        invoiceCreatedBy: p['invoice_created_by'],
        invoiceConceptId: p['invoice_conceptId'],
        invoiceRnc: p['invoice_rnc'],
        invoiceTypeId: p['invoice_typeId'],
        invoiceBankingId: p['invoice_bankingId'],
        invoicePaymentMethodId: p['invoice_payment_methodId'],
        createdAt: DateTime.tryParse(p['created_at']),
        invoiceCk: p['invoice_ck'],
        invoiceRetentionId: p['invoice_retentionId'],
        invoiceNcfTypeId: p['invoice_ncf_typeId'],
        invoiceNcf: p['invoice_ncf'],
        invoiceNcfModifed: p['invoice_ncf_modifed'],
        invoiceNcfModifedTypeId: p['invoice_ncfModifed_typeId'],
        invoiceTax: p['invoice_tax'],
        invoiceTaxRetentionId: p['invoice_tax_retentionId'],
        authorized: p['authorized'],
        invoiceTotal: p['invoice_total'],
        invoiceTaxCon: p['invoice_tax_con'],
        invoiceLegalTipAmount: p['invoice_legal_tip_amount'],
        invoiceIsrInPurchases: p['isr_in_purchases'],
        invoiceSelectiveConsumptionTax: p['selective_consumption_tax'],
        invoiceTaxInPurchases: p['tax_in_purchases'],
        invoiceOthersTaxes: p['other_taxes'],
        amountPaid: p['amountPaid'],
        invoiceIssueDate: DateTime.tryParse(p['invoice_issue_date']),
        invoicePayDate: DateTime.tryParse(p['invoice_pay_date']),
        ckBeneficiary: p['ck_beneficiary'],
        totalInForeignCurrency: p['totalInForeignCurrency'],
        rate: p['rate']);
  }

  static Future<List<Purchase>> getOriginal(
      {required String companyId,
      required DateTime startDate,
      required DateTime endDate}) async {
    try {
      var res = await connection.mappedResultsQuery('''
            SELECT * FROM 
            public."Purchase"
            WHERE
            "invoice_companyId" = '$companyId' 
            and ("invoice_issue_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' or "invoice_pay_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}') order by "invoice_issue_date";''');
      return res.map((e) {
        var p = e['Purchase']!;
        return Purchase(
            id: const Uuid().v4(),
            invoiceConceptId: p['invoice_conceptId'],
            invoiceRnc: p['invoice_rnc'],
            invoiceTypeId: p['invoice_typeId'],
            invoiceBankingId: p['invoice_bankingId'],
            invoicePaymentMethodId: p['invoice_payment_methodId'],
            createdAt: p['created_at'],
            invoiceCk: p['invoice_ck'],
            invoiceRetentionId: p['invoice_retentionId'],
            invoiceNcfTypeId: p['invoice_ncf_typeId'],
            invoiceNcfModifedTypeId: p['invoice_ncfModifed_typeId'],
            invoiceNcf: p['invoice_ncf'],
            invoiceNcfModifed: p['invoice_ncf_modifed'],
            invoiceTax: double.tryParse(p['invoice_tax']),
            invoiceTaxRetentionId: p['invoice_tax_retentionId'],
            authorized: p['authorized'],
            invoiceTotal: double.tryParse(p['invoice_total']),
            invoiceTaxCon: double.tryParse(p['invoice_tax_con']),
            invoiceLegalTipAmount:
                double.tryParse(p['invoice_legal_tip_amount']),
            invoiceIsrInPurchases: double.tryParse(p['isr_in_purchases']),
            invoiceSelectiveConsumptionTax:
                double.tryParse(p['selective_consumption_tax']),
            invoiceTaxInPurchases: double.tryParse(p['tax_in_purchases']),
            invoiceOthersTaxes: double.tryParse(p['other_taxes']),
            invoiceIssueDate: p['invoice_issue_date'],
            invoicePayDate: p['invoice_pay_date'],
            ckBeneficiary: p['ck_beneficiary'],
            amountPaid: double.tryParse(p['amountPaid']),
            totalInForeignCurrency:
                double.tryParse(p['totalInForeignCurrency']),
            rate: double.tryParse(p['rate']));
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  toMapOriginal() {
    return {
      'id': id,
      'invoice_rnc': invoiceRnc,
      'invoice_companyId': invoiceCompanyId,
      'invoice_created_by': invoiceCreatedBy,
      'invoice_conceptId': invoiceConceptId,
      'invoice_typeId': invoiceTypeId,
      'invoice_bankingId': invoiceBankingId,
      'invoice_payment_methodId': invoicePaymentMethodId,
      'created_at': createdAt.toString(),
      'invoice_ck': invoiceCk,
      'invoice_retentionId': invoiceRetentionId,
      'invoice_ncf_typeId': invoiceNcfTypeId,
      'invoice_ncfModifed_typeId': invoiceNcfModifedTypeId,
      'invoice_ncf': invoiceNcf,
      'invoice_ncf_modifed': invoiceNcfModifed,
      'invoice_tax': invoiceTax,
      'invoice_tax_retentionId': invoiceTaxRetentionId,
      'authorized': authorized,
      'invoice_total': invoiceTotal,
      'invoice_tax_con': invoiceTaxCon,
      'invoice_legal_tip_amount': invoiceLegalTipAmount,
      'isr_in_purchases': invoiceIsrInPurchases,
      'selective_consumption_tax': invoiceSelectiveConsumptionTax,
      'tax_in_purchases': invoiceTaxInPurchases,
      'other_taxes': invoiceOthersTaxes,
      'invoice_issue_date': invoiceIssueDate.toString(),
      'invoice_pay_date': invoicePayDate.toString(),
      'ck_beneficiary': ckBeneficiary,
      'totalInForeignCurrency': totalInForeignCurrency,
      'rate': rate,
      'amountPaid': amountPaid
    };
  }

  Future<void> updateAuthorization(bool newValue) async {
    await connection.execute(
        '''update public."Purchase" set authorized = $newValue where "id" = '$id';''');
  }

  static Future<Map<String, dynamic>> getReportViewByCompanyName(
      {String words = '',
      String filterParams = '',
      String targetPath = '',
      String reportName = 'REPORTE FISCAL',
      required Company company,
      required DateTime startDate,
      required DateTime endDate,
      QueryContext queryContext = QueryContext.tax}) async {
    String id = company.id!;

    String queryContextI = 'and';

    if (queryContext == QueryContext.consumption) {
      queryContextI =
          'and ("invoice_ncf_typeId" = 2 or "invoice_ncf_typeId" = 32 or "invoice_ncf_typeId" is null) and';
    } else if (queryContext == QueryContext.tax) {
      queryContextI =
          'and "invoice_ncf_typeId" != 2 and "invoice_ncf_typeId" != 32 and not("invoice_ncf_typeId" is null) and';
    }

    var extra = '';

    if (words != '') {
      extra =
          '''("invoice_ck"::text like @searchWord or "invoice_banking_name" like @searchWord or "invoice_author" like @searchWord or "invoice_concept_name" like @searchWord or "invoice_rnc" = @searchWord or "invoice_company_name" like @searchWord or "invoice_ncf" like @searchWord or "invoice_ncf_modifed" like @searchWord or "invoice_type_name" like @searchWord) and ''';
    }

    String rangeDatesAsString =
        ''' ("invoice_issue_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}') ''';

    String subParams =
        '''$filterParams "invoice_companyId" = '$id' $queryContextI $extra''';

    String where = '''$subParams $rangeDatesAsString''';

    try {
      var rsults = await connection.runTx((c) async {
        var r1 = await c.mappedResultsQuery('''
        SELECT * FROM (
        SELECT 
        invoice_company_name AS "NOMBRE",
        coalesce(sum(coalesce(invoice_total_as_service,0)),0)::money::text AS "TOTAL EN SERVICIOS",
        coalesce(sum(coalesce(invoice_total_as_good,0)),0)::money::text AS "TOTAL EN BIENES",
        coalesce(sum(coalesce(invoice_total,0)),0)::money::text AS "TOTAL FACTURADO",
        coalesce(sum(coalesce(invoice_final_tax,0)),0)::money::text AS "ITBIS POR ADELANTAR",
        coalesce(sum(coalesce(invoice_net_total,0)),0)::money::text AS "TOTAL NETO",
        coalesce(sum(coalesce("debt",0)),0)::money::text AS "DEUDA"
        FROM public."PurchaseDetails"
        WHERE $where
        GROUP BY invoice_company_name
        UNION ALL
        SELECT 
        'TOTAL GENERAL', 
        coalesce(sum(coalesce(invoice_total_as_service,0)),0)::money::text,
        coalesce(sum(coalesce(invoice_total_as_good,0)),0)::money::text,
        coalesce(sum(coalesce(invoice_total,0)),0)::money::text,
        coalesce(sum(coalesce(invoice_final_tax,0)),0)::money::text,
        coalesce(sum(coalesce(invoice_net_total,0)),0)::money::text,
        coalesce(sum(coalesce("debt",0)),0)::money::text
        FROM public."PurchaseDetails"
        WHERE $where
        ) as c
       ORDER BY row_number() over() asc
      ''', substitutionValues: {'searchWord': '%$words%'});

        var r2 = await c.mappedResultsQuery('''
           SELECT trunc(sum(p.invoice_tax - p.invoice_tax_con),2)::money::text AS "ITBIS FACTURADO EN BIENES" FROM public."PurchaseDetails" p WHERE $where and (p."invoice_typeId" = 9 or p."invoice_typeId" = 8 or p."invoice_typeId" = 10)
      ''', substitutionValues: {'searchWord': '%$words%'});

        var r3 = await c.mappedResultsQuery('''
           SELECT trunc(coalesce(sum(p.invoice_tax - p.invoice_tax_con),0),2)::money::text AS "ITBIS FACTURADO EN SERVICIOS" FROM public."PurchaseDetails" p WHERE $where and (p."invoice_typeId" != 9 and p."invoice_typeId" != 8 and p."invoice_typeId" != 10)''',
            substitutionValues: {'searchWord': '%$words%'});

        var r5 = await c.mappedResultsQuery('''
        select 
        coalesce(sum(invoice_tax_retention_value),0)::money::text AS "ITBIS RETENIDO"
        from 
        public."PurchaseDetails" 
        where $subParams invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r6 = await c.mappedResultsQuery('''
        select 
         coalesce(sum(invoice_isr_retention_value),0)::money::text AS "ISR RETENIDO"
        from 
        public."PurchaseDetails" 
        where $subParams invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r7 = await c.mappedResultsQuery('''
        select 
        coalesce(sum(invoice_tax_retention_value),0)::money::text AS "ITBIS RETENIDO 30%"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_tax_retentionId" = 1 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r8 = await c.mappedResultsQuery('''
        select 
        coalesce(sum(invoice_tax_retention_value),0)::money::text AS "ITBIS RETENIDO 100%"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_tax_retentionId" = 2 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r9 = await c.mappedResultsQuery('''
        select 
        coalesce(sum(invoice_isr_retention_value),0)::money::text AS "ISR RETENIDO (ALQUILERES 10%)"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_retentionId" = 1 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r10 = await c.mappedResultsQuery('''
        select 
      coalesce(sum(invoice_isr_retention_value),0)::money::text AS "ISR RETENIDO (HONORARIOS POR SERVICIOS 10%)"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_retentionId" = 2 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r11 = await c.mappedResultsQuery('''
        select 
         coalesce(sum(invoice_isr_retention_value),0)::money::text AS "ISR RETENIDO (OTRAS RENTAS 2%)"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_retentionId" = 3 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r12 = await c.mappedResultsQuery('''
            SELECT   trunc(coalesce(sum(p.invoice_tax - p.invoice_tax_con),0),2)::money::text AS "ITBIS FACTURADO" FROM public."PurchaseDetails" p WHERE $where''',
            substitutionValues: {'searchWord': '%$words%'});

        var r4 = await c.mappedResultsQuery(
            '''SELECT COUNT(*) AS "TOTAL DE DOCUMENTOS" FROM public."PurchaseDetails" p WHERE $where''',
            substitutionValues: {'searchWord': '%$words%'});

        return [r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12];
      });

      var r1 = rsults[0];

      var data = r1.map((e) => e['']!).toList();

      var r2 = rsults[1];

      var r3 = rsults[2];

      var r4 = rsults[3];

      var r5 = rsults[4];

      var r6 = rsults[5];

      var r7 = rsults[6];

      var r8 = rsults[7];

      var r9 = rsults[8];

      var r10 = rsults[9];

      var r11 = rsults[10];

      var r12 = rsults[11];

      var taxGoods = r2.first['']?['ITBIS FACTURADO EN BIENES'];

      var taxServices = r3.first['']?['ITBIS FACTURADO EN SERVICIOS'];

      var taxRetention = r5.first['']?['ITBIS RETENIDO'];

      var isrRetention = r6.first['']?['ISR RETENIDO'];

      var taxRetention30 = r7.first['']?['ITBIS RETENIDO 30%'];

      var taxRetention100 = r8.first['']?['ITBIS RETENIDO 100%'];

      var isrRetentionAlq10 = r9.first['']?['ISR RETENIDO (ALQUILERES 10%)'];

      var isrRetentionHon10 =
          r10.first['']?['ISR RETENIDO (HONORARIOS POR SERVICIOS 10%)'];

      var isrRetentionOt2 = r11.first['']?['ISR RETENIDO (OTRAS RENTAS 2%)'];

      var taxFi = r12.first['']?['ITBIS FACTURADO'];

      var countDocs = r4.first['']?['TOTAL DE DOCUMENTOS'] ?? '0';

      late Excel excel;

      var file = File(targetPath);

      if (!file.existsSync()) {
        excel = Excel.createExcel();
      } else {
        excel = Excel.decodeBytes(await file.readAsBytes());
      }

      var sheetName =
          '$reportName - ${startDate.format(payload: 'YYYY-MM-DD')} - ${endDate.format(payload: 'YYYY-MM-DD')}';

      excel.delete('Sheet1');

      var sheet = excel[sheetName];

      var list = data;

      var item = list[0];

      var keys = item.keys.toList();

      int endHeaderRowIndex = 3;

      var c =
          sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: 0));

      c.value = TextCellValue(sheetName);

      for (int i = 0; i < keys.length; i++) {
        var c = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: i, rowIndex: endHeaderRowIndex));
        c.value = TextCellValue(keys[i]);
      }

      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var values = item.values.toList();
        for (int j = 0; j < values.length; j++) {
          var val = values[j];
          var c = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: j, rowIndex: (endHeaderRowIndex + 1) + i));
          c.value = TextCellValue(val ?? '');
        }
      }

      pw.Document document = pw.Document();

      var oneRow =
          data.where((element) => element['NOMBRE'] == 'TOTAL GENERAL').first;
      var xdata = [...data];

      dhead() {
        return pw.TableRow(
            children: data[0].keys.map((key) {
          return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      key,
                      style: pw.TextStyle(
                        fontSize: pdfFontSize,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0x0000000),
                      ),
                    ),
                  ]));
        }).toList());
      }

      dheadTwo() {
        return pw.TableRow(
            children: oneRow.values.map((key) {
          return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      key,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0x0000000),
                      ),
                    ),
                  ]));
        }).toList());
      }

      xdata.removeWhere((e) => e['NOMBRE'] == 'TOTAL GENERAL');

      drows() {
        return xdata.map((item) {
          return pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColor.fromInt(0xA8A8A8), width: 0.3)),
              ),
              children: item.entries.map((entry) {
                var j = item.values.toList().indexOf(entry.value);
                //bool isTotal = j == 0 && index == 0;

                return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(entry.value ?? '\$0.00',
                              style: pw.TextStyle(
                                fontSize: pdfFontSize,
                              )),
                        ]));
              }).toList());
        }).toList();
      }

      List<pw.Widget> preCompanyData = [];

      if (company.address != null) {
        preCompanyData.addAll([
          pw.Text('${company.address}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
        ]);
      }

      if (company.email != null) {
        preCompanyData.addAll([
          pw.Text('${company.email}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
        ]);
      }

      var pages = pw.MultiPage(
          pageFormat:
              PdfPageFormat(PdfPageFormat.a4.width, 27.9 * PdfPageFormat.cm),
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(12),
          maxPages: 80,
          header: (ctx) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('${company.name}',
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          ...preCompanyData,
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text('RNC ${formatRncOrId(company.rnc!)}',
                                  style: const pw.TextStyle(fontSize: 10)),
                              company.phone != null
                                  ? pw.Text(',TEL. ${company.phone}',
                                      style: const pw.TextStyle(fontSize: 10))
                                  : pw.SizedBox(),
                            ],
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                              'FECHA DE EMISION ${DateTime.now().format(payload: 'DD/MM/YYYY')}',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 10),
                          pw.Text(
                              'PERIODOS ${startDate.format(payload: 'DD/MM/YYYY')} - ${endDate.format(payload: 'DD/MM/YYYY')}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(reportName,
                              style: pw.TextStyle(
                                  fontSize: 20, fontWeight: pw.FontWeight.bold))
                        ],
                      )
                    ]),
                pw.SizedBox(height: 20),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(260),
                    1: const pw.FixedColumnWidth(60),
                    2: const pw.FixedColumnWidth(60),
                    3: const pw.FixedColumnWidth(60),
                    4: const pw.FixedColumnWidth(60),
                    5: const pw.FixedColumnWidth(60),
                    6: const pw.FixedColumnWidth(60),
                    7: const pw.FixedColumnWidth(60)
                  },
                  children: [dheadTwo(), dhead()],
                )
              ],
            );
          },
          build: (pw.Context context) {
            return [
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(260),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FixedColumnWidth(60),
                  5: const pw.FixedColumnWidth(60),
                  6: const pw.FixedColumnWidth(60),
                  7: const pw.FixedColumnWidth(60)
                },
                children: [
                  ...drows(),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ITBIS FACTURADO EN SERVICIOS: $taxServices',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        pw.SizedBox(height: 15),
                        pw.Text('ITBIS FACTURADO EN BIENES: $taxGoods',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        pw.SizedBox(height: 15),
                        pw.Text('TOTAL ITBIS FACTURADO: $taxFi',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      ],
                    ),
                    pw.SizedBox(width: 20),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('ITBIS RETENIDO 30%: $taxRetention30',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text('ITBIS RETENIDO 100%: $taxRetention100',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text('TOTAL ITBIS RETENIDO: $taxRetention',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        ]),
                    pw.SizedBox(width: 20),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'ISR RETENIDO (ALQUILERES 10%): $isrRetentionAlq10',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text(
                              'ISR RETENIDO (HONORARIOS POR SERVICIOS 10%): $isrRetentionHon10',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text(
                              'ISR RETENIDO (OTRAS RENTAS 2%): $isrRetentionOt2',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text('TOTAL ISR RETENIDO: $isrRetention',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        ]),
                  ]),
              pw.SizedBox(height: 15),
              pw.Text('TOTAL DE DOCUMENTOS: $countDocs',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ]; // Center
          });

      document.addPage(pages);

      return {
        'data': data,
        'excelBytes': excel.save(),
        'pdfBytes': await document.save(),
        'footer': {
          'ITBIS EN SERVICIOS': taxServices,
          'ITBIS EN BIENES': taxGoods,
          'TOTAL ITBIS FACTURADO': taxFi,
          'ITBIS RETENIDO 30%': taxRetention30,
          'ITBIS RETENIDO 100%': taxRetention100,
          'TOTAL ITBIS RETENIDO': taxRetention,
          'ISR RETENIDO (ALQUILERES 10%)': isrRetentionAlq10,
          'ISR RETENIDO (HONORARIOS POR SERVICIOS 10%)': isrRetentionHon10,
          'ISR RETENIDO (OTRAS RENTAS 2%)': isrRetentionOt2,
          'TOTAL ISR RETENIDO': isrRetention
        }
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createXls(
      {String id = '',
      String targetPath = '',
      String sheetName = '',
      required DateTime startDate,
      required DateTime endDate}) async {
    String queryContextI =
        'and p."invoice_ncf_typeId" != 2 and p."invoice_ncf_typeId" != 32 and not("invoice_ncf_typeId" is null) and';

    String where =
        '''authorized = true and p."invoice_companyId" = '$id' $queryContextI p."invoice_issue_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''';

    try {
      if (Platform.isMacOS) {
        await connection.query('''SET lc_monetary = 'en_US.US-ASCII';''');
      } else {
        await connection.query('''SET lc_monetary = 'es_US';''');
      }

      var result = await connection.mappedResultsQuery('''
              SELECT * FROM (
              SELECT 
              COALESCE(p.invoice_company_name, 'TOTAL GENERAL') AS "NOMBRE",
              p.invoice_rnc AS "RNC",
              p."invoice_typeId" AS "CODIGO",
              p.invoice_type_name AS "TIPO DE FACTURA",
              p.invoice_ncf AS "NCF",
              p.invoice_ncf_modifed AS "NCF MODIFICADO",
              sum(p.invoice_total_as_service)::money::text AS "TOTAL EN SERVICIOS",
              sum(p.invoice_total_as_good)::money::text AS "TOTAL EN BIENES",
              sum(p.invoice_total)::money::text AS "TOTAL FACTURADO",
              sum(p.invoice_final_tax)::money::text AS "ITBIS POR ADELANTAR",
              sum(p.invoice_net_total)::money::text AS "TOTAL NETO",
              sum(p.invoice_tax_retention_value::numeric(10,2))::money::text AS "ITBIS RETENIDO",
              sum(p.invoice_tax_con)::money::text AS "ITBIS LLEVADO AL COSTO",
              p.invoice_issue_date::text AS "FECHA DE EMISION DE COMPROBANTE",
              p.invoice_pay_date::text AS "FECHA DE PAGO DE COMPROBANTE",
              p.invoice_retention_name AS "NOMBRE DE RETENCION ISR",
              sum(p.invoice_isr_retention_value::numeric(10,2))::money::text AS "RETENCION ISR",
              p.invoice_payment_method_name AS "METODO DE PAGO"
              FROM "PurchaseDetails" p 
              WHERE $where
              GROUP BY GROUPING SETS ((invoice_company_name,
             "invoice_typeId",
             invoice_rnc,
             invoice_type_name,
             invoice_ncf,
             invoice_ncf_modifed,
             invoice_total_as_service, 
             invoice_total_as_good,invoice_total,invoice_tax,
             invoice_tax_retention_value,
             invoice_tax_con,
             invoice_final_tax,
             invoice_issue_date,
             invoice_pay_date,
             invoice_retention_name,
             invoice_isr_retention_value,
             invoice_payment_method_name), ())
             ) AS epic ORDER BY "CODIGO"
     ''');

      var file = File(targetPath);

      Excel excel;

      List<int>? bytes = [];

      var list = result.map((e) => e['']).toList();

      if (file.existsSync()) {
        bytes = await file.readAsBytes();
        excel = Excel.decodeBytes(bytes);
      } else {
        excel = Excel.createExcel();
      }
      excel.delete('Sheet1');
      excel.delete('Sheet1');

      var sheetName =
          '''${startDate.format(payload: 'YYMMDD')}-${endDate.format(payload: 'YYMMDD')}''';

      var sheet = excel[sheetName];

      for (int i = 0; i < list.length; i++) {
        var values = list[i]?.values.toList();
        var keys = list[i]?.keys.toList();

        for (int j = 0; j < keys!.length; j++) {
          var cell = sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 0));
          cell.value = TextCellValue(keys[j]);
        }

        for (int j = 0; j < values!.length; j++) {
          var cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));

          cell.value = TextCellValue(values[j]?.toString() ?? '');
        }
      }
      bytes = excel.save();

      await file.create(recursive: true);
      await file.writeAsBytes(bytes!);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getReportViewByInvoiceType(
      {String words = '',
      String filterParams = 'authorized = true and',
      String targetPath = '',
      String reportName = 'REPORTE FISCAL',
      required DateTime startDate,
      required DateTime endDate,
      required Company company,
      QueryContext queryContext = QueryContext.tax}) async {
    String id = company.id!;

    String queryContextI = 'and';

    if (queryContext == QueryContext.consumption) {
      queryContextI =
          'and ("invoice_ncf_typeId" = 2 or "invoice_ncf_typeId" = 32 or "invoice_ncf_typeId" is null) and';
    } else if (queryContext == QueryContext.tax) {
      queryContextI =
          'and "invoice_ncf_typeId" != 2 and "invoice_ncf_typeId" != 32 and not("invoice_ncf_typeId" is null) and';
    }

    var extra = '';

    if (words != '') {
      extra =
          '''("invoice_ck"::text like @searchWord or "invoice_author" like @searchWord or "invoice_concept_name" like @searchWord or "invoice_banking_name" like @searchWord or "invoice_rnc" = @searchWord or "invoice_company_name" like @searchWord or "invoice_ncf" like @searchWord or "invoice_ncf_modifed" like @searchWord or "invoice_type_name" like @searchWord) and ''';
    }
    String rangeDatesAsString =
        ''' ("invoice_issue_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}')  ''';

    String subParams =
        '''$filterParams "invoice_companyId" = '$id' $queryContextI $extra''';
    String where = '''$subParams $rangeDatesAsString''';

    try {
      var rsults = await connection.runTx((c) async {
        var r1 = await c.mappedResultsQuery('''
       SELECT * FROM (
    SELECT 
        invoice_type_name AS "NOMBRE",
        COALESCE(sum(COALESCE(invoice_total_as_service, 0)), 0)::money::text AS "TOTAL EN SERVICIOS",
        COALESCE(sum(COALESCE(invoice_total_as_good, 0)), 0)::money::text AS "TOTAL EN BIENES",
        COALESCE(sum(COALESCE(invoice_total, 0)), 0)::money::text AS "TOTAL FACTURADO",
        COALESCE(sum(COALESCE(invoice_final_tax, 0)), 0)::money::text AS "ITBIS POR ADELANTAR",
        COALESCE(sum(COALESCE(invoice_net_total, 0)), 0)::money::text AS "TOTAL NETO",
        COALESCE(sum(COALESCE(debt, 0)), 0)::money::text AS "DEUDA"
    FROM public."PurchaseDetails"
    WHERE $where
    GROUP BY invoice_type_name
    UNION ALL
    SELECT 
        'TOTAL GENERAL', 
        COALESCE(sum(COALESCE(invoice_total_as_service, 0)), 0)::money::text,
        COALESCE(sum(COALESCE(invoice_total_as_good, 0)), 0)::money::text,
        COALESCE(sum(COALESCE(invoice_total, 0)), 0)::money::text,
        COALESCE(sum(COALESCE(invoice_final_tax, 0)), 0)::money::text,
        COALESCE(sum(COALESCE(invoice_net_total, 0)), 0)::money::text,
        COALESCE(sum(COALESCE(debt, 0)), 0)::money::text
    FROM public."PurchaseDetails" p
    WHERE $where
) as c
ORDER BY row_number() over() asc;
      ''', substitutionValues: {'searchWord': '%$words%'});
        var r2 = await c.mappedResultsQuery('''
           SELECT  trunc(coalesce(sum(p.invoice_tax - p.invoice_tax_con),0),2)::money::text AS "ITBIS FACTURADO EN BIENES" FROM public."PurchaseDetails" p WHERE $where and (p."invoice_typeId" = 9 or p."invoice_typeId" = 8 or p."invoice_typeId" = 10)
      ''', substitutionValues: {'searchWord': '%$words%'});

        var r3 = await c.mappedResultsQuery('''
            SELECT   trunc(coalesce(sum(p.invoice_tax - p.invoice_tax_con),0),2)::money::text AS "ITBIS FACTURADO EN SERVICIOS" FROM public."PurchaseDetails" p WHERE $where and (p."invoice_typeId" != 9 and p."invoice_typeId" != 8 and p."invoice_typeId" != 10)''',
            substitutionValues: {'searchWord': '%$words%'});

        var r5 = await c.mappedResultsQuery('''
        select 
       coalesce(sum(invoice_tax_retention_value),0)::money::text AS "ITBIS RETENIDO"
        from 
        public."PurchaseDetails" 
        where $subParams invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r6 = await c.mappedResultsQuery('''
        select 
            coalesce(sum(invoice_isr_retention_value),0)::money::text AS "ISR RETENIDO"
        from 
        public."PurchaseDetails" 
        where $subParams invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r7 = await c.mappedResultsQuery('''
        select 
        coalesce(sum(invoice_tax_retention_value),0)::money::text AS "ITBIS RETENIDO 30%"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_tax_retentionId" = 1 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r8 = await c.mappedResultsQuery('''
        select 
         coalesce(sum(invoice_tax_retention_value),0)::money::text AS "ITBIS RETENIDO 100%"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_tax_retentionId" = 2 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r9 = await c.mappedResultsQuery('''
        select 
      coalesce(sum(invoice_isr_retention_value),0)::money::text AS "ISR RETENIDO (ALQUILERES 10%)"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_retentionId" = 1 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r10 = await c.mappedResultsQuery('''
        select 
        coalesce(sum(invoice_isr_retention_value),0)::money::text AS "ISR RETENIDO (HONORARIOS POR SERVICIOS 10%)"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_retentionId" = 2 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r11 = await c.mappedResultsQuery('''
        select 
        coalesce(sum(invoice_isr_retention_value),0)::money::text AS "ISR RETENIDO (OTRAS RENTAS 2%)"
        from 
        public."PurchaseDetails" 
        where  $subParams "invoice_retentionId" = 3 and invoice_pay_date between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' ''',
            substitutionValues: {'searchWord': '%$words%'});

        var r12 = await c.mappedResultsQuery('''
            SELECT  trunc(coalesce(sum(p.invoice_tax - p.invoice_tax_con),0),2)::money::text AS "ITBIS FACTURADO" FROM public."PurchaseDetails" p WHERE $where''',
            substitutionValues: {'searchWord': '%$words%'});

        var r4 = await c.mappedResultsQuery(
            '''SELECT COUNT(*) AS "TOTAL DE DOCUMENTOS" FROM public."PurchaseDetails" p WHERE $where''',
            substitutionValues: {'searchWord': '%$words%'});

        return [r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12];
      });

      var r1 = rsults[0];

      var r2 = rsults[1];

      var r3 = rsults[2];

      var r4 = rsults[3];

      var r5 = rsults[4];

      var r6 = rsults[5];

      var r7 = rsults[6];

      var r8 = rsults[7];

      var r9 = rsults[8];

      var r10 = rsults[9];

      var r11 = rsults[10];

      var r12 = rsults[11];

      var data = r1.map((e) => e['']!).toList();

      var taxServices = r3.first['']?['ITBIS FACTURADO EN SERVICIOS'];

      var taxGoods = r2.first['']?['ITBIS FACTURADO EN BIENES'];

      var taxRetention = r5.first['']?['ITBIS RETENIDO'];

      var isrRetention = r6.first['']?['ISR RETENIDO'];

      var taxRetention30 = r7.first['']?['ITBIS RETENIDO 30%'];

      var taxRetention100 = r8.first['']?['ITBIS RETENIDO 100%'];

      var isrRetentionAlq10 = r9.first['']?['ISR RETENIDO (ALQUILERES 10%)'];

      var isrRetentionHon10 =
          r10.first['']?['ISR RETENIDO (HONORARIOS POR SERVICIOS 10%)'];

      var isrRetentionOt2 = r11.first['']?['ISR RETENIDO (OTRAS RENTAS 2%)'];

      var taxFi = r12.first['']?['ITBIS FACTURADO'];

      var countDocs = r4.first['']?['TOTAL DE DOCUMENTOS'] ?? '0';

      late Excel excel;

      var file = File(targetPath);

      if (!file.existsSync()) {
        excel = Excel.createExcel();
      } else {
        excel = Excel.decodeBytes(await file.readAsBytes());
      }

      var sheetName =
          '$reportName - ${startDate.format(payload: 'YYYY-MM-DD')} - ${endDate.format(payload: 'YYYY-MM-DD')}';

      excel.delete('Sheet1');

      var sheet = excel[sheetName];

      var list = data;

      var item = list[0];

      var keys = item.keys.toList();

      int endHeaderRowIndex = 3;

      var c =
          sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: 0));

      c.value = TextCellValue(sheetName);

      for (int i = 0; i < keys.length; i++) {
        var c = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: i, rowIndex: endHeaderRowIndex));
        c.value = TextCellValue(keys[i]);
      }

      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var values = item.values.toList();
        for (int j = 0; j < values.length; j++) {
          var val = values[j];
          var c = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: j, rowIndex: (endHeaderRowIndex + 1) + i));
          c.value = TextCellValue(val ?? '');
        }
      }

      pw.Document document = pw.Document();

      var oneRow =
          data.where((element) => element['NOMBRE'] == 'TOTAL GENERAL').first;
      var xdata = [...data];

      dhead() {
        return pw.TableRow(
            children: data[0].keys.map((key) {
          return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      key,
                      style: pw.TextStyle(
                        fontSize: pdfFontSize,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0x0000000),
                      ),
                    ),
                  ]));
        }).toList());
      }

      dheadTwo() {
        return pw.TableRow(
            children: oneRow.values.map((key) {
          return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      key,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0x0000000),
                      ),
                    ),
                  ]));
        }).toList());
      }

      xdata.removeWhere((element) => element['NOMBRE'] == 'TOTAL GENERAL');

      drows() {
        return xdata.map((item) {
          return pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColor.fromInt(0xA8A8A8), width: 0.3)),
              ),
              children: item.entries.map((entry) {
                return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(entry.value ?? '\$0.00',
                              style: pw.TextStyle(
                                fontSize: pdfFontSize,
                              )),
                        ]));
              }).toList());
        }).toList();
      }

      List<pw.Widget> preCompanyData = [];

      if (company.address != null) {
        preCompanyData.addAll([
          pw.Text('${company.address}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
        ]);
      }

      if (company.email != null) {
        preCompanyData.addAll([
          pw.Text('${company.email}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
        ]);
      }

      var pages = pw.MultiPage(
          pageFormat:
              PdfPageFormat(PdfPageFormat.a4.width, 27.9 * PdfPageFormat.cm),
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(12),
          maxPages: 80,
          header: (ctx) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('${company.name}',
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          ...preCompanyData,
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text('RNC ${formatRncOrId(company.rnc!)}',
                                  style: const pw.TextStyle(fontSize: 10)),
                              company.phone != null
                                  ? pw.Text(',TEL. ${company.phone}',
                                      style: const pw.TextStyle(fontSize: 10))
                                  : pw.SizedBox(),
                            ],
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                              'FECHA DE EMISION ${DateTime.now().format(payload: 'DD/MM/YYYY')}',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 10),
                          pw.Text(
                              'PERIODOS ${startDate.format(payload: 'DD/MM/YYYY')} - ${endDate.format(payload: 'DD/MM/YYYY')}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(reportName,
                              style: pw.TextStyle(
                                  fontSize: 20, fontWeight: pw.FontWeight.bold))
                        ],
                      )
                    ]),
                pw.SizedBox(height: 20),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(260),
                    1: const pw.FixedColumnWidth(60),
                    2: const pw.FixedColumnWidth(60),
                    3: const pw.FixedColumnWidth(60),
                    4: const pw.FixedColumnWidth(60),
                    5: const pw.FixedColumnWidth(60),
                    6: const pw.FixedColumnWidth(60),
                    7: const pw.FixedColumnWidth(60)
                  },
                  children: [dheadTwo(), dhead()],
                )
              ],
            );
          },
          build: (pw.Context context) {
            return [
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(260),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FixedColumnWidth(60),
                  5: const pw.FixedColumnWidth(60),
                  6: const pw.FixedColumnWidth(60),
                  7: const pw.FixedColumnWidth(60)
                },
                children: [
                  ...drows(),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ITBIS FACTURADO EN SERVICIOS: $taxServices',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        pw.SizedBox(height: 15),
                        pw.Text('ITBIS FACTURADO EN BIENES: $taxGoods',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        pw.SizedBox(height: 15),
                        pw.Text('TOTAL ITBIS FACTURADO: $taxFi',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      ],
                    ),
                    pw.SizedBox(width: 20),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('ITBIS RETENIDO 30%: $taxRetention30',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text('ITBIS RETENIDO 100%: $taxRetention100',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text('TOTAL ITBIS RETENIDO: $taxRetention',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        ]),
                    pw.SizedBox(width: 20),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'ISR RETENIDO (ALQUILERES 10%): $isrRetentionAlq10',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text(
                              'ISR RETENIDO (HONORARIOS POR SERVICIOS 10%): $isrRetentionHon10',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text(
                              'ISR RETENIDO (OTRAS RENTAS 2%): $isrRetentionOt2',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          pw.SizedBox(height: 15),
                          pw.Text('TOTAL ISR RETENIDO: $isrRetention',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        ]),
                  ]),
              pw.SizedBox(height: 15),
              pw.Text('TOTAL DE DOCUMENTOS: $countDocs',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ]; // Center
          });

      document.addPage(pages);

      return {
        'data': data,
        'excelBytes': excel.save(),
        'pdfBytes': await document.save(),
        'footer': {
          'ITBIS EN SERVICIOS': taxServices,
          'ITBIS EN BIENES': taxGoods,
          'TOTAL ITBIS FACTURADO': taxFi,
          'ITBIS RETENIDO 30%': taxRetention30,
          'ITBIS RETENIDO 100%': taxRetention100,
          'TOTAL ITBIS RETENIDO': taxRetention,
          'ISR RETENIDO (ALQUILERES 10%)': isrRetentionAlq10,
          'ISR RETENIDO (HONORARIOS POR SERVICIOS 10%)': isrRetentionHon10,
          'ISR RETENIDO (OTRAS RENTAS 2%)': isrRetentionOt2,
          'TOTAL ISR RETENIDO': isrRetention
        }
      };
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getReportViewByConceptType(
      {String words = '',
      String filterParams = '',
      String targetPath = '',
      String reportName = 'REPORTE FISCAL',
      required DateTime startDate,
      required DateTime endDate,
      required Company company,
      QueryContext queryContext = QueryContext.tax}) async {
    try {
      String id = company.id!;

      String queryContextI = 'and';

      if (queryContext == QueryContext.consumption) {
        queryContextI =
            'and (p."invoice_ncf_typeId" = 2 or p."invoice_ncf_typeId" = 32 or "invoice_ncf_typeId" is null) and';
      } else if (queryContext == QueryContext.tax) {
        queryContextI =
            'and p."invoice_ncf_typeId" != 2 and p."invoice_ncf_typeId" != 32 and not("invoice_ncf_typeId" is null) and';
      }

      var extra = '';

      if (words != '') {
        extra =
            '''("invoice_ck"::text like @searchWord or "invoice_banking_name" like @searchWord or "invoice_author" like @searchWord or "invoice_concept_name" like @searchWord or "invoice_rnc" = @searchWord or "invoice_company_name" like @searchWord or "invoice_rnc" = @searchWord or "invoice_company_name" like @searchWord or "invoice_ncf" like @searchWord or "invoice_ncf_modifed" like @searchWord or "invoice_type_name" like @searchWord) and ''';
      }

      String rangeDatesAsString =
          ''' ("invoice_issue_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}') ''';

      String subParams =
          '''$filterParams "invoice_companyId" = '$id' $queryContextI $extra''';

      String where = '''$subParams $rangeDatesAsString''';

      var result = await connection.runTx((c) async {
        // await c.query('''SET lc_monetary = 'es_US';''');
        var result = await c.mappedResultsQuery('''
              SELECT * FROM (
              SELECT
              "invoice_concept_name" AS "CONCEPTO",
              coalesce(SUM(coalesce(("invoice_total_as_service" + "invoice_total_as_good"),0)), 0)::money::text 
              AS "TOTAL FACTURADO",
              coalesce(SUM(coalesce("invoice_tax",0)),0)::money::text AS "TOTAL ITBIS FACTURADO",
              coalesce(SUM(coalesce(("invoice_total_as_service" + "invoice_total_as_good") - "invoice_tax",0)),0)::money::text AS "TOTAL NETO",
              coalesce(sum(coalesce(debt,0)),0)::money::text AS "DEUDA"
              FROM public."PurchaseDetails" p
              WHERE $where
              GROUP BY "invoice_concept_name"
              UNION ALL
              SELECT 
              'TOTAL GENERAL',
              coalesce(SUM(coalesce(("invoice_total_as_service" + "invoice_total_as_good"),0)),0)::money::text,
              coalesce(SUM(coalesce("invoice_tax",0)),0)::money::text,
              coalesce(SUM(coalesce(("invoice_total_as_service" + "invoice_total_as_good") - "invoice_tax",0)),0)::money::text,
              coalesce(coalesce(sum(debt),0),0)::money::text
              FROM public."PurchaseDetails" p
              WHERE $where
              ) as c
              ORDER BY row_number() over() asc
        ''', substitutionValues: {'searchWord': '%$words%'});
        return result;
      });

      var data = result.map((e) => e['']!).toList();

      var r2 = await connection.mappedResultsQuery(
          '''SELECT COUNT(*) AS "TOTAL DE DOCUMENTOS" FROM public."PurchaseDetails" p WHERE $where''',
          substitutionValues: {'searchWord': '%$words%'});

      var countDocs = r2.first['']?['TOTAL DE DOCUMENTOS'] ?? '0';

      late Excel excel;

      var file = File(targetPath);

      if (!file.existsSync()) {
        excel = Excel.createExcel();
      } else {
        excel = Excel.decodeBytes(await file.readAsBytes());
      }

      var sheetName =
          '$reportName - ${startDate.format(payload: 'YYYY-MM-DD')} - ${endDate.format(payload: 'YYYY-MM-DD')}';

      excel.delete('Sheet1');

      var sheet = excel[sheetName];

      var list = result.map((e) => e['']).toList();

      var item = list[0];

      var keys = item?.keys.toList();

      int endHeaderRowIndex = 3;

      var c =
          sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: 0));

      c.value = TextCellValue(sheetName);

      for (int i = 0; i < keys!.length; i++) {
        var c = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: i, rowIndex: endHeaderRowIndex));
        c.value = TextCellValue(keys[i]);
      }

      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        var values = item?.values.toList();
        for (int j = 0; j < values!.length; j++) {
          var val = values[j];
          var c = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: j, rowIndex: (endHeaderRowIndex + 1) + i));
          c.value = TextCellValue(val ?? '');
        }
      }

      pw.Document document = pw.Document();

      var oneRow =
          data.where((element) => element['CONCEPTO'] == 'TOTAL GENERAL').first;
      var xdata = [...data];

      dhead() {
        return pw.TableRow(
            children: oneRow.keys.map((key) {
          return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      key,
                      style: pw.TextStyle(
                        fontSize: pdfFontSize,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0x0000000),
                      ),
                    ),
                  ]));
        }).toList());
      }

      dheadTwo() {
        return pw.TableRow(
            children: oneRow.values.map((key) {
          return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      key,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0x0000000),
                      ),
                    ),
                  ]));
        }).toList());
      }

      xdata.removeWhere((element) => element['CONCEPTO'] == 'TOTAL GENERAL');

      drows() {
        return xdata.map((item) {
          return pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(
                        color: PdfColor.fromInt(0xA8A8A8), width: 0.3)),
              ),
              children: item.entries.map((entry) {
                return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(entry.value ?? '\$0.00',
                              style: pw.TextStyle(
                                fontSize: pdfFontSize,
                              )),
                        ]));
              }).toList());
        }).toList();
      }

      List<pw.Widget> preCompanyData = [];

      if (company.address != null) {
        preCompanyData.addAll([
          pw.Text('${company.address}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
        ]);
      }

      if (company.email != null) {
        preCompanyData.addAll([
          pw.Text('${company.email}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
        ]);
      }

      var pages = pw.MultiPage(
          pageFormat:
              PdfPageFormat(PdfPageFormat.a4.width, 27.9 * PdfPageFormat.cm),
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(12),
          maxPages: 80,
          header: (ctx) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('${company.name}',
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          ...preCompanyData,
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text('RNC ${formatRncOrId(company.rnc!)}',
                                  style: const pw.TextStyle(fontSize: 10)),
                              company.phone != null
                                  ? pw.Text(',TEL. ${company.phone}',
                                      style: const pw.TextStyle(fontSize: 10))
                                  : pw.SizedBox(),
                            ],
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                              'FECHA DE EMISION ${DateTime.now().format(payload: 'DD/MM/YYYY')}',
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(height: 10),
                          pw.Text(
                              'PERIODOS ${startDate.format(payload: 'DD/MM/YYYY')} - ${endDate.format(payload: 'DD/MM/YYYY')}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(reportName,
                              style: pw.TextStyle(
                                  fontSize: 20, fontWeight: pw.FontWeight.bold))
                        ],
                      )
                    ]),
                pw.SizedBox(height: 20),
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(260),
                    1: const pw.FixedColumnWidth(60),
                    2: const pw.FixedColumnWidth(60),
                    3: const pw.FixedColumnWidth(60),
                    4: const pw.FixedColumnWidth(60),
                    5: const pw.FixedColumnWidth(60),
                    6: const pw.FixedColumnWidth(60),
                    7: const pw.FixedColumnWidth(60)
                  },
                  children: [dheadTwo(), dhead()],
                )
              ],
            );
          },
          build: (pw.Context context) {
            return [
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(260),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FixedColumnWidth(60),
                  5: const pw.FixedColumnWidth(60),
                  6: const pw.FixedColumnWidth(60),
                  7: const pw.FixedColumnWidth(60)
                },
                children: [
                  ...drows(),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Text('TOTAL DE DOCUMENTOS: $countDocs',
                  style:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))
            ]; // Center
          });

      document.addPage(pages);

      return {
        'data': data,
        'excelBytes': excel.save(),
        'pdfBytes': await document.save()
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkIfExists(
      {String id = '',
      String purchaseId = '',
      String startDate = '',
      String endDate = '',
      editing = false}) async {
    try {
      var ncf = invoiceNcf == null ? null : "'$invoiceNcf'";
      var ncfM = invoiceNcfModifed == null
          ? ''
          : '''and "invoice_ncf_modifed" = '$invoiceNcfModifed' ''';

      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM public."Purchase" WHERE "invoice_companyId" = '$id' and "invoice_rnc" = '$invoiceRnc' and ("invoice_ncf" = $ncf $ncfM) and "invoice_issue_date" between '$startDate' and '$endDate';''');

      if (result.isNotEmpty) {
        throw 'YA EXISTE ESTA FACTURA';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfExistsOriginal(
      {required String companyId,
      required DateTime startDate,
      required DateTime endDate}) async {
    try {
      var ncf = invoiceNcf == null ? '' : "'$invoiceNcf'";
      var ncfM = invoiceNcfModifed == null
          ? ''
          : '''and "invoice_ncf_modifed" = '$invoiceNcfModifed' ''';

      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM public."Purchase" WHERE "invoice_companyId" = '$companyId' and "invoice_rnc" = '$invoiceRnc' and ("invoice_ncf" = $ncf $ncfM) and ("invoice_issue_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' or "invoice_pay_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}') ;''');

      if (result.isNotEmpty) {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  String get issueDate {
    return invoiceIssueDate!.format(payload: 'YYYY-MM-DD');
  }

  String? get payDate {
    if (invoicePayDate == null) return null;
    return invoicePayDate!.format(payload: 'YYYY-MM-DD');
  }

  Future<void> create() async {
    try {
      id = const Uuid().v4();
      invoiceCreatedBy = User.current!.id;
      var payContext = payDate != null ? "'$payDate'" : null;
      var ncf = invoiceNcf == null ? null : "'$invoiceNcf'";
      var ncfM = invoiceNcfModifed == null ? null : "'$invoiceNcfModifed'";
      var ckbeneficiary = ckBeneficiary == null ? null : "'$ckBeneficiary'";
      var checkid = checkId == null ? null : "'$checkId'";
      await connection.query('''
             INSERT
             INTO 
             public."Purchase" ("id","totalInForeignCurrency","rate","amountPaid","checkId","ck_beneficiary","invoice_rnc","invoice_conceptId","invoice_companyId","invoice_ncf","invoice_ncf_typeId","invoice_ncf_modifed","invoice_ncfModifed_typeId","invoice_typeId","invoice_ck","invoice_bankingId","invoice_payment_methodId","invoice_tax","invoice_total","invoice_created_by","invoice_retentionId","invoice_tax_retentionId","invoice_tax_con","authorized","invoice_legal_tip_amount","isr_in_purchases","selective_consumption_tax","tax_in_purchases", "other_taxes","invoice_issue_date", "invoice_pay_date") 
             VALUES('$id',$totalInForeignCurrency, $rate, $amountPaid, $checkid, $ckbeneficiary,'$invoiceRnc', $invoiceConceptId, '$invoiceCompanyId', $ncf, $invoiceNcfTypeId, $ncfM, $invoiceNcfModifedTypeId, $invoiceTypeId, $invoiceCk, $invoiceBankingId, $invoicePaymentMethodId, $invoiceTax, $invoiceTotal,'$invoiceCreatedBy',$invoiceRetentionId,$invoiceTaxRetentionId,$invoiceTaxCon,$authorized,$invoiceLegalTipAmount, $invoiceIsrInPurchases, $invoiceSelectiveConsumptionTax, $invoiceTaxInPurchases, $invoiceOthersTaxes, '$issueDate', $payContext);''');
    } catch (e) {
      rethrow;
    }
  }

  Future<Purchase> update() async {
    try {
      String payContext = payDate != null
          ? ''',"invoice_pay_date" = '$payDate','''
          : ''',"invoice_pay_date" =  null,''';

      var ncf = invoiceNcf == null
          ? ''',invoice_ncf = null,'''
          : ''',"invoice_ncf" = '$invoiceNcf',''';
      var ncfM = invoiceNcfModifed == null
          ? ''',invoice_ncf_modifed = null,'''
          : ''',invoice_ncf_modifed = '$invoiceNcfModifed',''';

      var ckbeneficiary = ckBeneficiary == null ? null : "'$ckBeneficiary'";

      var checkid = checkId == null ? null : "'$checkId'";

      await connection.query('''
      UPDATE public."Purchase" SET  "totalInForeignCurrency" = $totalInForeignCurrency, "checkId" = $checkid, "rate" = $rate, "amountPaid" = $amountPaid, "invoice_rnc" = '$invoiceRnc', ck_beneficiary = $ckbeneficiary, "authorized" = $authorized, "invoice_conceptId" = $invoiceConceptId $ncf "invoice_ncf_typeId" = $invoiceNcfTypeId $ncfM "invoice_ncfModifed_typeId" = $invoiceNcfModifedTypeId, "invoice_typeId" = $invoiceTypeId, "invoice_ck" = $invoiceCk, "invoice_bankingId" = $invoiceBankingId, "invoice_payment_methodId" = $invoicePaymentMethodId, "invoice_tax" = $invoiceTax, "invoice_total" = $invoiceTotal, "invoice_created_by" = '${User.current!.id}', "invoice_retentionId" = $invoiceRetentionId, "invoice_tax_retentionId" = $invoiceTaxRetentionId, "invoice_tax_con" = $invoiceTaxCon, "invoice_legal_tip_amount" = $invoiceLegalTipAmount, "isr_in_purchases" = $invoiceIsrInPurchases , "selective_consumption_tax" = $invoiceSelectiveConsumptionTax, "tax_in_purchases" = $invoiceTaxInPurchases, "other_taxes" = $invoiceOthersTaxes, "invoice_issue_date" = '$issueDate' $payContext "created_at" = CURRENT_TIMESTAMP WHERE "id" = '$id';
      ''');

      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM public."PurchaseDetails" WHERE "id" = '$id';''');
      return Purchase.fromMap(result.first['']!);
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

  Future<void> move(String newCompanyId) async {
    try {
      await connection.mappedResultsQuery(
          ''' update public."Purchase" set "invoice_companyId" = '$newCompanyId' where "id"  = '$id'; ''');
    } catch (e) {
      rethrow;
    }
  }

  Purchase copyWith(
      {String? id,
      String? invoiceRnc,
      int? invoiceTypeId,
      int? invoiceBankingId,
      int? invoicePaymentMethodId,
      int? invoiceConceptId,
      int? invoiceRetentionId,
      int? invoiceNcfTypeId,
      int? invoiceNcfModifedTypeId,
      int? invoiceYear,
      int? invoiceMonth,
      String? invoiceNcfDay,
      String? invoiceNcf,
      String? invoiceNcfModifed,
      double? invoiceTax,
      double? invoiceTaxCon,
      double? invoiceTotalAsService,
      double? invoiceTotalAsGood,
      double? invoiceLegalTipAmount,
      double? invoiceIsrInPurchases,
      double? invoiceSelectiveConsumptionTax,
      double? invoiceTaxInPurchases,
      double? invoiceOthersTaxes,
      int? invoiceCk,
      String? invoiceNcfDate,
      String? invoiceSheetId,
      String? invoiceBookId,
      String? invoiceCompanyId,
      String? invoiceCreatedBy,
      String? invoiceTypeName,
      String? invoiceRetentionName,
      String? invoicePaymentMethodName,
      String? invoiceConceptName,
      String? invoiceBankingName,
      DateTime? invoiceIssueDate,
      DateTime? invoicePayDate,
      int? invoiceTaxRetentionId,
      double? amountPaid,
      bool? isCopy}) {
    return Purchase(
        id: id ?? this.id,
        invoiceRnc: invoiceRnc ?? this.invoiceRnc,
        invoiceTypeId: invoiceTypeId ?? this.invoiceTypeId,
        invoiceBankingId: invoiceBankingId ?? this.invoiceBankingId,
        invoicePaymentMethodId:
            invoicePaymentMethodId ?? this.invoicePaymentMethodId,
        invoiceConceptId: invoiceConceptId ?? this.invoiceConceptId,
        invoiceRetentionId: invoiceRetentionId ?? this.invoiceRetentionId,
        invoiceNcfTypeId: invoiceNcfTypeId ?? this.invoiceNcfTypeId,
        invoiceNcfModifedTypeId:
            invoiceNcfModifedTypeId ?? this.invoiceNcfModifedTypeId,
        invoiceYear: invoiceYear ?? this.invoiceYear,
        invoiceMonth: invoiceMonth ?? this.invoiceMonth,
        invoiceNcfDay: invoiceNcfDay ?? this.invoiceNcfDay,
        invoiceNcf: invoiceNcf ?? this.invoiceNcf,
        invoiceNcfModifed: invoiceNcfModifed ?? this.invoiceNcfModifed,
        invoiceTax: invoiceTax ?? this.invoiceTax,
        invoiceTotalAsService:
            invoiceTotalAsService ?? this.invoiceTotalAsService,
        invoiceTotalAsGood: invoiceTotalAsGood ?? this.invoiceTotalAsGood,
        invoiceCk: invoiceCk ?? this.invoiceCk,
        invoiceNcfDate: invoiceNcfDate ?? this.invoiceNcfDate,
        invoiceSheetId: invoiceSheetId ?? this.invoiceSheetId,
        invoiceBookId: invoiceBookId ?? this.invoiceBookId,
        invoiceCompanyId: invoiceCompanyId ?? this.invoiceCompanyId,
        invoiceCreatedBy: invoiceCreatedBy ?? this.invoiceCreatedBy,
        invoiceTypeName: invoiceTypeName ?? this.invoiceTypeName,
        invoiceRetentionName: invoiceRetentionName ?? this.invoiceRetentionName,
        invoicePaymentMethodName:
            invoicePaymentMethodName ?? this.invoicePaymentMethodName,
        invoiceConceptName: invoiceConceptName ?? this.invoiceConceptName,
        invoiceBankingName: invoiceBankingName ?? this.invoiceBankingName,
        invoiceIssueDate: invoiceIssueDate ?? this.invoiceIssueDate,
        invoicePayDate: invoicePayDate ?? this.invoicePayDate,
        invoiceTaxRetentionId:
            invoiceTaxRetentionId ?? this.invoiceTaxRetentionId,
        invoiceTaxCon: invoiceTaxCon ?? this.invoiceTaxCon,
        invoiceLegalTipAmount:
            invoiceLegalTipAmount ?? this.invoiceLegalTipAmount,
        invoiceIsrInPurchases:
            invoiceIsrInPurchases ?? this.invoiceIsrInPurchases,
        invoiceSelectiveConsumptionTax: invoiceSelectiveConsumptionTax ??
            this.invoiceSelectiveConsumptionTax,
        invoiceTaxInPurchases:
            invoiceTaxInPurchases ?? this.invoiceTaxInPurchases,
        invoiceOthersTaxes: invoiceOthersTaxes ?? this.invoiceOthersTaxes,
        amountPaid: amountPaid ?? this.amountPaid,
        isCopy: isCopy ?? this.isCopy);
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    if (invoiceRnc != null) {
      result.addAll({'invoiceRnc': invoiceRnc});
    }
    if (invoiceTypeId != null) {
      result.addAll({'invoiceTypeId': invoiceTypeId});
    }
    if (invoiceBankingId != null) {
      result.addAll({'invoiceBankingId': invoiceBankingId});
    }
    if (invoicePaymentMethodId != null) {
      result.addAll({'invoicePaymentMethodId': invoicePaymentMethodId});
    }
    if (invoiceConceptId != null) {
      result.addAll({'invoiceConceptId': invoiceConceptId});
    }
    if (invoiceRetentionId != null) {
      result.addAll({'invoiceRetentionId': invoiceRetentionId});
    }
    if (invoiceNcfTypeId != null) {
      result.addAll({'invoiceNcfTypeId': invoiceNcfTypeId});
    }
    if (invoiceNcfModifedTypeId != null) {
      result.addAll({'invoiceNcfModifedTypeId': invoiceNcfModifedTypeId});
    }
    if (invoiceYear != null) {
      result.addAll({'invoiceYear': invoiceYear});
    }
    if (invoiceMonth != null) {
      result.addAll({'invoiceMonth': invoiceMonth});
    }
    if (invoiceNcfDay != null) {
      result.addAll({'invoiceNcfDay': invoiceNcfDay});
    }
    if (invoiceNcf != null) {
      result.addAll({'invoiceNcf': invoiceNcf});
    }
    if (invoiceNcfModifed != null) {
      result.addAll({'invoiceNcfModifed': invoiceNcfModifed});
    }
    if (invoiceTax != null) {
      result.addAll({'invoiceTax': invoiceTax});
    }
    if (invoiceTotalAsService != null) {
      result.addAll({'invoiceTotalAsService': invoiceTotalAsService});
    }
    if (invoiceTotalAsGood != null) {
      result.addAll({'invoiceTotalAsGood': invoiceTotalAsGood});
    }
    if (invoiceCk != null) {
      result.addAll({'invoiceCk': invoiceCk});
    }
    if (invoiceNcfDate != null) {
      result.addAll({'invoiceNcfDate': invoiceNcfDate});
    }
    if (invoiceSheetId != null) {
      result.addAll({'invoiceSheetId': invoiceSheetId});
    }
    if (invoiceBookId != null) {
      result.addAll({'invoiceBookId': invoiceBookId});
    }
    if (invoiceCompanyId != null) {
      result.addAll({'invoiceCompanyId': invoiceCompanyId});
    }
    if (invoiceCreatedBy != null) {
      result.addAll({'invoiceCreatedBy': invoiceCreatedBy});
    }
    if (invoiceTypeName != null) {
      result.addAll({'invoiceTypeName': invoiceTypeName});
    }
    if (invoiceRetentionName != null) {
      result.addAll({'invoiceRetentionName': invoiceRetentionName});
    }
    if (invoicePaymentMethodName != null) {
      result.addAll({'invoicePaymentMethodName': invoicePaymentMethodName});
    }
    if (invoiceConceptName != null) {
      result.addAll({'invoiceConceptName': invoiceConceptName});
    }
    if (invoiceBankingName != null) {
      result.addAll({'invoiceBankingName': invoiceBankingName});
    }
    if (isDuplicate != null) {
      result.addAll({'isDuplicate': isDuplicate});
    }

    return result;
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
        id: map['id'],
        isDuplicate: map['isDuplicate'],
        totalInForeignCurrency: double.tryParse(map['totalInForeignCurrency']),
        rate: double.tryParse(map['rate']),
        invoiceRnc: map['invoice_rnc'],
        invoiceTypeId: map['invoice_typeId'],
        invoiceBankingId: map['invoice_bankingId'],
        invoicePaymentMethodId: map['invoice_payment_methodId'],
        invoiceConceptId: map['invoice_conceptId'],
        invoiceRetentionId: map['invoice_retentionId'],
        invoiceNcfTypeId: map['invoice_ncf_typeId'],
        invoiceNcfModifedTypeId: map['invoice_ncfModifed_typeId'],
        invoiceYear: map['invoice_year'],
        invoiceMonth: map['invoice_month'],
        invoiceNcfDay: map['invoice_ncf_day'],
        invoiceNcf: map['invoice_ncf'],
        invoiceNcfModifed: map['invoice_ncf_modifed'],
        invoiceCk: map['invoice_ck'],
        invoiceSheetId: map['invoice_sheetId'],
        invoiceBookId: map['invoice_bookId'],
        invoiceCompanyId: map['invoice_companyId'],
        invoiceCreatedBy: map['invoice_created_by'],
        invoiceTypeName: map['invoice_type_name'],
        invoiceRetentionName: map['invoice_retention_name'],
        invoicePaymentMethodName: map['invoice_payment_method_name'],
        invoiceConceptName: map['invoice_concept_name'],
        invoiceBankingName: map['invoice_banking_name'],
        invoiceCompanyName: map['invoice_company_name'],
        invoiceAuthor: map['invoice_author'],
        invoiceFullNcf: map['invoice_full_ncf'],
        invoiceFullNcfModifed: map['invoice_full_ncf_modifed'],
        invoiceNcfName: map['invoice_ncf_name'],
        invoiceRate: map['invoice_isr_retention_rate'] == null
            ? null
            : int.tryParse(map['invoice_isr_retention_rate']),
        invoiceNcfModifedName: map['invoice_ncf_modifed_name'],
        invoicePayYear: map['invoice_pay_year'],
        invoicePayMonth: map['invoice_pay_month'],
        invoicePayDay: map['invoice_pay_day'],
        invoiceTaxRetentionId: map['invoice_tax_retentionId'],
        invoiceTaxRetentionRate: map['invoice_tax_retention_rate'],
        invoiceTaxRetentionValue:
            double.tryParse(map['invoice_tax_retention_value']),
        invoiceIsrRetentionValue:
            double.tryParse(map['invoice_isr_retention_value']),
        invoiceTotalAsService: double.tryParse(map['invoice_total_as_service']),
        invoiceTotalAsGood: double.tryParse(map['invoice_total_as_good']),
        invoiceTax: double.tryParse(map['invoice_tax']),
        invoiceTotal: double.tryParse(map['invoice_total']),
        invoiceTaxCon: double.tryParse(map['invoice_tax_con']),
        invoiceNetTotal: double.tryParse(map['invoice_net_total']),
        invoiceLegalTipAmount: double.tryParse(map['invoice_legal_tip_amount']),
        invoiceIsrInPurchases: double.tryParse(map['isr_in_purchases']),
        invoiceSelectiveConsumptionTax:
            double.tryParse(map['selective_consumption_tax']),
        invoiceTaxInPurchases: double.tryParse(map['tax_in_purchases']),
        invoiceOthersTaxes: double.tryParse(map['other_taxes']),
        invoiceFinalTax: double.tryParse(map['invoice_final_tax']),
        amountPaid: double.tryParse(map['amountPaid']),
        debt: double.tryParse(map['debt']),
        authorized: map['authorized'],
        invoiceIssueDate: map['invoice_issue_date'],
        invoicePayDate: map['invoice_pay_date'],
        ckBeneficiary: map['ck_beneficiary'],
        createdAt: map['created_at'],
        checkId: map['checkId'],
        bankingModel: map['bankingModel'],
        isCopy: map['isCopy']);
  }

  bool get checkedType {
    return invoiceRnc!.length < 11;
  }

  String get fullDate {
    return DateTime(invoiceYear!, invoiceMonth!).format(payload: 'YYYYMM');
  }

  String get fullNcfDate {
    return DateTime(invoiceYear!, invoiceMonth!, int.parse(invoiceNcfDay!))
        .format(payload: 'YYYYMM');
  }

  String get fullNcfDatek {
    return DateTime(invoiceYear!, invoiceMonth!, int.parse(invoiceNcfDay!))
        .format(payload: 'DD/MM/YYYY');
  }

  String get fullPayDatek {
    if (invoicePayYear == null) return '';
    return DateTime(invoicePayYear!, invoicePayMonth!, invoicePayDay!)
        .format(payload: 'DD/MM/YYYY');
  }

  String get fullPayDate {
    if (invoicePayYear == null) return '';
    return DateTime(invoicePayYear!, invoicePayMonth!, invoicePayDay!)
        .format(payload: 'DD/MM/YYYY');
  }

  String get dfullNcfDate {
    return DateTime(invoiceYear!, invoiceMonth!, int.parse(invoiceNcfDay!))
        .format(payload: 'DD/MM/YYYY');
  }

  String? get dfullPayDate {
    if (invoicePayYear == null ||
        invoicePayMonth == null ||
        invoicePayDay == null) return null;
    return DateTime(invoicePayYear!, invoicePayMonth!, invoicePayDay!)
        .format(payload: 'DD/MM/YYYY');
  }

  static Future<List<Purchase>> get(
      {String companyId = '',
      String searchWord = '',
      bool searchMode = false,
      String filterParams = '',
      required DateTime startDate,
      required DateTime endDate}) async {
    try {
      var searchContext = '';
      if (searchMode) {
        searchContext =
            '''and ("debt"::text like @searchWord or "invoice_ck"::text like @searchWord or "invoice_author" like @searchWord or "invoice_concept_name" like @searchWord or "invoice_banking_name" like @searchWord or "invoice_rnc"::text like @searchWord or "invoice_ncf" like @searchWord or "invoice_ncf_modifed" like @searchWord or "invoice_net_total"::text like @searchWord or "invoice_total"::text like @searchWord or "invoice_tax"::text like @searchWord or "invoice_company_name" like @searchWord or "invoice_type_name" like @searchWord)''';
      }

      var results = await connection.mappedResultsQuery('''
             SELECT * FROM public."PurchaseDetails"
             WHERE
             $filterParams
            "invoice_companyId" = '$companyId' 
             and ("invoice_issue_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}' or "invoice_pay_date" between '${startDate.format(payload: 'YYYY-MM-DD')}' and '${endDate.format(payload: 'YYYY-MM-DD')}') $searchContext order by "invoice_issue_date", "invoice_company_name"''',
          substitutionValues: {
            'searchWord': '%$searchWord%',
          });
      return results.map((row) => Purchase.fromMap(row['']!)).toList();
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
            ''' and (date_label like '%$search%' or date_key like '%$search%') ''';
      }

      var results = await connection.mappedResultsQuery('''
            SELECT DISTINCT * FROM(
            SELECT to_char(invoice_pay_date,'yyyy-mm')
            AS date_label,
            to_char(invoice_pay_date,'yyyymm')
            AS date_key
            FROM public."Purchase" 
            WHERE "invoice_companyId" = '$id'
            UNION
            SELECT to_char(invoice_issue_date,'yyyy-mm')
            AS date_label,
            to_char(invoice_issue_date,'yyyymm')
            AS date_key
            FROM public."Purchase" 
            WHERE "invoice_companyId" = '$id') 
            AS foo
            WHERE date_label is not null
            $searchContext
            GROUP BY date_label, date_key 
            ORDER BY date_label DESC
        ''');

      var list = results.map((e) => e['']!).toList();

      return list;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> to606(DateTime queryDateTime) {
    bool isNotSameMonth = true;
    if (invoicePayDate != null) {
      isNotSameMonth = !(invoicePayDate!.isAtSameMonthAs(queryDateTime));
    }

    return {
      'RNC': invoiceRnc,
      'TYPE ID': checkedType ? 1 : 2,
      'TYPE FACT': DateTime(0, invoiceTypeId!).format(payload: 'MM'),
      'NCF': invoiceNcf,
      'NCF MODIFICADO': invoiceNcfModifed ?? '',
      'FECHA DE COMPROBANTE': invoiceIssueDate!.format(payload: 'YYYYMMDD'),
      'FECHA DE PAGO': isNotSameMonth
          ? ''
          : invoicePayDate != null
              ? invoicePayDate!.format(payload: 'YYYYMMDD')
              : '',
      'TOTAL COMO SERVICIOS': invoiceTotalAsService == 0
          ? '0.00'
          : (invoiceTotalAsService! -
                  invoiceTax! -
                  invoiceLegalTipAmount! -
                  invoiceSelectiveConsumptionTax! -
                  invoiceOthersTaxes!)
              .abs()
              .toStringAsFixed(2),
      'TOTAL COMO BIENES': invoiceTotalAsGood == 0
          ? '0.00'
          : (invoiceTotalAsGood! -
                  invoiceTax! -
                  invoiceLegalTipAmount! -
                  invoiceSelectiveConsumptionTax! -
                  invoiceOthersTaxes!)
              .abs()
              .toStringAsFixed(2),
      'TOTAL FACTURADO': (invoiceNetTotal)?.abs().toStringAsFixed(2),
      'ITBIS FACTURADO': invoiceTax?.abs().toStringAsFixed(2),
      'ITBIS RETENIDO': isNotSameMonth
          ? '0.00'
          : invoiceTaxRetentionValue?.abs().toStringAsFixed(2),
      'y': '',
      'ITBIS LLEVADO AL COSTO': invoiceTaxCon?.abs().toStringAsFixed(2),
      'ITBIS POR ADELANTAR': invoiceFinalTax?.abs().toStringAsFixed(2),
      '1': '',
      'TIPO DE RETENCION ISR': isNotSameMonth
          ? ''
          : invoiceRetentionId != null
              ? DateTime(0, invoiceRetentionId!).format(payload: 'MM')
              : '',
      'MONTO DE RETENCION ISR': isNotSameMonth
          ? ''
          : invoiceIsrRetentionValue?.abs().toStringAsFixed(2),
      '3': invoiceIsrInPurchases?.abs().toStringAsFixed(2),
      '4': invoiceSelectiveConsumptionTax?.abs().toStringAsFixed(2),
      '5': invoiceOthersTaxes?.abs().toStringAsFixed(2),
      'MONTO PROPINA LEGAL': invoiceLegalTipAmount?.abs().toStringAsFixed(2),
      'METODO DE PAGO':
          DateTime(0, invoicePaymentMethodId!).format(payload: 'MM'),
    };
  }

  String get author {
    return invoiceAuthor ?? 'DESCONOCIDO';
  }

  Map<String, dynamic> toDisplay() {
    return {
      'EDITOR': author,
      'RNC/CEDULA': invoiceRnc,
      'PROVEEDOR': invoiceCompanyName ?? 'DESCONOCIDA',
      'CONCEPTO': invoiceConceptName,
      'TIPO DE FACTURA': invoiceTypeName,
      'NCF': invoiceNcf ?? 'S/N',
      'NCF MODIFICADO': invoiceNcfModifed != '' && invoiceNcfModifed != null
          ? invoiceNcfModifed
          : 'S/N',
      'FECHA DE COMPROBANTE': invoiceIssueDate!.format(payload: 'DD/MM/YYYY'),
      'FECHA DE PAGO': invoicePayDate != null
          ? invoicePayDate!.format(payload: 'DD/MM/YYYY')
          : 'S/N',
      'BANCO/ENTIDAD/NUM/BEN': bankingModel ?? 'S/N',
      'METODO DE PAGO': invoicePaymentMethodName,
      'TOTAL COMO SERVICIOS': invoiceTotalAsService?.toStringAsFixed(2),
      'TOTAL COMO BIENES': invoiceTotalAsGood?.toStringAsFixed(2),
      'TOTAL FACTURADO': invoiceTotal?.toStringAsFixed(2),
      'ITBIS FACTURADO': invoiceTax?.toStringAsFixed(2),
      'IMPUS. SELEC. AL CONSUMO':
          invoiceSelectiveConsumptionTax?.toStringAsFixed(2),
      'OTROS IMPUESTOS': invoiceOthersTaxes?.toStringAsFixed(2),
      'MONTO PROPINA LEGAL': invoiceLegalTipAmount?.toStringAsFixed(2),
      'TOTAL NETO': invoiceNetTotal?.toStringAsFixed(2),
      'ITBIS RETENIDO': invoiceTaxRetentionValue?.toStringAsFixed(2),
      'ITBIS LLEVADO AL COSTO': invoiceTaxCon?.toStringAsFixed(2),
      'ITBIS POR ADELANTAR': invoiceFinalTax?.toStringAsFixed(2),
      'NOMBRE DE RETENCION': invoiceRetentionName ?? 'S/N',
      'ISR RETENIDO': invoiceIsrRetentionValue?.toStringAsFixed(2),
      'ISR EN COMPRAS': invoiceIsrInPurchases?.toStringAsFixed(2),
      'ITBIS EN COMPRAS': invoiceTaxInPurchases?.toStringAsFixed(2),
      'MONTO PAGADO': amountPaid?.toStringAsFixed(2),
      'DEUDA': debt?.toStringAsFixed(2)
    };
  }

  String toJson() => json.encode(toMap());

  factory Purchase.fromJson(String source) =>
      Purchase.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Purchase(id: $id, invoiceRnc: $invoiceRnc, invoiceTypeId: $invoiceTypeId, invoiceBankingId: $invoiceBankingId, invoicePaymentMethodId: $invoicePaymentMethodId, invoiceConceptId: $invoiceConceptId, invoiceRetentionId: $invoiceRetentionId, invoiceNcfTypeId: $invoiceNcfTypeId, invoiceNcfModifedTypeId: $invoiceNcfModifedTypeId, invoiceYear: $invoiceYear, invoiceMonth: $invoiceMonth, invoiceNcfDay: $invoiceNcfDay, invoiceNcf: $invoiceNcf, invoiceNcfModifed: $invoiceNcfModifed, invoiceTax: $invoiceTax, invoiceTotalAsService: $invoiceTotalAsService, invoiceTotalAsGood: $invoiceTotalAsGood, invoiceCk: $invoiceCk, invoiceNcfDate: $invoiceNcfDate, invoiceSheetId: $invoiceSheetId, invoiceBookId: $invoiceBookId, invoiceCompanyId: $invoiceCompanyId, invoiceCreatedBy: $invoiceCreatedBy, invoiceTypeName: $invoiceTypeName, invoiceRetentionName: $invoiceRetentionName, invoicePaymentMethodName: $invoicePaymentMethodName, invoiceConceptName: $invoiceConceptName, invoiceBankingName: $invoiceBankingName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Purchase &&
        other.id == id &&
        other.invoiceRnc == invoiceRnc &&
        other.invoiceTypeId == invoiceTypeId &&
        other.invoiceBankingId == invoiceBankingId &&
        other.invoicePaymentMethodId == invoicePaymentMethodId &&
        other.invoiceConceptId == invoiceConceptId &&
        other.invoiceRetentionId == invoiceRetentionId &&
        other.invoiceNcfTypeId == invoiceNcfTypeId &&
        other.invoiceNcfModifedTypeId == invoiceNcfModifedTypeId &&
        other.invoiceYear == invoiceYear &&
        other.invoiceMonth == invoiceMonth &&
        other.invoiceNcfDay == invoiceNcfDay &&
        other.invoiceNcf == invoiceNcf &&
        other.invoiceNcfModifed == invoiceNcfModifed &&
        other.invoiceTax == invoiceTax &&
        other.invoiceTotalAsService == invoiceTotalAsService &&
        other.invoiceTotalAsGood == invoiceTotalAsGood &&
        other.invoiceCk == invoiceCk &&
        other.invoiceNcfDate == invoiceNcfDate &&
        other.invoiceSheetId == invoiceSheetId &&
        other.invoiceBookId == invoiceBookId &&
        other.invoiceCompanyId == invoiceCompanyId &&
        other.invoiceCreatedBy == invoiceCreatedBy &&
        other.invoiceTypeName == invoiceTypeName &&
        other.invoiceRetentionName == invoiceRetentionName &&
        other.invoicePaymentMethodName == invoicePaymentMethodName &&
        other.invoiceConceptName == invoiceConceptName &&
        other.invoiceBankingName == invoiceBankingName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        invoiceRnc.hashCode ^
        invoiceTypeId.hashCode ^
        invoiceBankingId.hashCode ^
        invoicePaymentMethodId.hashCode ^
        invoiceConceptId.hashCode ^
        invoiceRetentionId.hashCode ^
        invoiceNcfTypeId.hashCode ^
        invoiceNcfModifedTypeId.hashCode ^
        invoiceYear.hashCode ^
        invoiceMonth.hashCode ^
        invoiceNcfDay.hashCode ^
        invoiceNcf.hashCode ^
        invoiceNcfModifed.hashCode ^
        invoiceTax.hashCode ^
        invoiceTotalAsService.hashCode ^
        invoiceTotalAsGood.hashCode ^
        invoiceCk.hashCode ^
        invoiceNcfDate.hashCode ^
        invoiceSheetId.hashCode ^
        invoiceBookId.hashCode ^
        invoiceCompanyId.hashCode ^
        invoiceCreatedBy.hashCode ^
        invoiceTypeName.hashCode ^
        invoiceRetentionName.hashCode ^
        invoicePaymentMethodName.hashCode ^
        invoiceConceptName.hashCode ^
        invoiceBankingName.hashCode;
  }
}
