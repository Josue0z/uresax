import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart' as exl;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/imports.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/models/import.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uresaxapp/modals/add.import.modal.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';
import 'package:path/path.dart' as path;

class ImportsPage extends StatelessWidget {
  final CompanyDetailsPage companyDetailsPage;

  late ImportController importController;

  ImportsPage({super.key, required this.companyDetailsPage});

  ScrollController scrollController = ScrollController();

  double colWidth = 255;

  double colHeight = 85;

  int nn = 5;

  String get filePdfName {
    return 'IMPORTACIONES - ${companyDetailsPage.company.name?.toUpperCase()} - ${companyDetailsPage.startDate.format(payload: 'YYYY-MM-DD')} - ${companyDetailsPage.endDate.format(payload: 'YYYY-MM-DD')}.PDF';
  }

  String get rootPath {
    return path.join(
        Platform.environment['URESAX_STATIC_LOCAL_SERVER_PATH']!,
        'URESAX',
        companyDetailsPage.company.name?.trim(),
        companyDetailsPage.yearPeriod,
        'IMPORTACIONES');
  }

  savePdf() async {
    showLoader(Get.context!);
    try {
      if (importController.imports.isEmpty) {
        throw 'NO TIENES IMPORTACIONES';
      }

      var file = File(path.join(rootPath, filePdfName));
      await file.create(recursive: true);
      if (importController.pdfBytes != null) {
        await file.writeAsBytes(importController.pdfBytes!);

        Navigator.pop(Get.context!);

        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL PDF'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () async {
                launchFile(file.path);
              }),
        ));
      }
    } catch (e) {
      Navigator.pop(Get.context!);
      showAlert(Get.context!, message: e.toString());
    }
  }

  showModalOfImports() async {
    await showDialog(
        context: Get.context!,
        builder: (ctx) =>
            AddImportModal(companyDetailsPage: companyDetailsPage));
  }

  importTheImports() async {
    try {
      var result = await FilePicker.platform
          .pickFiles(allowedExtensions: ['xlsx', 'xls'], allowMultiple: false);
      var file = result?.files.first;
      if (file != null) {
        var f = File(file.path!);
        var bytes = await f.readAsBytes();
        var excel = exl.Excel.decodeBytes(bytes);
        var sheetName = excel.tables.keys.toList()[0];
        var sheet = excel[sheetName];
        var values = sheet.selectRangeValues(
            exl.CellIndex.indexByColumnRow(rowIndex: 1, columnIndex: 0),
            end: exl.CellIndex.indexByColumnRow(rowIndex: 6, columnIndex: 12));

        for (var element in values) {
          var val1 = (element![1] as exl.SharedString).toString();
          var val2 = (element[4] as exl.SharedString).toString();
          var r1 = DateFormat(val1.contains('-') ? 'yyyy-dd-MM' : 'MM/dd/yyyy')
              .parse(val1);
          var r2 = DateFormat(val2.contains('-') ? 'yyyy-dd-MM' : 'MM/dd/yyyy')
              .parse(val2);
        }
      }
    } catch (e) {
      showAlert(Get.context!, message: e.toString());
    }
  }

  onSelected(Import import) async {
    await showDialog(
        context: Get.context!,
        builder: (ctx) => AddImportModal(
            companyDetailsPage: companyDetailsPage,
            import: import,
            isEditing: true));
  }

  Widget get emptyContent {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.edit_document,
            size: 100, color: Theme.of(Get.context!).primaryColor)
      ],
    ));
  }

  Widget get content {
    int ix = 0;

    if (importController.imports.isEmpty) {
      return emptyContent;
    }
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(Get.context!).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Container(
                  height: colHeight,
                  decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.black12))),
                  alignment: Alignment.center,
                  child: Row(
                    children:
                        List.generate(importController.cols.length, (index) {
                      var item = importController.cols[index];
                      var endIndex = importController.cols.length - nn;

                      if (index >= nn) {
                        if (ix == endIndex) {
                          ix = endIndex;
                        } else {
                          ix++;
                        }
                      }

                      return Container(
                        width: colWidth,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            index >= nn
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        myformatter
                                            .formatEditUpdate(
                                                TextEditingValue.empty,
                                                TextEditingValue(
                                                    text: importController
                                                        .totals[ix - 1]
                                                        .toStringAsFixed(2)))
                                            .text,
                                        style: TextStyle(
                                            fontSize: kDefaultPadding),
                                      ),
                                      const SizedBox(height: 10)
                                    ],
                                  )
                                : Container(),
                            Text(item,
                                style: TextStyle(
                                    color: Theme.of(Get.context!).primaryColor,
                                    fontSize: kxDefaultFontSize * 0.9))
                          ],
                        ),
                      );
                    }),
                  )),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(Get.context!).size.height -
                            kToolbarHeight -
                            colHeight,
                        child: SingleChildScrollView(
                            child: Column(
                          children: List.generate(
                              importController.imports.length, (index) {
                            var item = importController.imports[index];
                            var values = item.toDisplay().values.toList();
                            return GestureDetector(
                              onDoubleTap: () => onSelected(item),
                              child: Container(
                                height: 60,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.black12))),
                                child: Row(
                                    children:
                                        List.generate(values.length, (index) {
                                  return Container(
                                    width: colWidth,
                                    padding: const EdgeInsets.all(10),
                                    child: Text(values[index],
                                        style: const TextStyle(fontSize: 18)),
                                  );
                                })),
                              ),
                            );
                          }),
                        )))
                  ],
                ),
              ))
            ],
          ),
        ));
  }

  Widget get loadingWidget {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
    );
  }

  bool isP = false;

  @override
  Widget build(BuildContext context) {
    importController = Get.put(ImportController(
        company: companyDetailsPage.company,
        startDate: companyDetailsPage.startDate,
        endDate: companyDetailsPage.endDate));
    return KeyboardListener(
        focusNode: importController.focusNode,
        onKeyEvent: (KeyEvent event) async {
          if (HardwareKeyboard.instance.isControlPressed &&
              event.logicalKey == LogicalKeyboardKey.keyV) {
            try {
              var c = Get.find<ImportController>();

              var c2 = Get.find<PurchasesController>();

              showLoader(context);

              var paymentDate =
                  await Import.importFromDgii(companyDetailsPage.company);

              if (paymentDate != null) {
                var start = paymentDate.startOfMonth();
                var end = paymentDate.endOfMonth();

                companyDetailsPage.startDate = start;
                companyDetailsPage.endDate = end;
                companyDetailsPage.controller2.date.value = TextEditingValue(
                    text:
                        '${start.format(payload: 'DD/MM/YYYY')} - ${end.format(payload: 'DD/MM/YYYY')}');
                c.dateRangeLabel.value =
                    '${start.format(payload: 'DD/MM/YYYY')} - ${end.format(payload: 'DD/MM//YYYY')}';

                await storage.write(
                    key: "STARTDATE_${companyDetailsPage.company.id}",
                    value: companyDetailsPage.startDateLargeAsString);
                await storage.write(
                    key: "ENDDATE_${companyDetailsPage.company.id}",
                    value: companyDetailsPage.endDateLargeAsString);

                var r = await Import.get(
                    company: companyDetailsPage.company,
                    startDate: companyDetailsPage.startDate,
                    endDate: companyDetailsPage.endDate);

                c.imports.value = r['result'];
                c.pdfBytes = r['pdfBytes'];

                c2.purchases.value = await Purchase.get(
                    companyId: companyDetailsPage.company.id!,
                    startDate: start,
                    endDate: end);
              }
              Navigator.pop(context);
            } catch (e) {
              Navigator.pop(context);
              showAlert(context, message: e.toString());
            }
          }
        },
        child: WindowBorder(
          color: kWindowBorderColor,
          width: 1,
          child: Scaffold(
            body: Column(
              children: [
                const CustomFrameWidgetDesktop(),
                Expanded(
                    child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Obx(() => Text(
                        'IMPORTACIONES DE ${companyDetailsPage.company.name?.toUpperCase()} ${importController.dateRangeLabel}')),
                    actions: [
                      Row(
                        children: [
                          Obx(() => SizedBox(
                                width: 50,
                                height: kToolbarHeight,
                                child: Center(
                                  child: Text(
                                    importController.imports.length.toString(),
                                    style: TextStyle(
                                        fontSize: kxDefaultFontSize,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                          ToolButton(
                              onTap: savePdf,
                              toolTip: 'GENERAR PDF',
                              icon: const Icon(Icons.picture_as_pdf)),
                          ToolButton(
                              onTap: () => Get.back(),
                              toolTip:
                                  'CERRAR LISTA DE IMPORTACIONES DE ${companyDetailsPage.company.name?.toUpperCase()}',
                              icon: const Icon(Icons.close)),
                        ],
                      )
                    ],
                  ),
                  body: Obx(() =>
                      importController.loading.value ? loadingWidget : content),
                ))
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: showModalOfImports,
              child: const Icon(Icons.add),
            ),
          ),
        ));
  }
}
