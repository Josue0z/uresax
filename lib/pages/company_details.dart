// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:html/parser.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/apis/keyboard.handler.dart';
import 'package:uresaxapp/controllers/ncfs.override.controller.dart';
import 'package:uresaxapp/controllers/periods.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/controllers/ready.company.details.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/controllers/session.controller.dart';
import 'package:uresaxapp/modals/add-concept-modal.dart';
import 'package:uresaxapp/modals/add-purchase-modal.dart';
import 'package:uresaxapp/modals/add.ncf.override.modal.dart';
import 'package:uresaxapp/modals/add.sale.modal.dart';
import 'package:uresaxapp/modals/document.modal.type.income.dart';
import 'package:uresaxapp/modals/filter.modal.dart';
import 'package:uresaxapp/modals/ncf.sale.selector.modal.dart';
import 'package:uresaxapp/modals/purchase.mini.editor.modal.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/invoice.type.context.dart';
import 'package:uresaxapp/models/invoicetype.dart';
import 'package:uresaxapp/models/ncf.override.model.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:uresaxapp/models/payment-method.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:path/path.dart' as path;
import 'package:uresaxapp/models/type.of.income.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/imports_page.dart';
import 'package:uresaxapp/pages/periods.page.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/company.selector.widget.dart';
import 'package:uresaxapp/widgets/custom.floating-action.button.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

String hostname = Platform.environment['DATABASE_HOSTNAME'] ?? '';

String hostport = Platform.environment['HOST_PORT'] ?? '';

String wsUrl = 'ws://$hostname:$hostport/ws';

class CompanyDetailsPage extends StatefulWidget {
  Company company;

  DateTime startDate;

  DateTime endDate;

  FormType formType;

  int currentIdValue = 0;

  int currentVisibleId = 0;

  late CompanyDetailsController controller2;

  Map<String, dynamic>? metadata;

  TextEditingController get date {
    return controller2.date;
  }

  String get startDateLargeAsString {
    return startDate.format(payload: 'YYYY-MM-DD');
  }

  String get endDateLargeAsString {
    return endDate.format(payload: 'YYYY-MM-DD');
  }

  String get startDateNormalAsString {
    return startDate.format(payload: 'DD/MM/YYYY');
  }

  String get endDateNormalAsString {
    return endDate.format(payload: 'DD/MM/YYYY');
  }

  String get startDateAsString {
    return startDate.format(payload: 'DD-MM-YYYY');
  }

  String get endDateAsString {
    return endDate.format(payload: 'DD-MM-YYYY');
  }

  String get titleFormType {
    if (formType == FormType.form606) {
      return 'COMPRAS Y GASTOS';
    }
    if (formType == FormType.form607) {
      return 'VENTAS';
    }
    if (formType == FormType.form608) {
      return 'NCFS ANULADOS';
    }
    return '';
  }

  String get title {
    return '${company.name!} / RNC ${company.rnc} - $titleFormType';
  }

  String get dateRangeAsString {
    return '$startDateNormalAsString - $endDateNormalAsString';
  }

  String get startDatePeriod {
    return startDate.format(payload: 'YYYYMM');
  }

  String get endDatePeriod {
    return endDate.format(payload: 'YYYYMM');
  }

  String get yearPeriod {
    return startDate.format(payload: 'YYYY');
  }

  String get dirRootPath {
    return path.join(dirUresaxPath ?? '',
        'URESAX', company.name?.trim(), yearPeriod);
  }

  String get rootPath {
    return path.join(dirUresaxPath ?? '',
        'URESAX', company.name?.trim(), yearPeriod, formatType);
  }

  String get formatType {
    if (formType == FormType.form606) {
      return '606';
    }

    if (formType == FormType.form607) {
      return '607';
    }

    if (formType == FormType.form608) {
      return '608';
    }
    return '';
  }

  String get fileName {
    return path.join(
        rootPath, 'DGII_F_${formatType}_${company.rnc}_$startDatePeriod');
  }

  String get filePath {
    return '$fileName.TXT';
  }

  String get dirPath {
    return path.dirname(filePath);
  }

  CompanyDetailsPage(
      {super.key,
      this.formType = FormType.form606,
      required this.startDate,
      required this.endDate,
      required this.company,
      this.metadata});

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  DateTimeRange? myDateRange;

  late pw.Document pdf;

  late PurchasesController controllerPurchases;

  late SalesController controllerSales;

  late NcfsOverrideController ncfsOverrideController;

  late SessionController sessionController;

  TextEditingController searchWord = TextEditingController();

  String filterStatus = '';

  bool isOpenDialog = false;

  BuildContext? contextDialog;

  final KeyboardLayoutChanger _keyboardLayoutChanger = KeyboardLayoutChanger();

  @override
  initState() {
    if (!mounted) return;
    if (Platform.isWindows) {
      _keyboardLayoutChanger.changeKeyboardLayout('en');
    }
    super.initState();
  }

  String get filterStatusx {
    if (formType == FormType.form606 && filterStatus.isEmpty) {
      filterStatus = 'authorized = true and';
    }
    return filterStatus;
  }

  Future<void> searchNcf(String url) async {
    var dio = Dio(BaseOptions(
        responseType: ResponseType.plain,
        followRedirects: true,
        maxRedirects: 5,
        headers: {
          'Content-Type': 'text/html; charset=utf-8',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59'
        }));
    dio.interceptors.add(CookieManager(CookieJar()));

    showLoader(context);
    try {
      var isUrl = url.contains('ecf.dgii.gov.do');

      if (!isUrl) throw 'LA URL NO ES VALIDA';

      var providerName = '';

      var rncProvider = '';

      var rncClient = '';

      var ncf = '';

      var date = '';

      var total = '';

      var tax = '';

      var list = [];

      var res = await dio.get(url.trim());

      if (res.statusCode == 200) {
        var document = parse(res.data);

        var table = document.querySelector('table');

        var msg = table?.text.trim();

        if (msg != null &&
            msg.contains('No fue encontrada la factura (e-CF).')) {
          throw 'LA FACTURA NO FUE ENCONTRADA';
        }
        var tbody = document.querySelector('tbody');

        if (tbody != null) {
          for (int i = 0; i < tbody.nodes.length; i++) {
            var node = tbody.nodes[i];
            var l = node.children.length;
            if (l != 0) {
              var e = node.children[1];

              list.add(e.innerHtml.trim());
            }
          }
        } else {
          throw 'EL CUERPO NO EXISTE';
        }

        if (list.isEmpty) {
          throw 'NO SE ENCONTRARON DATOS EN LA PAGINA';
        }

        rncProvider = list[0];
        providerName = list[1];

        rncClient = list[2];
        ncf = list[4];
        date = list[5];
        tax = list[6];
        total = list[7];

        if (rncClient.trim() != widget.company.rnc?.trim()) {
          throw 'ESTE COMPROBANTE NO PERTENECE A ESTE CONTRIBUYENTE';
        }

        var xx = date.split('-');
        var d = int.parse(xx[0]);
        var m = int.parse(xx[1]);
        var y = int.parse(xx[2]);

        var dateTime = DateTime(y, m, d);

        var tt = double.parse(total.replaceAll(',', ''));
        var tx = double.tryParse(tax.replaceAll(',', '')) ?? 0;

        var type = ncf.substring(1, 3).trim();

        int ncfTypeId = 31;

        bool isNcfModifed = true;

        if (type == '31') {
          ncfTypeId = 31;
          isNcfModifed = false;
        }

        if (type == '34') {
          ncfTypeId = 34;
        }

        if (type == '33') {
          ncfTypeId = 33;
        }

        var concepts = [
          Concept(name: 'CONCEPTO'),
          ...await Concept.getConcepts()
        ];
        var invoiceTypes = [
          InvoiceType(name: 'TIPO DE FACTURA'),
          ...await InvoiceType.getInvoiceTypes()
        ];
        var paymentsMethods = [
          PaymentMethod(name: 'METODO DE PAGO'),
          ...await PaymentMethod.getPaymentMethods()
        ];

        var ncfs = [
          NcfType(name: 'NCF MODIFICADO'),
          ...await NcfType.getNcfs()
        ];

        NcfType? ncfType = ncfs.where((ncf) => ncf.id == 31).first;
        Navigator.pop(context);

        if (contextDialog != null) {
          Navigator.pop(contextDialog!);
          contextDialog = null;
        }
        var startDate = dateTime.startOfMonth();
        var endDate = dateTime.endOfMonth();

        var xres = await showDialog(
            context: context,
            builder: (ctx) {
              contextDialog = ctx;
              return PurchaseMinEditorModal(
                  concepts: concepts,
                  invoiceTypes: invoiceTypes,
                  paymentsMethods: paymentsMethods,
                  ncfModifed: TextEditingController(),
                  ncfs: ncfs,
                  providerName: providerName,
                  invoiceRnc: rncProvider,
                  ncf: ncf,
                  currentNcfModifedTypeId: ncfType.id,
                  currentNcfModifedType: ncfType,
                  isNcfModifed: isNcfModifed,
                  startDate: startDate.format(payload: 'YYYY-MM-DD'),
                  endDate: endDate.format(payload: 'YYYY-MM-DD'),
                  companyDetailsPage: widget);
            });

        contextDialog = null;

        if (xres != null) {
          var conceptId = xres[0];
          var invoiceTypeId = xres[1];
          var paymentMethodId = xres[2];
          var ncfModifed = xres[3] as String?;

          var purchase = Purchase(
              invoiceRnc: rncProvider,
              totalInForeignCurrency: 0,
              invoiceTotal: tt,
              invoiceTax: tx,
              invoiceTaxCon: 0,
              invoiceLegalTipAmount: 0,
              invoiceSelectiveConsumptionTax: 0,
              invoiceIsrInPurchases: 0,
              invoiceTaxInPurchases: 0,
              invoiceOthersTaxes: 0,
              rate: 0,
              amountPaid: tt,
              invoiceTypeId: invoiceTypeId,
              invoicePaymentMethodId: paymentMethodId,
              invoiceConceptId: conceptId,
              invoiceNcf: ncf,
              invoiceNcfModifed: ncfModifed,
              invoiceNcfTypeId: ncfTypeId,
              invoiceNcfModifedTypeId: ncfModifed != null ? ncfType.id : null,
              invoiceIssueDate: dateTime,
              invoiceCreatedBy: User.current?.id,
              invoiceCompanyId: widget.company.id,
              authorized: true);

          showLoader(context);

          widget.startDate = startDate;
          widget.endDate = endDate;

          await purchase.create();

          widget.date.value = TextEditingValue(
              text:
                  '${widget.startDateNormalAsString} - ${widget.endDateNormalAsString}');

          await storage.write(
              key: "STARTDATE_${widget.company.id}",
              value: widget.startDateLargeAsString);

          await storage.write(
              key: "ENDDATE_${widget.company.id}",
              value: widget.endDateLargeAsString);

          controllerPurchases.purchases.value = await Purchase.get(
              companyId: widget.company.id ?? '',
              startDate: widget.startDate,
              endDate: widget.endDate);

          Navigator.pop(context);

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('FACTURA AÑADIDA')));

          setState(() {});
        }
      }
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
    return;
  }

  @override
  dispose() {
    controllerPurchases.onClose();
    controllerSales.onClose();
    ncfsOverrideController.onClose();
    super.dispose();
  }

  _exportData() async {
    try {
      if (formType == FormType.form606) {
        _export606Data();
      }
      if (formType == FormType.form607) {
        _export607Data();
      }
      if (formType == FormType.form608) {
        _export608Data();
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _importData() async {
    try {
      if (formType == FormType.form606) {
        _import606Data();
      }
      if (formType == FormType.form607) {
        _import607Data();
      }
      if (formType == FormType.form608) {
        _import608Data();
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _export606Data() async {
    showLoader(context);
    try {
      if (purchases.isEmpty) {
        throw 'NO TIENES FACTURAS';
      }

      if (isMultiplyPeriod) {
        throw 'NO SE PUEDE GENERAR UN ARCHIVO DE EXPORTACION PARA MULTIPLES PERIODOS';
      }

      var xpurchases = await Purchase.getOriginal(
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

    
      var result = xpurchases.map((e) => e.toMapOriginal()).toList();

    

      var newExportFile = File(path.join(
          widget.dirRootPath,
          widget.formatType,
          'EXPORTS',
          'EXPORT_${widget.company.name!}_${widget.company.rnc}_${widget.startDatePeriod}.JSON'));

      await newExportFile.create(recursive: true);

      await newExportFile.writeAsString(jsonEncode(result));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('ARCHIVO DE EXPORTACION DE DATOS GENERADO'),
        action: SnackBarAction(
            label: 'ABRIR ARCHIVO',
            onPressed: () async {
              await launchFile(path.dirname(newExportFile.path));
            }),
      ));

      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _export607Data() async {
    showLoader(context);
    try {
      if (controllerSales.sales.isEmpty) {
        throw 'NO TIENES FACTURAS';
      }

      if (isMultiplyPeriod) {
        throw 'NO SE PUEDE GENERAR UN ARCHIVO DE EXPORTACION PARA MULTIPLES PERIODOS';
      }

      var xsales = await Sale.getOriginal(
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      var result = xsales.map((e) => e.toMap()).toList();

      var newExportFile = File(path.join(
          widget.dirRootPath,
          widget.formatType,
          'EXPORTS',
          'EXPORT_${widget.company.name!}_${widget.company.rnc}_${widget.startDatePeriod}.JSON'));

      await newExportFile.create(recursive: true);

      await newExportFile.writeAsString(jsonEncode(result));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('ARCHIVO DE EXPORTACION DE DATOS GENERADO'),
        action: SnackBarAction(
            label: 'ABRIR ARCHIVO',
            onPressed: () async {
              await launchFile(path.dirname(newExportFile.path));
            }),
      ));

      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _export608Data() async {
    showLoader(context);
    try {
      if (ncfsOverrideController.ncfsOverrides.isEmpty) {
        throw 'NO TIENES FACTURAS';
      }

      if (isMultiplyPeriod) {
        throw 'NO SE PUEDE GENERAR UN ARCHIVO DE EXPORTACION PARA MULTIPLES PERIODOS';
      }

      var xncfsOverride = await NcfOverrideModel.get(
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      var result = xncfsOverride.map((e) {
        var m = e.toMap();
        m.remove('authorId');
        m.remove('authorName');
        m.remove('typeOfOverrideName');
        m.remove('ncfDateDisplay');
        return m;
      }).toList();

      var newExportFile = File(path.join(
          widget.dirRootPath,
          widget.formatType,
          'EXPORTS',
          'EXPORT_${widget.company.name!}_${widget.company.rnc}_${widget.startDatePeriod}.JSON'));

      await newExportFile.create(recursive: true);

      await newExportFile.writeAsString(jsonEncode(result));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('ARCHIVO DE EXPORTACION DE DATOS GENERADO'),
        action: SnackBarAction(
            label: 'ABRIR ARCHIVO',
            onPressed: () async {
              await launchFile(path.dirname(newExportFile.path));
            }),
      ));

      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _import606Data() async {
    try {
      if (isMultiplyPeriod) {
        throw 'NO SE PUEDE IMPORTAR UN ARCHIVO DE EXPORTACION PARA UN RANGO DE FECHA MULTIPLE';
      }
      var filePicker = FilePicker.platform;
      var result = await filePicker.pickFiles(
          initialDirectory:
              path.join(widget.dirRootPath, widget.formatType, 'EXPORTS'),
          type: FileType.custom,
          allowedExtensions: ['json']);

      if (result != null) {
        showLoader(context);
        var file = result.files[0];

        var xcurrentFile = File(file.path!);
        var xfileValues = await xcurrentFile.readAsString();
        var jsonData = jsonDecode(xfileValues);

        var fileName = path.basenameWithoutExtension(xcurrentFile.path);

        var parts = fileName.split('_');
        var p = parts[2];
        var p1 = parts[3];

        if (widget.company.rnc != p && widget.startDatePeriod != p1) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTA EMPRESA Y TAMBIEN EL PERIODO NO ES VALIDO';
        }

        if (widget.company.rnc != p) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTA EMPRESA';
        }

        if (widget.startDatePeriod != p1) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTE PERIODO';
        }

        for (var item in jsonData) {
          var xp = Purchase.fromMapOriginal({
            ...item,
            'invoice_companyId': widget.company.id,
            'invoice_created_by': User.current!.id
          });
          var exists = await xp.checkIfExistsOriginal(
              companyId: widget.company.id!,
              startDate: widget.startDate,
              endDate: widget.endDate);

          if (exists) {
            print('no agregar');
          } else {
            await xp.create();
          }
        }
        controllerPurchases.purchases.value = await Purchase.get(
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);

        Navigator.pop(context);
      }
    } catch (e) {
      if (!isMultiplyPeriod) {
        Navigator.pop(context);
      }
      showAlert(context, message: e.toString());
    }
  }

  _import607Data() async {
    try {
      if (isMultiplyPeriod) {
        throw 'NO SE PUEDE IMPORTAR UN ARCHIVO DE EXPORTACION PARA UN RANGO DE FECHA MULTIPLE';
      }
      var filePicker = FilePicker.platform;
      var result = await filePicker.pickFiles(
          type: FileType.custom,
          initialDirectory:
              path.join(widget.dirRootPath, widget.formatType, 'EXPORTS'),
          allowedExtensions: ['json']);

      if (result != null) {
        showLoader(context);
        var file = result.files[0];

        var xcurrentFile = File(file.path!);
        var xfileValues = await xcurrentFile.readAsString();
        var jsonData = jsonDecode(xfileValues);

        var fileName = path.basenameWithoutExtension(xcurrentFile.path);

        var parts = fileName.split('_');
        var p = parts[2];
        var p1 = parts[3];

        if (widget.company.rnc != p && widget.startDatePeriod != p1) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTA EMPRESA Y TAMBIEN EL PERIODO NO ES VALIDO';
        }

        if (widget.company.rnc != p) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTA EMPRESA';
        }

        if (widget.startDatePeriod != p1) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTE PERIODO';
        }

        for (var item in jsonData) {
          var xsa = Sale.fromMapOriginal({
            ...item,
            'companyId': widget.company.id,
            'authorId': User.current!.id
          });

          var exists = await xsa.checkIfExistsOriginal(
              companyId: widget.company.id!,
              startDate: widget.startDate,
              endDate: widget.endDate);

          if (exists) {
            print('no agregar');
          } else {
            await xsa.create();
          }
        }
        controllerSales.sales.value = await Sale.get(
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);

        Navigator.pop(context);
      }
    } catch (e) {
      if (!isMultiplyPeriod) {
        Navigator.pop(context);
      }
      showAlert(context, message: e.toString());
    }
  }

  _import608Data() async {
    try {
      if (isMultiplyPeriod) {
        throw 'NO SE PUEDE IMPORTAR UN ARCHIVO DE EXPORTACION PARA UN RANGO DE FECHA MULTIPLE';
      }

      var filePicker = FilePicker.platform;
      var result = await filePicker.pickFiles(
          type: FileType.custom,
          initialDirectory:
              path.join(widget.dirRootPath, widget.formatType, 'EXPORTS'),
          allowedExtensions: ['json']);

      if (result != null) {
        showLoader(context);
        var file = result.files[0];

        var xcurrentFile = File(file.path!);
        var xfileValues = await xcurrentFile.readAsString();
        var jsonData = jsonDecode(xfileValues);

        var fileName = path.basenameWithoutExtension(xcurrentFile.path);

        var parts = fileName.split('_');
        var p = parts[2];
        var p1 = parts[3];

        if (widget.company.rnc != p && widget.startDatePeriod != p1) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTA EMPRESA Y TAMBIEN EL PERIODO NO ES VALIDO';
        }

        if (widget.company.rnc != p) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTA EMPRESA';
        }

        if (widget.startDatePeriod != p1) {
          throw 'EL ARCHIVO DE EXPORTACION NO PERTENECE A ESTE PERIODO';
        }

        for (var item in jsonData) {
          var xncfOverride = NcfOverrideModel.fromMap({
            ...item,
            'companyId': widget.company.id,
            'authorId': User.current!.id
          });

          var exists = await xncfOverride.checkIfExists(
              companyId: widget.company.id!,
              startDate: widget.startDate,
              endDate: widget.endDate);

          if (exists) {
            print('no agregar');
          } else {
            print('agregar');
            await xncfOverride.create();
          }
        }
        ncfsOverrideController.ncfsOverrides.value = await NcfOverrideModel.get(
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);
        Navigator.pop(context);
      }
    } catch (e) {
      if (!isMultiplyPeriod) {
        Navigator.pop(context);
      }
      showAlert(context, message: e.toString());
    }
  }

  _showConceptModal() async {
    showLoader(context);
    try {
      var concepts = await Concept.getConcepts();
      List<InvoiceTypeContext> invoiceTypesContext =[];
    if(enabledConceptByTypeContext){
      invoiceTypesContext  = await InvoiceTypeContext.get();
    }
      Navigator.pop(context);

      await showDialog(
          context: context,
          builder: (ctx) => AddConceptModal(
              concepts: concepts, invoiceTypesContext: invoiceTypesContext));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _generateXlsx() async {
    if (formType == FormType.form606) {
      _generateXlsx606();
    }

    if (formType == FormType.form607) {
      _generateXlsx607();
    }
  }

  _generateXlsx606() async {
    showLoader(context);
    try {
      await createXls();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL REPORTE XLSX'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                launchFile(widget.dirPath);
              })));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _generateXlsx607() async {
    showLoader(context);
    try {
      await Sale.createXlsx(
          id: company.id!,
          sheetName: (widget.startDate.month - 1).toString(),
          startDate: widget.startDate,
          endDate: widget.endDate,
          targetPath: path
              .join(widget.rootPath,
                  '${company.name?.trim()} ${widget.yearPeriod}.xlsx')
              .trim());

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL REPORTE XLSX'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                launchFile(widget.dirPath);
              })));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _generateForm() {
    if (formType == FormType.form606) {
      _generate606();
    }

    if (formType == FormType.form607) {
      _generate607();
    }

    if (formType == FormType.form608) {
      _generate608();
    }
  }

  _generate606() async {
    showLoader(context);

    try {
      var purchases = await Purchase.get(
          companyId: company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      purchases.removeWhere((element) =>
          element.invoiceNcfTypeId == 2 ||
          element.invoiceNcfTypeId == 32 ||
          element.invoiceNcfTypeId == null ||
          element.authorized == false);

      var elements = purchases.map((e) => e.to606(widget.startDate)).toList();

      if (purchases.isEmpty) {
        throw 'NO TIENES FACTURAS';
      }

      if (isMultiplyPeriod) {
        throw 'NO PUEDES GENERAR EL 606 PARA MULTIPLES PERIODOS';
      }

      List<List<dynamic>> rows = [];

      for (int i = 0; i < elements.length; i++) {
        var item = elements[i];
        var values = item.values.toList();
        rows.add(values);
      }

      var result = const ListToCsvConverter().convert([
        [606, company.rnc, widget.startDatePeriod, purchases.length],
        ...rows
      ], fieldDelimiter: '|');

      var file = File(widget.filePath.trim());

      await file.create(recursive: true);

      await file.writeAsString(result);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL 606 (TXT, XLSX)'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                launchFile(widget.dirPath);
              })));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _generate607() async {
    showLoader(context);

    try {
      var sales = await Sale.get(
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      sales.removeWhere((element) =>
          element.invoiceNcfTypeId == 2 || element.invoiceNcfTypeId == 32);

      var elements = sales.map((e) => e.to607(widget.startDate)).toList();

      if (sales.isEmpty) {
        throw 'NO TIENES FACTURAS';
      }

      if (isMultiplyPeriod) {
        throw 'NO PUEDES GENERAR EL 607 PARA MULTIPLES PERIODOS';
      }

      List<List<dynamic>> rows = [];

      for (int i = 0; i < elements.length; i++) {
        var item = elements[i];
        var values = item.values.toList();
        rows.add(values);
      }

      var result = const ListToCsvConverter().convert([
        [607, company.rnc, widget.startDatePeriod, sales.length],
        ...rows
      ], fieldDelimiter: '|');

      var file = File(widget.filePath.trim());

      await file.create(recursive: true);

      await file.writeAsString(result);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL 607'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                launchFile(widget.dirPath);
              })));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _generate608() async {
    showLoader(context);

    try {
      var ncfsOverrides = await NcfOverrideModel.get(
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      var elements = ncfsOverrides.map((e) => e.to608()).toList();

      if (ncfsOverrides.isEmpty) {
        throw 'NO TIENES FACTURAS';
      }

      if (isMultiplyPeriod) {
        throw 'NO PUEDES GENERAR EL 608 PARA MULTIPLES PERIODOS';
      }

      List<List<dynamic>> rows = [];

      for (int i = 0; i < elements.length; i++) {
        var item = elements[i];
        var values = item.values.toList();
        rows.add(values);
      }

      var result = const ListToCsvConverter().convert([
        [608, company.rnc, widget.startDatePeriod, ncfsOverrides.length],
        ...rows
      ], fieldDelimiter: '|');

      var file = File(widget.filePath.trim());

      await file.create(recursive: true);

      await file.writeAsString(result);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL 608'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                launchFile(widget.dirPath);
              })));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _openFolder() async {
    try {
      await launchFile(widget.dirPath);
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  fetchPurchases() async {
    controllerPurchases.purchases.value = await Purchase.get(
        companyId: company.id!,
        startDate: widget.startDate,
        endDate: widget.endDate);
  }

  _getPurchaseContext({bool isEditing = false, Purchase? purchase}) async {
    return await showDialog(
        context: context,
        builder: (ctx) => AddPurchaseModal(
            widget: widget,
            startDateLargeAsString: widget.startDate.toString(),
            startDate: widget.startDate,
            purchase: purchase,
            isEditing: isEditing,
            metadata: widget.metadata!));
  }

  _showModalContext() {
    if (formType == FormType.form606) {
      _showModalPurchase();
    }
    if (formType == FormType.form607) {
      _showModalSale();
    }
    if (formType == FormType.form608) {
      _showModalNcfOverride();
    }
  }

  _showModalPurchase() async {
    try {
      var result = await _getPurchaseContext();

      if (result == 'INSERT') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SE INSERTO LA FACTURA')));
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _selectInvoice(Purchase purchase) async {
    try {
      var result =
          await _getPurchaseContext(isEditing: true, purchase: purchase);
      if (result is String) {
        if (result == 'DELETE') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE ELIMINO LA FACTURA')));
        }

        if (result == 'UPDATE') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE ACTUALIZO LA FACTURA')));
        }
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _selectSale(Sale sale) async {
    showLoader(context);
    try {
      var ncfs = [
        NcfType(name: 'TIPO DE COMPROBANTE'),
        ...(await NcfType.getNcfs())
      ];
      var typeOfIncomes = [
        TypeOfIncome(name: 'TIPO DE INGRESO'),
        ...(await TypeOfIncome.get())
      ];
      var concepts = [
        Concept(name: 'CONCEPTO'),
        ...(await Concept.getConcepts())
      ];
      Get.back();
      var result = await showDialog(
          context: context,
          builder: (ctx) => AddSaleModal(
              companyDetailsPage: widget,
              isEditing: true,
              sale: sale,
              ncfs: ncfs,
              typeOfIncomes: typeOfIncomes,
              concepts: concepts));
      if (result is String) {
        if (result == 'DELETE') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE ELIMINO LA FACTURA')));
        }
        if (result == 'UPDATE') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE ACTUALIZO LA FACTURA')));
        }
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _selectNcfOverride(NcfOverrideModel ncfOverride) async {
    try {
      var result = await showDialog(
          context: context,
          builder: (ctx) => NcfOverrideModal(
              companyDetailsPage: widget,
              isEditing: true,
              ncfOverrideModel: ncfOverride));
      if (result is String) {
        if (result == 'DELETE') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('SE ELIMINO EL COMPROBANTE ANULADO')));
        }
        if (result == 'UPDATE') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('SE ACTUALIZO EL COMPROBANTE ANULADO')));
        }
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _showModalSale() async {
    showLoader(context);
    try {
      var ncfs = [
        NcfType(name: 'TIPO DE COMPROBANTE'),
        ...(await NcfType.getNcfs())
      ];
      var typeOfIncomes = [
        TypeOfIncome(name: 'TIPO DE INGRESO'),
        ...(await TypeOfIncome.get())
      ];
      var concepts = [
        Concept(name: 'CONCEPTO'),
        ...(await Concept.getConcepts())
      ];

      Get.back();
      var result = await showDialog<String?>(
          context: context,
          builder: (ctx) => AddSaleModal(
              companyDetailsPage: widget,
              ncfs: ncfs,
              typeOfIncomes: typeOfIncomes,
              concepts: concepts));

      if (result is String) {
        if (result == 'INSERT') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE INSERTO LA FACTURA')));
        }
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _showModalNcfOverride() async {
    var result = await showDialog<String?>(
        context: context,
        builder: (ctx) => NcfOverrideModal(companyDetailsPage: widget));

    if (result is String) {
      if (result == 'INSERT') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('SE INSERTO EL COMPRODBANTE ANULADO')));
      }
    }
  }

  Future<void> createXls() async {
    try {
      await Purchase.createXls(
          id: company.id!,
          sheetName: (widget.startDate.month - 1).toString(),
          startDate: widget.startDate,
          endDate: widget.endDate,
          targetPath: path
              .join(widget.rootPath,
                  '${company.name?.trim()} ${widget.yearPeriod}.xlsx')
              .trim());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _preloadReportDataForInvoiceType() async {
    generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
      showLoader(context);
      try {
        var data = reportViewModel['data'];

        var isEmpty = data.length == 1;

        if (isEmpty) {
          throw 'NO TIENES DATOS QUE GENERAR';
        }

        if (data.length > 1) {
          var file = File('$filePath.XLSX');

          await file.create(recursive: true);

          await file.writeAsBytes(reportViewModel['excelBytes']);

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('SE GENERO EL REPORTE XLSX - $title'),
              action: SnackBarAction(
                  label: 'ABRIR ARCHIVO',
                  onPressed: () async {
                    await launchFile(file.path);
                  })));
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    generatePdf(
        reportViewModel, title, customTitle, filePath, reportName, dir) async {
      showLoader(context);
      try {
        var data = reportViewModel['data'];

        var isEmpty = data.length == 1;

        if (isEmpty) {
          throw 'NO TIENES DATOS QUE GENERAR';
        }

        var fileName =
            '$customTitle $reportName - ${company.name?.trim()} - ${widget.startDate.format(payload: 'YYYY-MM-DD')} - ${widget.endDate.format(payload: 'YYYY-MM-DD')}.PDF';
        var file = File(path.join(dir, fileName));
        await file.create(recursive: true);

        await file.writeAsBytes(reportViewModel['pdfBytes']);

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('SE GENERO EL REPORTE PDF - $title'),
            action: SnackBarAction(
                label: 'ABRIR ARCHIVO',
                onPressed: () async {
                  await launchFile(file.path);
                })));
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    onUpdate(String filePath, DocumentModal parent, String reportName,
        QueryContext queryContext) async {
      showLoader(context);
      try {
        parent.reportViewModel = await Purchase.getReportViewByInvoiceType(
            company: company,
            words: searchWord.text,
            filterParams: filterStatusx,
            startDate: widget.startDate,
            endDate: widget.endDate,
            reportName: reportName,
            targetPath: '$filePath.XLSX',
            queryContext: queryContext);
        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);
        showAlert(context, message: e.toString());
      }
    }

    showLoader(context);

    try {
      var result = await Purchase.getReportViewByInvoiceType(
          company: company,
          words: searchWord.text,
          filterParams: filterStatusx,
          startDate: widget.startDate,
          endDate: widget.endDate);

      Navigator.pop(context);

      Get.to(() => DocumentModal(
          context: context,
          customTitle: 'REPORTE POR TIPO DE FACTURA - ',
          generateXlsx: generateXlsx,
          generatePdf: generatePdf,
          onUpdate: onUpdate,
          companyDetailsPage: widget,
          reportViewModel: result));
    } catch (e) {
      Navigator.pop(context);
      await showAlert(context, message: e.toString());
    }
  }

  Future<void> _preloadReportDataForConceptType() async {
    generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
      showLoader(context);
      try {
        var data = reportViewModel['data'];

        var isEmpty = data.length == 1;

        if (isEmpty) {
          throw 'NO TIENES DATOS QUE GENERAR';
        }

        if (data.length > 1) {
          var file = File('$filePath.XLSX');

          await file.create(recursive: true);

          await file.writeAsBytes(reportViewModel['excelBytes']);

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('SE GENERO EL REPORTE XLSX - $title'),
              action: SnackBarAction(
                  label: 'ABRIR ARCHIVO',
                  onPressed: () async {
                    await launchFile(file.path);
                  })));
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    generatePdf(
        reportViewModel, title, customTitle, filePath, reportName, dir) async {
      showLoader(context);
      try {
        var data = reportViewModel['data'];

        var isEmpty = data.length == 1;

        if (isEmpty) {
          throw 'NO TIENES DATOS QUE GENERAR';
        }

        if (data.length > 1) {
          var fileName =
              '$customTitle $reportName - ${company.name?.trim()} - ${widget.startDate.format(payload: 'YYYY-MM-DD')} - ${widget.endDate.format(payload: 'YYYY-MM-DD')}.PDF';
          var file = File(path.join(dir, fileName));

          await file.create(recursive: true);

          await file.writeAsBytes(reportViewModel['pdfBytes']);

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('SE GENERO EL REPORTE PDF - $title'),
              action: SnackBarAction(
                  label: 'ABRIR ARCHIVO',
                  onPressed: () async {
                    await launchFile(file.path);
                  })));
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    onUpdate(String filePath, DocumentModal parent, String reportName,
        QueryContext queryContext) async {
      showLoader(context);
      try {
        parent.reportViewModel = await Purchase.getReportViewByConceptType(
            company: company,
            words: searchWord.text,
            filterParams: filterStatusx,
            startDate: widget.startDate,
            endDate: widget.endDate,
            reportName: reportName,
            targetPath: '$filePath.XLSX',
            queryContext: queryContext);
        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);
        showAlert(context, message: e.toString());
      }
    }

    showLoader(context);

    try {
      var result = await Purchase.getReportViewByConceptType(
          company: company,
          words: searchWord.text,
          filterParams: filterStatusx,
          startDate: widget.startDate,
          endDate: widget.endDate);

      Navigator.pop(context);

      Get.to(() => DocumentModal(
          context: context,
          customTitle: 'REPORTE POR CONCEPTO - ',
          generateXlsx: generateXlsx,
          generatePdf: generatePdf,
          onUpdate: onUpdate,
          companyDetailsPage: widget,
          reportViewModel: result));
    } catch (e) {
      Navigator.pop(context);
      await showAlert(context, message: e.toString());
    }
  }

  Future<void> _preloadReportDataForCompanyName() async {
    showLoader(context);
    try {
      var result = await Purchase.getReportViewByCompanyName(
          company: company,
          words: searchWord.text,
          filterParams: filterStatusx,
          startDate: widget.startDate,
          endDate: widget.endDate);

      generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
        showLoader(context);
        try {
          var data = reportViewModel['data'];

          var isEmpty = data.length == 1;

          if (isEmpty) {
            throw 'NO TIENES DATOS QUE GENERAR';
          }

          if (data.length > 1) {
            var file = File('$filePath.XLSX');

            await file.create(recursive: true);

            await file.writeAsBytes(reportViewModel['excelBytes']);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('SE GENERO EL REPORTE XLSX - $customTitle - $title'),
                action: SnackBarAction(
                    label: 'ABRIR ARCHIVO',
                    onPressed: () async {
                      await launchFile(file.path);
                    })));
          }
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }

      onUpdate(String filePath, DocumentModal parent, String reportName,
          QueryContext queryContext) async {
        showLoader(context);
        try {
          parent.reportViewModel = await Purchase.getReportViewByCompanyName(
              company: company,
              startDate: widget.startDate,
              endDate: widget.endDate,
              reportName: reportName,
              targetPath: '$filePath.XLSX',
              words: searchWord.text,
              filterParams: filterStatusx,
              queryContext: queryContext);
          Navigator.pop(context);
        } catch (e) {
          Navigator.pop(context);
          showAlert(context, message: e.toString());
        }
      }

      generatePdf(reportViewModel, title, customTitle, filePath, reportName,
          dir) async {
        showLoader(context);
        try {
          var data = reportViewModel['data'];

          var isEmpty = data.length == 1;

          if (isEmpty) {
            throw 'NO TIENES DATOS QUE GENERAR';
          }

          if (data.length > 1) {
            var fileName =
                '$customTitle $reportName - ${company.name?.trim()} - ${widget.startDate.format(payload: 'YYYY-MM-DD')} - ${widget.endDate.format(payload: 'YYYY-MM-DD')}.PDF';
            var file = File(path.join(dir, fileName));

            await file.create(recursive: true);

            await file.writeAsBytes(reportViewModel['pdfBytes']);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('SE GENERO EL REPORTE PDF - $title'),
                action: SnackBarAction(
                    label: 'ABRIR ARCHIVO',
                    onPressed: () async {
                      await launchFile(file.path);
                    })));
          }
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }

      Navigator.pop(context);

      Get.to(() => DocumentModal(
          context: context,
          customTitle: 'REPORTE POR PROVEEDOR - ',
          companyDetailsPage: widget,
          reportViewModel: result,
          generateXlsx: generateXlsx,
          generatePdf: generatePdf,
          onUpdate: onUpdate));
    } catch (e) {
      Navigator.pop(context);
      await showAlert(context, message: e.toString());
    }
  }

  _preloadReportDataByTypeIncome() async {
    showLoader(context);

    generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
      showLoader(context);
      try {
        var data = reportViewModel['data'];

        var isEmpty = data.length == 1;

        if (isEmpty) {
          throw 'NO TIENES DATOS QUE GENERAR';
        }

        var file = File('$filePath.XLSX');

        await file.create(recursive: true);

        await file.writeAsBytes(reportViewModel['excelBytes']);

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('SE GENERO EL REPORTE XLSX - $title'),
            action: SnackBarAction(
                label: 'ABRIR ARCHIVO',
                onPressed: () async {
                  await launchFile(file.path);
                })));
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    onUpdate(String filePath, DocumentModal parent, String reportName,
        QueryContext queryContext) async {
      showLoader(context);
      try {
        parent.reportViewModel = await Sale.getReportViewByTypeIncome(
            company: widget.company,
            startDate: widget.startDate,
            endDate: widget.endDate,
            reportName: reportName,
            targetPath: '$filePath.XLSX',
            filterParams: filterStatus,
            words: searchWord.text,
            queryContext: queryContext);
        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);
        showAlert(context, message: e.toString());
      }
    }

    try {
      var result = await Sale.getReportViewByTypeIncome(
          words: searchWord.text,
          company: widget.company,
          filterParams: filterStatus,
          startDate: widget.startDate,
          endDate: widget.endDate);

      Navigator.pop(context);

      Get.to(() => DocumentModal(
          context: context,
          customTitle: 'REPORTE POR TIPO DE INGRESO - ',
          formatType: '607',
          companyDetailsPage: widget,
          reportViewModel: result,
          generateXlsx: generateXlsx,
          onUpdate: onUpdate));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _preloadReportDataByConcept() async {
    try {
      var result = await Sale.getReportViewByConcept(
          words: searchWord.text,
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate,
          filterParams: filterStatus);

      generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
        showLoader(context);
        try {
          var data = reportViewModel['data'];

          var isEmpty = data.length == 1;

          if (isEmpty) {
            throw 'NO TIENES DATOS QUE GENERAR';
          }

          var file = File('$filePath.XLSX');

          await file.create(recursive: true);

          await file.writeAsBytes(reportViewModel['excelBytes']);

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('SE GENERO EL REPORTE XLSX - $title'),
              action: SnackBarAction(
                  label: 'ABRIR ARCHIVO',
                  onPressed: () async {
                    await launchFile(file.path);
                  })));
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }

      onUpdate(String filePath, DocumentModal parent, String reportName,
          QueryContext queryContext) async {
        try {
          var id = widget.company.id;
          parent.reportViewModel = await Sale.getReportViewByConcept(
              words: searchWord.text,
              companyId: id!,
              startDate: widget.startDate,
              endDate: widget.endDate,
              reportName: reportName,
              targetPath: '$filePath.XLSX',
              queryContext: queryContext,
              filterParams: filterStatus);
        } catch (e) {
          showAlert(context, message: e.toString());
        }
      }

      Get.to(() => DocumentModal(
          context: context,
          customTitle: 'REPORTE POR CONCEPTO - ',
          formatType: '607',
          companyDetailsPage: widget,
          reportViewModel: result,
          generateXlsx: generateXlsx,
          onUpdate: onUpdate));
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _preloadReportDataByClient() async {
    try {
      showLoader(context);

      var result = await Sale.getReportViewByProvider(
          words: searchWord.text,
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate,
          filterParams: filterStatus);

      generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
        showLoader(context);
        try {
          var data = reportViewModel['data'];

          var isEmpty = data.length == 1;

          if (isEmpty) {
            throw 'NO TIENES DATOS QUE GENERAR';
          }

          if (data.length > 1) {
            var file = File('$filePath.XLSX');

            await file.create(recursive: true);

            await file.writeAsBytes(reportViewModel['excelBytes']);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('SE GENERO EL REPORTE XLSX - $customTitle - $title'),
                action: SnackBarAction(
                    label: 'ABRIR ARCHIVO',
                    onPressed: () async {
                      await launchFile(file.path);
                    })));
          }
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }

      onUpdate(String filePath, DocumentModal parent, String reportName,
          QueryContext queryContext) async {
        try {
          var id = widget.company.id;
          parent.reportViewModel = await Sale.getReportViewByProvider(
              words: searchWord.text,
              companyId: id!,
              startDate: widget.startDate,
              endDate: widget.endDate,
              reportName: reportName,
              targetPath: '$filePath.XLSX',
              queryContext: queryContext,
              filterParams: filterStatus);
        } catch (e) {
          showAlert(context, message: e.toString());
        }
      }

      Navigator.pop(context);
      Get.to(() => DocumentModal(
          context: context,
          customTitle: 'REPORTE POR CLIENTE - ',
          formatType: '607',
          companyDetailsPage: widget,
          reportViewModel: result,
          generateXlsx: generateXlsx,
          onUpdate: onUpdate));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _copyRnc() async {
    try {
      await Clipboard.setData(ClipboardData(text: company.rnc!));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('RNC DE ${company.name} COPIADO')));
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _goHome() async {
    try {
      Get.back();
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  String get reloadLabel {
    if (formType == FormType.form606) {
      return "RECARGAR COMPRAS Y GASTOS";
    }

    if (formType == FormType.form607) {
      return 'RECARGAR VENTAS';
    }
    if (formType == FormType.form608) {
      return 'RECARGAR COMPROBANTES ANULADOS';
    }
    return '';
  }

  String get addTitleContext {
    if (formType == FormType.form606) {
      return 'AÑADIR FACTURA DE COMPRAS Y GASTOS';
    }
    if (formType == FormType.form607) {
      return "AÑADIR FACTURA DE VENTAS";
    }
    if (formType == FormType.form608) {
      return "AÑADIR COMPROBANTE ANULADO";
    }
    return '';
  }

  reload() async {
    showLoader(context);
    try {
      widget.currentIdValue = 0;
      widget.currentVisibleId = 0;
      if (formType == FormType.form606) {
        filterStatus = 'authorized = true and';
        controllerPurchases.purchases.value = await Purchase.get(
          companyId: company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
      }
      if (formType == FormType.form607) {
        filterStatus = '';
        controllerSales.sales.value = await Sale.get(
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);
      }

      if (formType == FormType.form608) {
        ncfsOverrideController.ncfsOverrides.value = await NcfOverrideModel.get(
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);
      }

      searchWord.value = TextEditingValue.empty;
      if (widget.controller2.scrollController.hasClients) {
        widget.controller2.scrollController.jumpTo(0);
        widget.controller2.verticalScrollController.jumpTo(0);
      }
      Get.back();
    } catch (e) {
      Get.back();
      showAlert(context, message: e.toString());
    }
  }

  preloadImports() async {
    try {
      Get.to(() => ImportsPage(companyDetailsPage: widget));
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _onSelectedOption(Map<String, dynamic> option) {
    if (option['type'] == ReportModelType.invoiceType) {
      _preloadReportDataForInvoiceType();
    }
    if (option['type'] == ReportModelType.conceptType) {
      _preloadReportDataForConceptType();
    }
    if (option['type'] == ReportModelType.companyName) {
      _preloadReportDataForCompanyName();
    }
    if (option['type'] == ReportModelType.imports) {
      preloadImports();
    }
  }

  _onSelectedOption607(Map<String, dynamic> option) {
    if (option['type'] == ReportModelType.typeIncome) {
      _preloadReportDataByTypeIncome();
    }
    if (option['type'] == ReportModelType.conceptType) {
      _preloadReportDataByConcept();
    }
    if (option['type'] == ReportModelType.companyName) {
      _preloadReportDataByClient();
    }
  }

  _showDatePicker() async {
    showLoader(context);

    var myDateRange = await showDateRangePicker(
        locale: const Locale('es'),
        useRootNavigator: false,
        currentDate: DateTime.now(),
        builder: (ctx, widget) {
          return WindowBorder(
              width: 1,
              color: kWindowBorderColor,
              child: Column(
                children: [
                  const CustomFrameWidgetDesktop(),
                  Expanded(child: widget!)
                ],
              ));
        },
        initialDateRange:
            DateTimeRange(start: widget.startDate, end: widget.endDate),
        context: context,
        firstDate: DateTime(1999),
        lastDate: DateTime(3000));

    if (myDateRange != null) {
      widget.startDate = myDateRange.start;
      widget.endDate = myDateRange.end;

      if (formType == FormType.form606) {
        controllerPurchases.purchases.value = await Purchase.get(
            companyId: company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);

        await storage.write(
            key: "STARTDATE_${company.id}",
            value: widget.startDateLargeAsString);
        await storage.write(
            key: "ENDDATE_${company.id}", value: widget.endDateLargeAsString);
      }
      if (formType == FormType.form607) {
        controllerSales.sales.value = await Sale.get(
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);
        await storage.write(
            key: "STARTDATE_SALES_${company.id}",
            value: widget.startDateLargeAsString);
        await storage.write(
            key: "ENDDATE_SALES_${company.id}",
            value: widget.endDateLargeAsString);
      }

      if (formType == FormType.form608) {
        ncfsOverrideController.ncfsOverrides.value = await NcfOverrideModel.get(
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);
        await storage.write(
            key: "STARTDATE_ANULADOS_${company.id}",
            value: widget.startDateLargeAsString);
        await storage.write(
            key: "ENDDATE_ANULADOS_${company.id}",
            value: widget.endDateLargeAsString);
      }

      widget.controller2.date.value =
          TextEditingValue(text: widget.dateRangeAsString);

      if (widget.controller2.scrollController.hasClients) {
        widget.controller2.verticalScrollController.jumpTo(0);
        widget.controller2.scrollController.jumpTo(0);
        searchWord.value = TextEditingValue.empty;
      }
    }
    Navigator.pop(context);
  }

  _openPeriods() async {
    try {
      var c = Get.put(PeriodsController());
      if (formType == FormType.form606) {
        c.periods.value = await Purchase.getListPeriods(id: company.id!);
      }
      if (formType == FormType.form607) {
        c.periods.value = await Sale.getListPeriods(id: company.id!);
      }
      if (formType == FormType.form608) {
        c.periods.value =
            await NcfOverrideModel.getListPeriods(id: company.id!);
      }
      Get.to(() => PeriodsPage(companyDetailsPage: widget, formType: formType));
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  onSavedSearchValue() async {
    showLoader(context);
    var value = searchWord.text;
    try {
      var n = value.replaceAll(',', '');

      var val = value;

      if (value.contains(',') && double.tryParse(n) != null) {
        val = double.parse(n).toStringAsFixed(2);
      }
      if (formType == FormType.form606) {
        controllerPurchases.purchases.value = await Purchase.get(
            companyId: company.id!,
            searchWord: val,
            searchMode: true,
            startDate: widget.startDate,
            endDate: widget.endDate);
      }

      if (formType == FormType.form607) {
        controllerSales.sales.value = await Sale.get(
            searchMode: true,
            searchWord: val,
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);
      }
      if (formType == FormType.form608) {
        ncfsOverrideController.ncfsOverrides.value = await NcfOverrideModel.get(
            searchMode: true,
            searchWord: val,
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);
      }

      widget.date.value = TextEditingValue(
          text:
              '${widget.startDateNormalAsString} - ${widget.endDateNormalAsString}');

      if (widget.controller2.scrollController.hasClients) {
        widget.controller2.verticalScrollController.jumpTo(0);
        widget.controller2.scrollController.jumpTo(0);
      }
      Get.back();
    } catch (e) {
      Get.back();
      showAlert(context, message: e.toString());
    }
  }

  showFilterModal() async {
    var res = await showDialog(
        context: context,
        builder: (ctx) => FilterModalWidget(
            companyDetailsPage: widget, searchWord: searchWord));

    if (res != null) {
      filterStatus = res['filterStatus'];
    }
  }

  String get labelEdit {
    if (formType == FormType.form608) {
      return 'EDITAR COMPROBANTE';
    }
    return 'EDITAR FACTURA';
  }

  String get labelMove {
    if (formType == FormType.form608) {
      return 'MOVER COMPROBANTE';
    }
    return 'MOVER FACTURA';
  }

  String get labelNcfOverrideInsert {
    return 'ANULAR COMPROBANTE DESDE VENTAS (607)';
  }

  String get labelDelete {
    if (formType == FormType.form608) {
      return 'ELIMINAR COMPROBANTE';
    }
    return 'ELIMINAR FACTURA';
  }

  Future<dynamic> showPopUpMenu(Offset globalPosition) async {
    double left = globalPosition.dx;
    double top = globalPosition.dy;

    List<PopupMenuEntry<dynamic>> elements = [];

    var conditionLine1 = widget.formType == FormType.form606
        ? sessionController.currentUser!.value!.permissions!
            .contains('ALLOW_UPDATE_PURCHASE_INVOICE')
        : widget.formType == FormType.form607
            ? sessionController.currentUser!.value!.permissions!
                .contains('ALLOW_UPDATE_SALE_INVOICE')
            : sessionController.currentUser!.value!.permissions!
                .contains('ALLOW_UPDATE_OVERRIDE_INVOICE');

    if (conditionLine1) {
      elements.add(PopupMenuItem(
        padding: EdgeInsets.zero,
        value: 1,
        child: Container(
          padding: EdgeInsets.all(kDefaultPadding / 2),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12))),
          child: Row(
            children: [
              Icon(Icons.edit_note, color: Theme.of(context).primaryColor),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Text(
                labelEdit,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ))
            ],
          ),
        ),
      ));
    }

    var conditionLine2 = widget.formType == FormType.form606
        ? sessionController.currentUser!.value!.permissions!
            .contains('ALLOW_MOVE_PURCHASE_INVOICE')
        : widget.formType == FormType.form607
            ? sessionController.currentUser!.value!.permissions!
                .contains('ALLOW_MOVE_SALE_INVOICE')
            : sessionController.currentUser!.value!.permissions!
                .contains('ALLOW_MOVE_OVERRIDE_INVOICE');

    if (conditionLine2) {
      elements.add(PopupMenuItem(
        padding: EdgeInsets.zero,
        value: 2,
        child: Container(
          padding: EdgeInsets.all(kDefaultPadding / 2),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12))),
          child: Row(
            children: [
              Icon(Icons.keyboard_arrow_right,
                  color: Theme.of(context).primaryColor),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Text(
                labelMove,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ))
            ],
          ),
        ),
      ));
    }

    var conditionLine3 = widget.formType == FormType.form606
        ? sessionController.currentUser!.value!.permissions!
            .contains('ALLOW_DELETE_PURCHASE_INVOICE')
        : widget.formType == FormType.form607
            ? sessionController.currentUser!.value!.permissions!
                .contains('ALLOW_DELETE_SALE_INVOICE')
            : sessionController.currentUser!.value!.permissions!
                .contains('ALLOW_DELETE_OVERRIDE_INVOICE');

    if (conditionLine3) {
      elements.add(PopupMenuItem(
        padding: EdgeInsets.zero,
        value: 3,
        child: Container(
          padding: EdgeInsets.all(kDefaultPadding / 2),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12))),
          child: Row(
            children: [
              Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Text(
                labelDelete,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ))
            ],
          ),
        ),
      ));
    }

    return await showMenu(
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(left, top, left + 1, top + 1),
      items: elements,
      elevation: 8.0,
    );
  }

  Widget get content {
    if (formType == FormType.form606) {
      return _invoicesView606;
    }
    if (formType == FormType.form607) {
      return _invoicesView607;
    }
    if (formType == FormType.form608) {
      return _invoicesView608;
    }
    return Container();
  }

  Widget get _invoicesView606 {
    if (purchases.isEmpty) return _emptyContainer;

    var invs = purchases.map((e) => e.toDisplay()).toList();

    var columns = invs[0].keys.toList();

    columns = [invs.length.toString(), ...columns];

    var widgets = List.generate(columns.length, (index) {
      var isNumber = index == 0;
      var isAuthor = index == 1;
      var isRnc = index == 2;
      var isTypeInvoice = index == 5;
      var isNcf = index == 6 || index == 7;

      var w = isNumber
          ? 80
          : isAuthor || isRnc
              ? 150
              : isTypeInvoice
                  ? 485
                  : isNcf
                      ? 155
                      : 250;

      return Container(
        width: w.toDouble(),
        padding: const EdgeInsets.only(left: 15, right: 5, top: 15, bottom: 15),
        child: Text(columns[index],
            style: const TextStyle(color: Colors.blue, fontSize: 17),
            softWrap: true),
      );
    });

    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: SingleChildScrollView(
          controller: widget.controller2.scrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 85,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black12))),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: widgets)),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      controller: widget.controller2.verticalScrollController,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(invs.length, (i) {
                            var invoice = invs[i];
                            var purchase = purchases[invs.indexOf(invoice)];
                            var values = invoice.entries.toList();
                            values = [MapEntry('', (i + 1)), ...values];
                            var widgets = List.generate(values.length, (j) {
                              var cell = values[j];
                              var isNumber = j == 0;
                              var isAuthor = j == 1;
                              var isRnc = j == 2;

                              var isTypeInvoice = j == 5;
                              var isNcf = j == 6 || j == 7;

                              var w = isNumber
                                  ? 80
                                  : isAuthor || isRnc
                                      ? 150
                                      : isTypeInvoice
                                          ? 485
                                          : isNcf
                                              ? 155
                                              : 250;
                              return Container(
                                width: w.toDouble(),
                                color: !purchase.authorized
                                    ? const Color.fromARGB(31, 188, 187, 187)
                                    : Colors.transparent,
                                padding: const EdgeInsets.only(
                                    left: 15, right: 5, top: 15, bottom: 15),
                                child: Text(
                                  cell.value == null || cell.value == ''
                                      ? 'S/N'
                                      : cell.value.toString(),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              );
                            });

                            return GestureDetector(
                                onSecondaryTapDown: (details) async {
                                  try {
                                    var value = await showPopUpMenu(
                                        details.globalPosition);

                                    if (value == 1) {
                                      _selectInvoice(purchase);
                                    }

                                    if (value == 2) {
                                      showDialog(
                                          context: context,
                                          builder: (ctx) =>
                                              CompanySelectorWidget(
                                                  company: widget.company,
                                                  item: purchase,
                                                  startDate: widget.startDate,
                                                  endDate: widget.endDate));
                                    }

                                    if (value == 3) {
                                      var confirm = await showConfirm(context,
                                          title:
                                              '¿DESEAS ELIMINAR ESTA FACTURA?');
                                      if (confirm != null && confirm) {
                                        showLoader(context);
                                        await purchase.delete();
                                        controllerPurchases.purchases.value =
                                            await Purchase.get(
                                                companyId: widget.company.id!,
                                                startDate: widget.startDate,
                                                endDate: widget.endDate);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'SE ELIMINO LA FACTURA')));
                                        Get.back();
                                      }
                                    }
                                  } catch (e) {
                                    showAlert(context, message: e.toString());
                                  }
                                },
                                child: Container(
                                  height: 55,
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.black12))),
                                  child: Row(children: widgets),
                                ));
                          }))))
            ],
          ),
        ));
  }

  Widget get _invoicesView607 {
    if (controllerSales.sales.isEmpty) return _emptyContainer;

    var invs = controllerSales.sales.map((e) => e.toDisplay()).toList();

    var columns = invs[0].keys.toList();

    columns = [invs.length.toString(), ...columns];

    var widgets = List.generate(columns.length, (index) {
      var w = index == 0 ? 90 : 185;
      w = index == 3 ? 250 : w;
      w = index == 7 ? 450 : w;

      return Container(
        width: w.toDouble(),
        padding: const EdgeInsets.only(left: 12, top: 15, bottom: 15),
        child: Text(
          columns[index],
          style: const TextStyle(color: Colors.blue, fontSize: 17),
        ),
      );
    });

    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: SingleChildScrollView(
          controller: widget.controller2.scrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 85,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black12))),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [...widgets])),
              ),
              Expanded(
                  child: SizedBox(
                      child: SingleChildScrollView(
                controller: controller2.verticalScrollController,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(invs.length, (i) {
                      var invoice = invs[i];
                      var values = invoice.entries.toList();
                      values = [MapEntry('', (i + 1)), ...values];

                      var widgets = List.generate(values.length, (j) {
                        var cell = values[j];

                        var w = j == 0 ? 90 : 185;

                        w = j == 3 ? 250 : w;
                        w = j == 7 ? 450 : w;

                        return Container(
                          width: w.toDouble(),
                          padding: const EdgeInsets.only(
                              left: 15, right: 5, top: 15, bottom: 15),
                          child: Text(
                            cell.value == null || cell.value == ''
                                ? 'S/N'
                                : cell.value.toString(),
                            style: const TextStyle(
                                fontSize: 17, overflow: TextOverflow.ellipsis),
                          ),
                        );
                      });

                      return GestureDetector(
                          onSecondaryTapDown: (details) async {
                            try {
                              var sale =
                                  controllerSales.sales[invs.indexOf(invoice)];

                              var value =
                                  await showPopUpMenu(details.globalPosition);

                              if (value == 1) {
                                _selectSale(sale);
                              }

                              if (value == 2) {
                                showDialog(
                                    context: context,
                                    builder: (ctx) => CompanySelectorWidget(
                                        company: widget.company,
                                        item: sale,
                                        startDate: widget.startDate,
                                        endDate: widget.endDate));
                              }

                              if (value == 3) {
                                var confirm = await showConfirm(context,
                                    title: '¿DESEAS ELIMINAR ESTA FACTURA?');
                                if (confirm != null && confirm) {
                                  showLoader(context);
                                  await sale.delete();
                                  controllerSales.sales.value = await Sale.get(
                                      companyId: widget.company.id!,
                                      startDate: widget.startDate,
                                      endDate: widget.endDate);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('SE ELIMINO LA VENTA')));

                                  Get.back();
                                }
                              }
                            } catch (e) {
                              showAlert(context, message: e.toString());
                            }
                          },
                          child: Container(
                            height: 55,
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.black12))),
                            child: Row(children: widgets),
                          ));
                    })),
              )))
            ],
          ),
        ));
  }

  Widget get _invoicesView608 {
    if (ncfsOverrideController.ncfsOverrides.isEmpty) return _emptyContainer;

    var invs =
        ncfsOverrideController.ncfsOverrides.map((e) => e.toDisplay()).toList();

    var columns = invs[0].keys.toList();

    columns = [invs.length.toString(), ...columns];

    var widgets = List.generate(columns.length, (index) {
      var w = index == 0 ? 90 : 225;
      w = index == 4 ? 400 : w;

      return Container(
        width: w.toDouble(),
        padding: const EdgeInsets.only(left: 12, top: 15, bottom: 15),
        child: Text(
          columns[index],
          style: const TextStyle(color: Colors.blue, fontSize: 17),
        ),
      );
    });

    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: SingleChildScrollView(
          controller: widget.controller2.scrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 85,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black12))),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [...widgets])),
              ),
              Expanded(
                  child: SizedBox(
                      child: SingleChildScrollView(
                controller: controller2.verticalScrollController,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(invs.length, (i) {
                      var invoice = invs[i];
                      var values = invoice.entries.toList();
                      values = [MapEntry('', (i + 1)), ...values];

                      var widgets = List.generate(values.length, (j) {
                        var cell = values[j];

                        var w = j == 0 ? 90 : 225;

                        w = j == 4 ? 400 : w;

                        return Container(
                          width: w.toDouble(),
                          padding: const EdgeInsets.only(
                              left: 15, right: 5, top: 15, bottom: 15),
                          child: Text(
                            cell.value == null || cell.value == ''
                                ? 'S/N'
                                : cell.value.toString(),
                            style: const TextStyle(
                                fontSize: 17, overflow: TextOverflow.ellipsis),
                          ),
                        );
                      });

                      return GestureDetector(
                          onSecondaryTapDown: (details) async {
                            try {
                              var ncfOverride = ncfsOverrideController
                                  .ncfsOverrides[invs.indexOf(invoice)];

                              var value =
                                  await showPopUpMenu(details.globalPosition);

                              if (value == 1) {
                                _selectNcfOverride(ncfOverride);
                              }

                              if (value == 2) {
                                var res = await showDialog(
                                    context: context,
                                    builder: (ctx) => CompanySelectorWidget(
                                        company: widget.company,
                                        item: ncfOverride,
                                        startDate: widget.startDate,
                                        endDate: widget.endDate));
                                if (res != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'SE MOVIO EL COMPROBANTE ANULADO')));
                                }
                              }

                              if (value == 3) {
                                var confirm = await showConfirm(context,
                                    title:
                                        '¿DESEAS ELIMINAR ESTE COMPROBANTE ANULADO?');
                                if (confirm != null && confirm) {
                                  showLoader(context);
                                  await ncfOverride.delete();
                                  ncfsOverrideController.ncfsOverrides.value =
                                      await NcfOverrideModel.get(
                                          companyId: widget.company.id!,
                                          startDate: widget.startDate,
                                          endDate: widget.endDate);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'SE ELIMINO EL COMPROBANTE ANULADO')));
                                  Get.back();
                                }
                              }
                            } catch (e) {
                              showAlert(context, message: e.toString());
                            }
                          },
                          child: Container(
                            height: 55,
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.black12))),
                            child: Row(children: widgets),
                          ));
                    })),
              )))
            ],
          ),
        ));
  }

  String get rangeAsString {
    return '${company.name}  ${widget.startDateAsString} - ${widget.endDateAsString}';
  }

  List<Purchase> get purchases {
    return controllerPurchases.purchases;
  }

  get controller2 {
    return widget.controller2;
  }

  FormType get formType {
    return widget.formType;
  }

  Company get company {
    return widget.company;
  }

  bool get isMultiplyPeriod {
    return widget.endDate.month - widget.startDate.month >= 1;
  }

  bool get isEmptyContent {
    return purchases.isEmpty;
  }

  List<Map<String, dynamic>> get reportTypesData {
    return formType == FormType.form606 ? reportTypes : reportTypes607;
  }

  Widget get _emptyContainer {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svgs/undraw_receipt_tzi0.svg', width: 250)
        ],
      ),
    );
  }

  String get _count01 {
    if (formType == FormType.form606) {
      return purchases
          .where((element) =>
              element.invoiceNcfTypeId != 2 &&
              element.invoiceNcfTypeId != 32 &&
              element.authorized == true &&
              element.invoiceNcfTypeId != null)
          .toList()
          .length
          .toString();
    }

    if (formType == FormType.form607) {
      return controllerSales.sales
          .where((element) =>
              element.invoiceNcfTypeId != 2 && element.invoiceNcfTypeId != 32)
          .toList()
          .length
          .toString();
    }

    if (formType == FormType.form608) {
      return ncfsOverrideController.ncfsOverrides.length.toString();
    }
    return '0';
  }

  Timer? _timer;
  String _scannedData = '';
  DateTime _lastKeyPress = DateTime.now();
  final FocusNode _focusKeyb = FocusNode();

  String normalizarCaracter(String input) {
    const mapaEspToUs = {
      'ñ': ';',
      'Ñ': ':',
      'ç': '\'',
      'Ç': '"',
      '¡': '!',
      '¿': '?',
      '´': '`',
      '¨': '^',
      'º': ']',
      'ª': '[',
      '€': '\$',
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ü': 'u',
      'Ü': 'U',
      '«': '<',
      '»': '>',
      '–': '-',
      '—': '-',
      '·': '.',
      '…': '...',
      '“': '"',
      '”': '"',
      '‘': '\'',
      '’': '\'',
      '°': 'º',
      '×': '*',
      '÷': '/',
    };

    return input.split('').map((char) => mapaEspToUs[char] ?? char).join();
  }

  void _onScanComplete() {
    print(_scannedData);
    searchNcf(_scannedData);
    _scannedData = '';
    _timer = null;
  }

  bool _handleKeyEvent(KeyEvent event, isScan) {
    if (event is KeyDownEvent) {
      DateTime now = DateTime.now();
      Duration difference = now.difference(_lastKeyPress);
      _lastKeyPress = now;

      if (_timer != null) {
        _timer!.cancel();
      }

      if (difference.inMilliseconds < 50) {
        _scannedData += event.character ?? '';

        _timer = Timer(Duration(milliseconds: 50), _onScanComplete);
      } else {
        _scannedData += event.character ?? '';
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    sessionController = Get.find<SessionController>();
    controllerPurchases = Get.find<PurchasesController>();
    controllerSales = Get.find<SalesController>();
    ncfsOverrideController = Get.find<NcfsOverrideController>();
    widget.controller2 = Get.put(CompanyDetailsController());
    controller2.date.value = TextEditingValue(text: widget.dateRangeAsString);

    return WindowBorder(
        color: kWindowBorderColor,
        width: 1,
        child: LayoutWithBar(
            child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: null,
            leadingWidth: 0,
            title: Text(widget.title),
            elevation: 0,
            actions: [
              Row(
                children: [
                  Obx(() => SizedBox(
                      height: kToolbarHeight,
                      width: 50,
                      child: Tooltip(
                        message:
                            'CANTIDAD DE NCFS QUE SERAN REPORTADOS A LA DGII',
                        child: Center(
                          child: Text(_count01,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500)),
                        ),
                      ))),
                  ToolButton(
                      onTap: _copyRnc,
                      toolTip: 'COPIAR RNC DE ${company.name?.toUpperCase()}',
                      icon: const Icon(Icons.copy)),
                  ToolButton(
                      onTap: _goHome,
                      toolTip: 'IR A INICIO',
                      icon: const Icon(Icons.home)),
                  ToolButton(
                      onTap: _showConceptModal,
                      toolTip: 'ABRIR CATALOGO DE CATEGORIAS',
                      icon: const Icon(Icons.reorder)),
                  ToolButton(
                      onTap: _openFolder,
                      toolTip: 'ABRIR CARPETA DE ${company.name}',
                      icon: const Icon(Icons.folder)),
                  ToolButton(
                      onTap: _exportData,
                      toolTip: 'EXPORT ${widget.formatType} DATA',
                      icon: const Icon(Icons.ios_share_outlined)),
                  ToolButton(
                      onTap: _importData,
                      toolTip: 'IMPORT ${widget.formatType} DATA',
                      icon: const Icon(Icons.download)),
                  formType != FormType.form608
                      ? ToolButton(
                          onTap: _generateXlsx,
                          toolTip: 'GENERAR XLSX',
                          icon: const Icon(Icons.calculate_outlined))
                      : const SizedBox(),
                  ToolButton(
                      onTap: _generateForm,
                      toolTip: 'GENERAR ${widget.formatType}',
                      icon: const Icon(Icons.save))
                ],
              )
            ],
          ),
          body: Column(
            children: [
              SizedBox(height: kDefaultPadding),
              Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: 80,
                        child: TextFormField(
                          controller: controller2.date,
                          enableInteractiveSelection: false,
                          readOnly: true,
                          keyboardType: TextInputType.none,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                              hintText: 'RANGO DE FECHA',
                              labelText: 'RANGO DE FECHA',
                              suffixIcon: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                children: [
                                  IconButton(
                                      tooltip: 'ABRIR CALENDARIO',
                                      onPressed: _showDatePicker,
                                      icon: const Icon(Icons.calendar_month)),
                                  const SizedBox(width: 5),
                                  IconButton(
                                      tooltip:
                                          'ABRIR LISTA DE PERIODOS FISCALES DE ${company.name?.toUpperCase()}',
                                      onPressed: _openPeriods,
                                      icon:
                                          const Icon(Icons.list_alt_outlined)),
                                  SizedBox(width: kDefaultPadding / 2)
                                ],
                              ),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(kDefaultPadding))),
                        ),
                      )),
                      SizedBox(width: kDefaultPadding),
                      SizedBox(
                          width: 250,
                          height: 80,
                          child: Focus(
                            child: TextFormField(
                              controller: searchWord,
                              onFieldSubmitted: (_) => onSavedSearchValue(),
                              inputFormatters: [UpperCaseTextFormatter()],
                              decoration: InputDecoration(
                                  hintText: 'BUSCAR...',
                                  suffixIcon: Padding(
                                      padding: EdgeInsets.only(
                                          right: kDefaultPadding / 2),
                                      child: Wrap(
                                        children: [
                                          IconButton(
                                              onPressed: () =>
                                                  onSavedSearchValue(),
                                              icon: const Icon(Icons.search)),
                                          formType != FormType.form608
                                              ? IconButton(
                                                  onPressed: showFilterModal,
                                                  icon: const Icon(Icons.tune))
                                              : const SizedBox()
                                        ],
                                      )),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          kDefaultPadding))),
                            ),
                          ))
                    ],
                  )),
              Obx(() => Expanded(
                      child: GestureDetector(
                    onTap: () => _focusKeyb.requestFocus(),
                    child: Focus(
                        focusNode: _focusKeyb,
                        autofocus: true,
                        onKeyEvent: (focus, event) {
                          try {
                            if (Platform.isMacOS) {
                              if (event.physicalKey.debugName == 'Num Lock' ||
                                  event.logicalKey.keyLabel == 'Num Lock') {
                                return KeyEventResult.ignored;
                              }
                            }

                            _handleKeyEvent(event, true);
                            return KeyEventResult.handled;
                          } catch (e) {
                            return KeyEventResult.ignored;
                          }
                        },
                        child: content),
                  )))
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              formType == FormType.form608
                  ? CustomFloatingActionButton(
                      title: 'BUSCAR COMPROBANTES DESDE VENTAS (607)',
                      onTap: () async {
                        var res = await showDialog(
                            context: context,
                            builder: (ctx) => NcfSaleSelectorModal(
                                companyDetailsPage: widget));
                      },
                      child: const Icon(Icons.search, color: Colors.white))
                  : const Wrap(),
              formType != FormType.form608
                  ? CustomFloatingActionButton(
                      title: 'VER REPORTE POR TIPO DE FACTURA',
                      child: PopupMenuButton<Map<String, dynamic>>(
                          onSelected: formType == FormType.form606
                              ? _onSelectedOption
                              : _onSelectedOption607,
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          itemBuilder: (ctx) {
                            return reportTypesData
                                .map((e) => PopupMenuItem<Map<String, dynamic>>(
                                    value: e, child: Text(e['name'])))
                                .toList();
                          }))
                  : const Wrap(),
              const SizedBox(width: 10),
              CustomFloatingActionButton(
                  onTap: reload,
                  title: reloadLabel,
                  child:
                      const Icon(Icons.replay_outlined, color: Colors.white)),
              const SizedBox(width: 10),
              CustomFloatingActionButton(
                  onTap: _showModalContext,
                  title: addTitleContext,
                  child: const Icon(Icons.add, color: Colors.white)),
            ],
          ),
        )));
  }
}
