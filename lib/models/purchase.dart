import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uuid/uuid.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:string_mask/string_mask.dart';

var formatter = StringMask('#.###.00');

enum ReportType { month, year }

enum QueryContext { general, tax, consumption }

class ReportViewModel {
  String title;

  List<Map<String, dynamic>?> body;

  String taxServices;

  String taxGood;

  String totalTax;

  String totalGeneral;

  Map<String, dynamic> footer;

  RangeLabels? rangeLabels;

  RangeValues? rangeValues;

  pw.Document? pdf;

  Book? book;

  int? start = 1;

  int? end = 12;

  String totalNcfs;

  ReportViewModel(
      {required this.body,
      this.footer = const {},
      this.title = '',
      this.rangeLabels,
      this.rangeValues,
      this.book,
      this.start,
      this.end,
      this.pdf,
      this.totalNcfs = '0',
      this.taxServices = '\$0.00',
      this.totalGeneral = '\$0.00',
      this.totalTax = '\$0.00',
      this.taxGood = '\$0.00'});
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
  String? invoiceTaxRetentionValue;
  String? invoiceIsrRetentionValue;
  String? invoiceTotal;
  String? invoiceNetTotal;
  DateTime? createdAt;

  Purchase(
      {this.id,
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
      this.createdAt});

  static Future<ReportViewModel> getReportViewByInvoiceType(
      {String id = '',
      int start = 1,
      int end = 12,
      reportType = ReportType.month,
      QueryContext queryContext = QueryContext.tax}) async {
    String where = '';
    String queryContextI = 'and';

    if (queryContext == QueryContext.consumption) {
      queryContextI =
          'and (p."invoice_ncf_typeId" = 2 or p."invoice_ncf_typeId" = 32) and';
    } else if (queryContext == QueryContext.tax) {
      queryContextI =
          'and p."invoice_ncf_typeId" != 2 and p."invoice_ncf_typeId" != 32 and';
    }

    if (reportType == ReportType.month) {
      where =
          '''(p."invoice_sheetId" = '$id' OR p."invoice_bookId" = '$id') $queryContextI p."invoice_month" between $start and $end''';
    } else {
      where =
          '''p."invoice_companyId" = '$id' $queryContextI p."invoice_year" between $start and $end''';
    }

    try {
      await connection.query('''SET lc_monetary = 'es_US';''');

      await connection.query('''
        CREATE OR REPLACE VIEW public."ReportViewForInvoiceType"
        AS
        SELECT 
        p."invoice_typeId" AS "TIPO",
        p.invoice_type_name AS "NOMBRE",
        sum(p.invoice_total_as_service)::text AS "TOTAL EN SERVICIOS",
        sum(p.invoice_total_as_good)::text AS "TOTAL EN BIENES",
        sum(p.invoice_tax)::text AS "TOTAL ITBIS FACTURADO",
        sum(p.invoice_tax_retention_value::numeric(10,2))::text AS "ITBIS RETENIDO",
        sum(p.invoice_isr_retention_value::numeric(10,2))::text AS "ISR RETENIDO"
        FROM "PurchaseDetails" p
        WHERE $where
        GROUP BY p."invoice_typeId",p.invoice_type_name
        ORDER BY p."invoice_typeId", p."invoice_type_name"
      ''');
      var r1 = await connection.mappedResultsQuery('''
          SELECT
          COALESCE("NOMBRE", 'TOTAL GENERAL') AS "NOMBRE",
          SUM("TOTAL EN SERVICIOS"::numeric(10,2))::money::text AS "TOTAL EN SERVICIOS",
          SUM("TOTAL EN BIENES"::numeric(10,2))::money::text AS "TOTAL EN BIENES",
          SUM("TOTAL EN BIENES"::numeric(10,2) + "TOTAL EN SERVICIOS"::numeric(10,2))::money::text AS "TOTAL FACTURADO",
          SUM("TOTAL ITBIS FACTURADO"::numeric(10,2))::money::text AS "TOTAL ITBIS FACTURADO",
          SUM(("TOTAL EN BIENES"::numeric(10,2) + "TOTAL EN SERVICIOS"::numeric(10,2)) - "TOTAL ITBIS FACTURADO"::numeric(10,2))::money::text AS "TOTAL NETO",
          SUM("ITBIS RETENIDO"::numeric(10,2))::money::text AS "ITBIS RETENIDO",
          SUM("ISR RETENIDO"::numeric(10,2))::money::text AS "ISR RETENIDO"
          FROM public."ReportViewForInvoiceType"
          GROUP BY GROUPING SETS (("TIPO","NOMBRE"), ())
          ORDER BY "TIPO"
          ''');

      var r3 = await connection.mappedResultsQuery('''
           SELECT trunc(sum(p.invoice_tax),2)::money::text AS "ITBIS FACTURADO EN BIENES" FROM public."PurchaseDetails" p WHERE $where and (p."invoice_typeId" = 9 or p."invoice_typeId" = 8 or p."invoice_typeId" = 10)
      ''');

      var r4 = await connection.mappedResultsQuery('''
           SELECT trunc(sum(p.invoice_tax),2)::money::text AS "ITBIS FACTURADO EN SERVICIOS" FROM public."PurchaseDetails" p WHERE $where and (p."invoice_typeId" != 9 and p."invoice_typeId" != 8 and p."invoice_typeId" != 10)''');

      var r5 = await connection.mappedResultsQuery(
          '''SELECT COUNT(*) AS "TOTAL DE DOCUMENTOS" FROM public."PurchaseDetails" p WHERE $where''');

      var body = r1.map((e) => e['']).toList();

      var t3 = r3.first['']?['ITBIS FACTURADO EN BIENES'] ?? '\$0.00';

      var t4 = r4.first['']?['ITBIS FACTURADO EN SERVICIOS'] ?? '\$0.00';

      var t5 = r5.first['']?['TOTAL DE DOCUMENTOS'] ?? '0';

      return ReportViewModel(
          body: body,
          start: start,
          end: end,
          taxGood: t3,
          totalNcfs: t5.toString(),
          taxServices: t4);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> dispose() async {
    await connection.query('''DROP VIEW public."ReportViewForInvoiceType";''');
  }

  Future<void> checkIfExistsPurchase() async {
    try {
      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM "Purchase" WHERE "invoice_sheetId" = '$invoiceSheetId' and "invoice_rnc" = '$invoiceRnc' and ("invoice_ncf" = '$invoiceNcf' AND "invoice_ncf_modifed" = '$invoiceNcfModifed');''');
      if (result.isNotEmpty) {
        throw 'YA EXISTE ESTA COMPRA EN ESTA HOJA';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Purchase> create() async {
    try {
      id = const Uuid().v4();

      invoiceCreatedBy = User.current!.id;

      await connection.query(
          '''INSERT INTO public."Purchase" ("id","invoice_rnc","invoice_conceptId","invoice_sheetId","invoice_bookId","invoice_companyId","invoice_ncf","invoice_ncf_typeId","invoice_ncf_modifed","invoice_ncfModifed_typeId","invoice_typeId","invoice_ck","invoice_bankingId","invoice_payment_methodId","invoice_ncf_day","invoice_tax","invoice_total_as_service","invoice_total_as_good","invoice_created_by","invoice_retentionId","invoice_year","invoice_month","invoice_pay_year","invoice_pay_month","invoice_pay_day","invoice_tax_retentionId") VALUES('$id','$invoiceRnc',$invoiceConceptId,'$invoiceSheetId','$invoiceBookId','$invoiceCompanyId','$invoiceNcf', $invoiceNcfTypeId, '$invoiceNcfModifed', $invoiceNcfModifedTypeId, $invoiceTypeId, $invoiceCk, $invoiceBankingId, $invoicePaymentMethodId,'$invoiceNcfDay', $invoiceTax, $invoiceTotalAsService, $invoiceTotalAsGood,'$invoiceCreatedBy',$invoiceRetentionId,$invoiceYear,$invoiceMonth,$invoicePayYear,$invoicePayMonth,$invoicePayDay,$invoiceTaxRetentionId);''');
      var result = await connection.mappedResultsQuery(
          '''SELECT * FROM public."PurchaseDetails" WHERE id = '$id';''');

      return Purchase.fromMap(result.first['']!);
    } catch (e) {
      rethrow;
    }
  }

  Future<Purchase> update() async {
    try {
      await connection.query('''
      UPDATE public."Purchase" SET "invoice_rnc" = '$invoiceRnc', "invoice_conceptId" = $invoiceConceptId, "invoice_ncf" = '$invoiceNcf', "invoice_ncf_typeId" = $invoiceNcfTypeId, "invoice_ncf_modifed" = '$invoiceNcfModifed', "invoice_ncfModifed_typeId" = $invoiceNcfModifedTypeId, "invoice_typeId" = $invoiceTypeId, "invoice_ck" = $invoiceCk, "invoice_bankingId" = $invoiceBankingId, "invoice_payment_methodId" = $invoicePaymentMethodId, "invoice_ncf_day" = '$invoiceNcfDay', "invoice_tax" = $invoiceTax, "invoice_total_as_service" = $invoiceTotalAsService, "invoice_total_as_good" = $invoiceTotalAsGood, "invoice_created_by" = '${User.current!.id}', "invoice_retentionId" = $invoiceRetentionId, "invoice_year" = $invoiceYear, "invoice_month" = $invoiceMonth, "invoice_pay_year" = $invoicePayYear, "invoice_pay_month" = $invoicePayMonth, "invoice_pay_day" = $invoicePayDay, "invoice_tax_retentionId" = $invoiceTaxRetentionId WHERE "id" = '$id';
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

  Purchase copyWith({
    String? id,
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
    double? invoiceTotalAsService,
    double? invoiceTotalAsGood,
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
  }) {
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
    );
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

    return result;
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
        id: map['id'],
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
        invoiceTax: double.tryParse(map['invoice_tax']) ?? 0,
        invoiceTotalAsService:
            double.tryParse(map['invoice_total_as_service']) ?? 0,
        invoiceTotalAsGood: double.tryParse(map['invoice_total_as_good']) ?? 0,
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
        invoiceTaxRetentionValue: map['invoice_tax_retention_value'],
        invoiceIsrRetentionValue: map['invoice_isr_retention_value'],
        invoiceTotal: map['invoice_total'],
        invoiceNetTotal: map['invoice_net_total'],
        createdAt: map['created_at']);
  }

  bool get checkedType {
    return invoiceRnc!.length < 11;
  }

  String get fullDate {
    return Moment.fromDate(DateTime(invoiceYear!, invoiceMonth!))
        .format('yyyyMM');
  }

  String get fullNcfDate {
    return Moment.fromDate(
            DateTime(invoiceYear!, invoiceMonth!, int.parse(invoiceNcfDay!)))
        .format('yyyyMMdd');
  }

  String get fullNcfDatek {
    return Moment.fromDate(
            DateTime(invoiceYear!, invoiceMonth!, int.parse(invoiceNcfDay!)))
        .format('dd/MM/yyyy');
  }

  String get fullPayDatek {
    if (invoicePayYear == null) return '';
    return Moment.fromDate(
            DateTime(invoicePayYear!, invoicePayMonth!, invoicePayDay!))
        .format('dd/MM/yyyy');
  }

  String get fullPayDate {
    if (invoicePayYear == null) return '';
    return Moment.fromDate(
            DateTime(invoicePayYear!, invoicePayMonth!, invoicePayDay!))
        .format('yyyyMMdd');
  }

  String get dfullNcfDate {
    return Moment.fromDate(
            DateTime(invoiceYear!, invoiceMonth!, int.parse(invoiceNcfDay!)))
        .format('dd/MM/yyyy');
  }

  String? get dfullPayDate {
    if (invoicePayYear == null) return null;
    return Moment.fromDate(
            DateTime(invoicePayYear!, invoicePayMonth!, invoicePayDay!))
        .format('dd/MM/yyyy');
  }

  Map<String, dynamic> to606() {
    return {
      'RNC': invoiceRnc,
      'TYPEID': checkedType ? 1 : 2,
      'TYPE FACT': Moment.fromDate(DateTime(0, invoiceTypeId!)).format('MM'),
      'NCF': invoiceNcf,
      'NCF MODIFICADO': invoiceNcfModifed ?? '',
      'FECHA DE COMPROBANTE': fullNcfDate,
      'FECHA DE PAGO': fullPayDate,
      'TOTAL COMO SERVICIOS': invoiceTotalAsService?.abs().toStringAsFixed(2),
      'TOTAL COMO BIENES': invoiceTotalAsGood?.abs().toStringAsFixed(2),
      'TOTAL FACTURADO':
          double.tryParse(invoiceTotal!)?.abs().toStringAsFixed(2),
      'ITBIS FACTURADO': invoiceTax?.abs().toStringAsFixed(2),
      'ITBIS RETENIDO':
          double.tryParse(invoiceTaxRetentionValue!)?.abs().toStringAsFixed(2),
      'y': '',
      'a': '',
      'ITBIS POR ADELANTAR': invoiceTax?.abs().toStringAsFixed(2),
      '1': '',
      'TIPO DE RETENCION ISR': invoiceRetentionId == null
          ? ''
          : Moment.fromDate(DateTime(0, invoiceRetentionId!)).format('MM'),
      'MONTO DE RETENCION ISR':
          double.tryParse(invoiceIsrRetentionValue!)?.abs().toString(),
      '3': '',
      '4': '',
      '5': '',
      '6': '',
      'METODO DE PAGO':
          Moment.fromDate(DateTime(0, invoicePaymentMethodId!)).format('MM'),
    };
  }

  Map<String, dynamic> to606Display() {
    return {
      'RNC': invoiceRnc,
      'TYPEID': checkedType ? 1 : 2,
      'TYPE FACT': invoiceTypeName,
      'NCF': invoiceNcf,
      'NCF MODIFICADO': invoiceNcfModifed ?? '',
      'FECHA DE COMPROBANTE': fullNcfDatek,
      'FECHA DE PAGO': fullPayDatek,
      'TOTAL COMO SERVICIOS': invoiceTotalAsService?.toStringAsFixed(2),
      'TOTAL COMO BIENES': invoiceTotalAsGood?.toStringAsFixed(2),
      'TOTAL FACTURADO': double.tryParse(invoiceTotal!)?.toStringAsFixed(2),
      'ITBIS FACTURADO': invoiceTax?.toStringAsFixed(2),
      'ITBIS RETENIDO':
          double.tryParse(invoiceTaxRetentionValue!)?.toStringAsFixed(2),
      'y': 0,
      'a': 0,
      'ITBIS POR ADELANTAR': invoiceTax?.toStringAsFixed(2),
      '1': 0,
      'TIPO DE RETENCION ISR': invoiceRetentionName ?? '',
      'MONTO DE RETENCION ISR':
          double.tryParse(invoiceIsrRetentionValue!)?.toStringAsFixed(2),
      '3': 0,
      '4': 0,
      '5': 0,
      '6': 0,
      'METODO DE PAGO': invoicePaymentMethodName,
    };
  }

  String get author {
    return invoiceAuthor ?? 'DESCONOCIDO';
  }

  Map<String, dynamic> toDisplay() {
    return {
      'AUTOR': author,
      'RNC': invoiceRnc,
      'EMPRESA': invoiceCompanyName ?? 'DESCONOCIDA',
      'CONCEPTO': invoiceConceptName,
      'TIPO DE FACTURA': invoiceTypeName,
      'NCF': invoiceNcf,
      'NCF MODIFICADO': invoiceNcfModifed ?? 'NINGUNO',
      'FECHA DE COMPROBANTE': dfullNcfDate,
      'FECHA DE PAGO': dfullPayDate ?? 'NINGUNO',
      'BANCO': invoiceBankingName ?? 'NINGUNO',
      'NUMERO DE CHEQUE': invoiceCk ?? 'NINGUNO',
      'METODO DE PAGO': invoicePaymentMethodName,
      'TOTAL COMO SERVICIOS': invoiceTotalAsService?.toStringAsFixed(2),
      'TOTAL COMO BIENES': invoiceTotalAsGood?.toStringAsFixed(2),
      'TOTAL FACTURADO': invoiceTotal,
      'ITBIS FACTURADO': invoiceTax?.toStringAsFixed(2),
      'TOTAL NETO': invoiceNetTotal,
      'ITBIS RETENIDO': invoiceTaxRetentionValue,
      'NOMBRE DE RETENCION': invoiceRetentionName ?? 'NINGUNO',
      'ISR RETENIDO': invoiceIsrRetentionValue,
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
