import 'dart:io';

import 'package:flutter/services.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uresaxapp/controllers/session.controller.dart';

List<String> months = [
  'ENERO',
  'FEBRERO',
  'MARZO',
  'ABRIL',
  'MAYO',
  'JUNIO',
  'JULIO',
  'AGOSTO',
  'SEPTIEMBRE',
  'OCTUBRE',
  'NOVIEMBRE',
  'DICIEMBRE'
];

enum FormType { form606, form607, form608 }

enum ReportType { month, year }

enum QueryContext { general, tax, consumption }

enum AuthorizationType { authorized, notAuthorized }

enum ReportModelType {
  invoiceType,
  conceptType,
  companyName,
  typeIncome,
  imports
}

List<Map<String, dynamic>> reportTypes = [
  {'type': ReportModelType.invoiceType, 'name': 'REPORTE POR TIPO DE FACTURA'},
  {'type': ReportModelType.conceptType, 'name': 'REPORTE POR CONCEPTO'},
  {'type': ReportModelType.companyName, 'name': 'REPORTE POR PROVEEDOR'},
  {'type': ReportModelType.imports, 'name': 'IMPORTACIONES'}
];

List<Map<String, dynamic>> reportTypes607 = [
  {'type': ReportModelType.typeIncome, 'name': 'REPORTE POR TIPO DE INGRESO'},
  {'type': ReportModelType.conceptType, 'name': 'REPORTE POR CONCEPTO'},
  {'type': ReportModelType.companyName, 'name': 'REPORTE POR CLIENTE'}
];
List<Map<String, dynamic>> ncfsTypes = [
  {'TIPO': QueryContext.general, 'NAME': 'REPORTE GENERAL'},
  {'TIPO': QueryContext.tax, 'NAME': 'FACTURAS FISCALES'},
  {'TIPO': QueryContext.consumption, 'NAME': 'FACTURAS DE CONSUMO'}
];

var myformatter = NumberTextInputFormatter(
  integerDigits: 10,
  decimalDigits: 2,
  maxValue: '1000000000.00',
  decimalSeparator: '.',
  groupDigits: 3,
  groupSeparator: ',',
  allowNegative: false,
  overrideDecimalPoint: true,
  insertDecimalPoint: false,
  insertDecimalDigits: true,
);

var pointFormatter = NumberTextInputFormatter(
  integerDigits: 10,
  decimalDigits: 2,
  maxValue: '1000000000.00',
  decimalSeparator: '.',
  groupDigits: 3,
  groupSeparator: ',',
  allowNegative: true,
  overrideDecimalPoint: true,
  insertDecimalPoint: false,
  insertDecimalDigits: true,
);

String execPointFormatter(dynamic value) {
  return pointFormatter
      .formatEditUpdate(
          TextEditingValue.empty, TextEditingValue(text: value.toString()))
      .text;
}

late SessionController sessionController;

 PackageInfo? packageInfo;


  var hostName = Platform.environment['DATABASE_HOSTNAME'];
  var dbPort = Platform.environment['DATABASE_PORT'];
  var dbName = Platform.environment['DATABASE_NAME'];
  var dbUsername = Platform.environment['DATABASE_USERNAME'];
  var dbSecret = Platform.environment['DATABASE_SECRET'];
  var dirUresaxPath = Platform.environment['URESAX_STATIC_LOCAL_SERVER_PATH'];
  bool enabledConceptByTypeContext =bool.parse( Platform.environment['URESAX_ENABLED_CONCEPT_BY_TYPECONTEXT'] ?? 'false');