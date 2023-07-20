// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/periods.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/controllers/ready.company.details.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/modals/add-concept-modal.dart';
import 'package:uresaxapp/modals/add-purchase-modal.dart';
import 'package:uresaxapp/modals/add.sale.modal.dart';
import 'package:uresaxapp/modals/document.modal.type.income.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:uresaxapp/pages/imports_page.dart';
import 'package:uresaxapp/pages/periods.page.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:path/path.dart' as path;
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.floating-action.button.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';
import 'package:window_manager/window_manager.dart';
import 'package:pdf/widgets.dart' as pw;

class ShowPurchaseModalIntent extends Intent {
  final String name;
  const ShowPurchaseModalIntent({required this.name});
}

class CompanyDetailsPage extends StatefulWidget {
  Company company;

  DateTime startDate;

  DateTime endDate;

  FormType formType;

  late CompanyDetailsController controller2;

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

  CompanyDetailsPage({
    super.key,
    this.formType = FormType.form606,
    required this.startDate,
    required this.endDate,
    required this.company,
  });

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  DateTimeRange? myDateRange;

  late pw.Document pdf;

  late PurchasesController controllerPurchases;

  late SalesController controllerSales;

  TextEditingController searchWord = TextEditingController();

  List<Purchase> get purchases {
    return controllerPurchases.purchases;
  }

  get controller2 {
    return widget.controller2;
  }

  BuildContext get context {
    return Get.context!;
  }

  String get dateRangeAsString {
    return '${widget.startDateNormalAsString} - ${widget.endDateNormalAsString}';
  }

  String get startDatePeriod {
    return widget.startDate.format(payload: 'YYYYMM');
  }

  String get endDatePeriod {
    return widget.endDate.format(payload: 'YYYYMM');
  }

  String get yearPeriod {
    return widget.startDate.format(payload: 'YYYY');
  }

  FormType get formType {
    return widget.formType;
  }

  Company get company {
    return widget.company;
  }

  String get _title {
    return '${company.name!} / RNC ${company.rnc} - ${formType == FormType.form606 ? 'COMPRAS Y GASTOS' : 'VENTAS'}';
  }

  String get _rootPath {
    return path.join(Platform.environment['URESAX_STATIC_LOCAL_SERVER_PATH']!,
        'URESAX', company.name?.trim(), yearPeriod, formatType);
  }

  String get formatType {
    if (formType == FormType.form607) return '607';
    return '606';
  }

  String get _fileName {
    return path.join(
        _rootPath, 'DGII_F_${formatType}_${company.rnc}_$startDatePeriod');
  }

  String get _filePath {
    return '$_fileName.TXT';
  }

  String get _dirPath {
    return path.dirname(_filePath);
  }

  bool get isMultiplyPeriod {
    return widget.endDate.month - widget.startDate.month >= 1;
  }

  bool get isEmptyContent {
    return purchases.isEmpty;
  }

  Future<void> _showConceptModal() async {
    try {
      showLoader(context);
      var concepts = await Concept.getConcepts();
      Navigator.pop(context);
      await showDialog(
          context: context,
          builder: (ctx) => AddConceptModal(concepts: concepts));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _generate606() async {
    try {
      var purchases = await Purchase.getPurchases(
          id: company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      purchases.removeWhere((element) =>
          element.invoiceNcfTypeId == 2 ||
          element.invoiceNcfTypeId == 32 ||
          element.authorized == false);

      var elements = purchases.map((e) => e.to606()).toList();

      if (purchases.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NO TIENES FACTURAS'),
        ));
        return;
      }

      if (isMultiplyPeriod) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NO PUEDES GENERAR EL 606 PARA MULTIPLES PERIODOS'),
        ));
        return;
      }

      showLoader(context);

      await createXls();

      List<List<dynamic>> rows = [];

      for (int i = 0; i < elements.length; i++) {
        var item = elements[i];
        var values = item.values.toList();
        rows.add(values);
      }

      var result = const ListToCsvConverter().convert([
        [606, company.rnc, startDatePeriod, purchases.length],
        ...rows
      ], fieldDelimiter: '|');

      var file = File(_filePath.trim());

      await file.create(recursive: true);

      await file.writeAsString(result);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL 606 (TXT, XLSX)'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                launchFile(_dirPath);
              })));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _generate607() async {
    try {
      var sales = await Sale.get(
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      sales.removeWhere((element) =>
          element.invoiceNcfTypeId == 2 || element.invoiceNcfTypeId == 32);

      var elements = sales.map((e) => e.to607()).toList();

      if (sales.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NO TIENES FACTURAS'),
        ));
        return;
      }

      if (isMultiplyPeriod) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NO PUEDES GENERAR EL 607 PARA MULTIPLES PERIODOS'),
        ));
        return;
      }

      showLoader(context);

      List<List<dynamic>> rows = [];

      for (int i = 0; i < elements.length; i++) {
        var item = elements[i];
        var values = item.values.toList();
        rows.add(values);
      }

      var result = const ListToCsvConverter().convert([
        [607, company.rnc, startDatePeriod, sales.length],
        ...rows
      ], fieldDelimiter: '|');

      var file = File(_filePath.trim());

      await file.create(recursive: true);

      await file.writeAsString(result);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL 607'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                launchFile(_dirPath);
              })));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _openFolder() async {
    try {
      await launchFile(_dirPath);
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  Future<void> fetchPurchases() async {
    controllerPurchases.purchases.value = await Purchase.getPurchases(
        id: company.id!, startDate: widget.startDate, endDate: widget.endDate);
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
            ));
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
    try {
      var result = await showDialog(
          context: context,
          builder: (ctx) => AddSaleModal(
              companyDetailsPage: widget, isEditing: true, sale: sale));
      if (result is String) {
        if (result == 'INSERT') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE INSERTO LA FACTURA')));
        }
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

  _showModalSale() async {
    showDialog(
        context: context,
        builder: (ctx) => AddSaleModal(companyDetailsPage: widget));
  }

  Future<void> createXls() async {
    try {
      await Purchase.createXls(
          id: company.id!,
          sheetName: months[widget.startDate.month - 1],
          startDate: widget.startDateLargeAsString,
          endDate: widget.endDateLargeAsString,
          targetPath: path
              .join(_rootPath, '${company.name?.trim()} $yearPeriod.xlsx')
              .trim());
    } catch (e) {
      rethrow;
    }
  }

  String get rangeAsString {
    return '${company.name}  ${widget.startDateAsString} - ${widget.endDateAsString}';
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
      try {
        var data = reportViewModel['data'];

        var isEmpty = data.length == 0;

        if (isEmpty) {
          throw 'NO TIENES DATOS QUE GENERAR';
        }

        if (data.length > 1) {
          var file = File('$filePath.XLSX');
          showLoader(context);

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
      try {
        var data = reportViewModel['data'];

        var isEmpty = data.length == 0;

        if (isEmpty) {
          throw 'NO TIENES DATOS QUE GENERAR';
        }

        if (data.length > 1) {
          var fileName =
              '$customTitle $reportName - ${company.name?.trim()} - ${widget.startDate.format(payload: 'YYYY-MM-DD')} - ${widget.endDate.format(payload: 'YYYY-MM-DD')}.PDF';
          var file = File(path.join(dir, fileName));

          showLoader(context);

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
          startDate: widget.startDate,
          endDate: widget.endDate);

      generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
        try {
          var data = reportViewModel['data'];

          var isEmpty = data.length == 0;

          if (isEmpty) {
            throw 'NO TIENES DATOS QUE GENERAR';
          }

          if (data.length > 1) {
            var file = File('$filePath.XLSX');

            showLoader(context);

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

          var isEmpty = data.length == 0;

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
            queryContext: queryContext);
        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);
        showAlert(context, message: e.toString());
      }
    }

    try {
      var result = await Sale.getReportViewByTypeIncome(
          company: widget.company,
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
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
        try {
          var data = reportViewModel['data'];

          var isEmpty = data.length == 1;

          if (isEmpty) {
            throw 'NO TIENES DATOS QUE GENERAR';
          }

          var file = File('$filePath.XLSX');

          showLoader(context);

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
              companyId: id!,
              startDate: widget.startDate,
              endDate: widget.endDate,
              reportName: reportName,
              targetPath: '$filePath.XLSX',
              queryContext: queryContext);
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

  _preloadReportDataByProvider() async {
    try {
      showLoader(context);

      var result = await Sale.getReportViewByProvider(
          companyId: widget.company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate);

      generateXlsx(reportViewModel, title, customTitle, filePath, dir) async {
        try {
          var data = reportViewModel['data'];

          var isEmpty = data.length == 0;

          if (isEmpty) {
            throw 'NO TIENES DATOS QUE GENERAR';
          }

          if (data.length > 1) {
            var file = File('$filePath.XLSX');

            showLoader(context);

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
              companyId: id!,
              startDate: widget.startDate,
              endDate: widget.endDate,
              reportName: reportName,
              targetPath: '$filePath.XLSX',
              queryContext: queryContext);
        } catch (e) {
          showAlert(context, message: e.toString());
        }
      }

      Navigator.pop(context);
      Get.to(() => DocumentModal(
          context: context,
          customTitle: 'REPORTE POR PROVEEDOR - ',
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
      await windowManager.setPreventClose(false);
      Navigator.pop(context);
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  reload() async {
    try {
      if (formType == FormType.form606) {
        controllerPurchases.purchases.value = await Purchase.getPurchases(
          id: company.id!,
          startDate: widget.startDate,
          endDate: widget.endDate,
        );
      } else if (formType == FormType.form607) {
        controllerSales.sales.value = await Sale.get(
            companyId: widget.company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);
      }

      searchWord.value = TextEditingValue.empty;
      if (widget.controller2.scrollController.hasClients) {
        widget.controller2.scrollController.jumpTo(0);
        widget.controller2.verticalScrollController.jumpTo(0);
      }
    } catch (e) {
      print(e);
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
      Get.to(() => ImportsPage(companyDetailsPage: widget));
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
      _preloadReportDataByProvider();
    }
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
                                padding: const EdgeInsets.only(
                                    left: 15, right: 5, top: 15, bottom: 15),
                                child: Text(
                                  cell.value == null || cell.value == ''
                                      ? 'NINGUNO'
                                      : cell.value.toString(),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              );
                            });

                            return GestureDetector(
                                onDoubleTap: () => _selectInvoice(
                                    purchases[invs.indexOf(invoice)]),
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

                        return Container(
                          width: w.toDouble(),
                          padding: const EdgeInsets.only(
                              left: 15, right: 5, top: 15, bottom: 15),
                          child: Text(
                            cell.value == null || cell.value == ''
                                ? 'NINGUNO'
                                : cell.value.toString(),
                            style: const TextStyle(
                                fontSize: 17, overflow: TextOverflow.ellipsis),
                          ),
                        );
                      });

                      return GestureDetector(
                          onDoubleTap: () {
                            var sale =
                                controllerSales.sales[invs.indexOf(invoice)];
                            _selectSale(sale);
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

  Widget get _emptyContainer {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_document,
              color: Theme.of(context).primaryColor, size: 100)
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
              element.authorized == true)
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
    return '0';
  }

  _showDatePicker() async {
    showLoader(context);

    var myDateRange = await showDateRangePicker(
        locale: const Locale('es'),
        currentDate: DateTime.now(),
        initialDateRange:
            DateTimeRange(start: widget.startDate, end: widget.endDate),
        context: context,
        firstDate: DateTime(1999),
        lastDate: DateTime(3000));

    if (myDateRange != null) {
      widget.startDate = myDateRange.start;
      widget.endDate = myDateRange.end;

      if (formType == FormType.form606) {
        controllerPurchases.purchases.value = await Purchase.getPurchases(
            id: company.id!,
            startDate: widget.startDate,
            endDate: widget.endDate);

        await storage.write(
            key: "STARTDATE_${company.id}",
            value: widget.startDateLargeAsString);
        await storage.write(
            key: "ENDDATE_${company.id}", value: widget.endDateLargeAsString);
      } else {
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
      widget.controller2.date.value = TextEditingValue(text: dateRangeAsString);

      if (widget.controller2.scrollController.hasClients) {
        widget.controller2.verticalScrollController.jumpTo(0);
        widget.controller2.scrollController.jumpTo(0);
        searchWord.value = TextEditingValue.empty;
      }
    }
    Navigator.pop(context);
  }

  onSavedSearchValue() async {
    var value = searchWord.text;
    try {
      var n = value.replaceAll(',', '');

      var val = value;

      if (value.contains(',') && double.tryParse(n) != null) {
        val = double.parse(n).toStringAsFixed(2);
      }
      if (formType == FormType.form606) {
        controllerPurchases.purchases.value = await Purchase.getPurchases(
            id: company.id!,
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

      widget.date.value = TextEditingValue(
          text:
              '${widget.startDateNormalAsString} - ${widget.endDateNormalAsString}');

      if (widget.controller2.scrollController.hasClients) {
        widget.controller2.verticalScrollController.jumpTo(0);
        widget.controller2.scrollController.jumpTo(0);
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  List<Map<String, dynamic>> get reportTypesData {
    return formType == FormType.form606 ? reportTypes : reportTypes607;
  }

  @override
  dispose() {
    controllerPurchases.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controllerPurchases = Get.find<PurchasesController>();
    controllerSales = Get.find<SalesController>();
    widget.controller2 = Get.put(CompanyDetailsController());
    controller2.date.value = TextEditingValue(text: dateRangeAsString);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        leadingWidth: 0,
        title: Text(_title),
        elevation: 0,
        actions: [
          Row(
            children: [
              Obx(() => SizedBox(
                  height: kToolbarHeight,
                  width: 50,
                  child: Tooltip(
                    message: 'CANTIDAD DE NCFS QUE SERAN REPORTADOS A LA DGII',
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
                  onTap: formType == FormType.form606
                      ? _generate606
                      : _generate607,
                  toolTip: 'GENERAR $formatType',
                  icon: const Icon(Icons.save))
            ],
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                  onPressed: () async {
                                    var c = Get.put(PeriodsController());
                                    if (formType == FormType.form606) {
                                      c.periods.value =
                                          await Purchase.getListPeriods(
                                              id: company.id!);
                                    } else {
                                      c.periods.value =
                                          await Sale.getListPeriods(
                                              id: company.id!);
                                    }
                                    Get.to(() => PeriodsPage(
                                        companyDetailsPage: widget,
                                        formType: formType));
                                  },
                                  icon: const Icon(Icons.list_alt_outlined)),
                              const SizedBox(width: 10)
                            ],
                          ),
                          border: const OutlineInputBorder()),
                    ),
                  )),
                  const SizedBox(width: 20),
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
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                      onPressed: () => onSavedSearchValue(),
                                      icon: const Icon(Icons.search))),
                              border: const OutlineInputBorder()),
                        ),
                      ))
                ],
              )),
          Obx(() => Expanded(
                child: formType == FormType.form606
                    ? _invoicesView606
                    : _invoicesView607,
              ))
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFloatingActionButton(
              title: 'VER REPORTE POR TIPO DE FACTURA',
              child: PopupMenuButton<Map<String, dynamic>>(
                  onSelected: formType == FormType.form606
                      ? _onSelectedOption
                      : _onSelectedOption607,
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (ctx) {
                    return reportTypesData
                        .map((e) => PopupMenuItem<Map<String, dynamic>>(
                            value: e, child: Text(e['name'])))
                        .toList();
                  })),
          const SizedBox(width: 10),
          CustomFloatingActionButton(
              onTap: reload,
              title: formType == FormType.form606
                  ? "RECARGAR COMPRAS Y GASTOS"
                  : 'RECARGAR VENTAS',
              child: const Icon(Icons.replay_outlined, color: Colors.white)),
          const SizedBox(width: 10),
          CustomFloatingActionButton(
              onTap: formType == FormType.form606
                  ? _showModalPurchase
                  : _showModalSale,
              title: formType == FormType.form606
                  ? "AÑADIR FACTURA DE COMPRAS Y GASTOS"
                  : "AÑADIR FACTURA DE VENTAS",
              child: const Icon(Icons.add, color: Colors.white)),
        ],
      ),
    );
  }
}
