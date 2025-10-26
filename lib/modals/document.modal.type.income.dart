// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:path/path.dart' as path;
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class DocumentModal extends StatefulWidget {
  final BuildContext context;

  final String customTitle;

  CompanyDetailsPage companyDetailsPage;

  Map<String, dynamic> reportViewModel;

  Function generateXlsx;

  Function? generatePdf;

  Function onUpdate;

  String formatType;

  DocumentModal(
      {super.key,
      this.customTitle = '',
      this.formatType = '606',
      this.generatePdf,
      required this.generateXlsx,
      required this.onUpdate,
      required this.context,
      required this.companyDetailsPage,
      required this.reportViewModel});

  @override
  State<DocumentModal> createState() => _DocumentModalState();
}

class _DocumentModalState extends State<DocumentModal> {
  List<Map<String, dynamic>> ncfsTypes = [
    {'TYPE': QueryContext.general, 'NAME': 'REPORTE GENERAL'},
    {'TYPE': QueryContext.tax, 'NAME': 'REPORTE FISCAL'},
    {'TYPE': QueryContext.consumption, 'NAME': 'REPORTE DE CONSUMO'}
  ];

  QueryContext queryContext = QueryContext.tax;

  String reportName = '';

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    setState(() {
      reportName = ncfsTypes[1]['NAME'];
    });
    super.initState();
  }

  List<Map<String, dynamic>> get data {
    return widget.reportViewModel['data'];
  }

  bool get isEmpty {
    return data.length == 1;
  }

  String get title {
    return '$reportName - ${widget.companyDetailsPage.company.name}  ${widget.companyDetailsPage.startDateAsString.replaceAll('/', '-')} - ${widget.companyDetailsPage.endDateAsString.replaceAll('/', '-')}';
  }

  String get fileName {
    return '${widget.customTitle}${widget.companyDetailsPage.company.name} $yearPeriod';
  }

  String get yearPeriod {
    return widget.companyDetailsPage.startDate.format(payload: 'YYYY');
  }

  Directory get directory {
    return Directory(path.join(
        dirUresaxPath ?? '',
        'URESAX',
        widget.companyDetailsPage.company.name!.trim(),
        yearPeriod,
        widget.formatType));
  }

  String get filePath {
    return path.join(directory.path, fileName);
  }

  showViewer() async {
    try {
      var result = await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async =>
              widget.reportViewModel['pdfBytes']);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('COMENZO LA IMPRESION...')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SE CANCELO LA IMPRESION...')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  saveXlsx() {
    widget.generateXlsx(widget.reportViewModel, title, widget.customTitle,
        filePath, directory.path);
  }

  savePdf() {
    widget.generatePdf!(widget.reportViewModel, title, widget.customTitle,
        filePath, reportName, directory.path);
  }

  onUpdate() async {
    await widget.onUpdate(filePath, widget, reportName, queryContext);
    setState(() {});
  }

  Widget get footerWidget {
    if (widget.reportViewModel['footer'] == null) return Container();

    var entries = widget.reportViewModel['footer'].entries;
    var list = entries.toList();

    dynamic col1, col2, col3 = [];

    if (widget.companyDetailsPage.formType == FormType.form606) {
      col1 = list.take(3);
      col2 = list.skip(3).take(3);
      col3 = list.skip(6).take(4);
    }

    if (widget.companyDetailsPage.formType == FormType.form607) {
      col1 = list.take(3);
      col2 = list.skip(3).take(3);
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: col1
                    .map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor)),
                            const SizedBox(height: 12),
                            Text(e.value ?? '\$0.00',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87))
                          ],
                        )))
                    .toList()
                    .cast<Widget>()),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: col2
                    .map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor)),
                            const SizedBox(height: 12),
                            Text(e.value ?? '\$0.00',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87))
                          ],
                        )))
                    .toList()
                    .cast<Widget>()),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: col3
                    .map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor)),
                            const SizedBox(height: 12),
                            Text(e.value ?? '\$0.00',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87))
                          ],
                        )))
                    .toList()
                    .cast<Widget>()),
          ],
        ),
        const SizedBox(height: 12)
      ],
    );
  }

  Widget get _viewData {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: List.generate(data.length, (index) {
                                    var item = data[index];
                                    var entries = item.entries.toList();
                                    return Column(
                                      children: [
                                        Row(
                                            children: List.generate(
                                                entries.length, (i) {
                                          var entry = entries[i];
                                          var color = i == 0
                                              ? Colors.white
                                              : Colors.black;
                                          var w = i == 0
                                              ? FontWeight.w500
                                              : FontWeight.normal;

                                          var ww = i == 0 ? 350.00 : 290.00;
                                          var g = i == 0;
                                          return Container(
                                            width: ww,
                                            height: 90,
                                            padding: i == 0
                                                ? const EdgeInsets.all(12)
                                                : const EdgeInsets.all(10),
                                            margin: const EdgeInsets.only(
                                                right: 20, bottom: 20),
                                            decoration: BoxDecoration(
                                                color: i == 0
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : const Color.fromARGB(
                                                        255, 247, 245, 245),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              crossAxisAlignment: g
                                                  ? CrossAxisAlignment.center
                                                  : CrossAxisAlignment.start,
                                              mainAxisAlignment: i > 0
                                                  ? MainAxisAlignment.start
                                                  : MainAxisAlignment.center,
                                              children: [
                                                i > 0
                                                    ? const SizedBox(height: 10)
                                                    : Container(),
                                                i > 0
                                                    ? Text(
                                                        entry.key,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      )
                                                    : Container(),
                                                const SizedBox(height: 10),
                                                Text(entry.value ?? '\$0.00',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: w,
                                                        color: color))
                                              ],
                                            ),
                                          );
                                        })),
                                      ],
                                    );
                                  }),
                                ),
                                footerWidget
                              ],
                            ),
                          ],
                        ))))));
  }

  Widget get _content {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: kToolbarHeight + 25,
          backgroundColor: Colors.transparent,
          title: Text(title,
              style: TextStyle(color: Theme.of(context).primaryColor)),
          actions: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 250,
                child: DropdownButtonFormField<QueryContext>(
                    value: queryContext,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        //<-- SEE HERE
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        //<-- SEE HERE
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                    items: ncfsTypes
                        .map((e) => DropdownMenuItem(
                            value: e['TYPE'] as QueryContext,
                            child: Text(e['NAME'])))
                        .toList(),
                    onChanged: (type) {
                      queryContext = type!;
                      reportName = ncfsTypes
                          .where((element) => element['TYPE'] == type)
                          .first['NAME'];
                      onUpdate();
                    }),
              ),
            ),
            const SizedBox(width: 15),
            IconButton(
                onPressed: saveXlsx,
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.calculate)),
            widget.generatePdf != null
                ? Row(
                    children: [
                      const SizedBox(width: 15),
                      IconButton(
                          onPressed: savePdf,
                          color: Theme.of(context).primaryColor,
                          icon: const Icon(Icons.picture_as_pdf)),
                      const SizedBox(width: 15),
                      IconButton(
                          onPressed: showViewer,
                          color: Theme.of(context).primaryColor,
                          icon: const Icon(Icons.print)),
                    ],
                  )
                : Container(),
            const SizedBox(width: 15),
            IconButton(
                color: Colors.grey,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
            const SizedBox(width: 15),
          ],
        ),
        body: _viewData);
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: SelectableRegion(
                selectionControls: materialTextSelectionControls,
                child: _content)));
  }
}
