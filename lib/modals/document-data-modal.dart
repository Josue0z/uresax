// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:path/path.dart' as path;

class DocumentModal extends StatefulWidget {
  final BuildContext context;

  final Book book;

  final Sheet? currentSheet;

  ReportViewModel reportViewModel;

  List<Purchase> purchases;

  DocumentModal(
      {super.key,
      required this.context,
      this.purchases = const [],
      required this.reportViewModel,
      required this.currentSheet,
      required this.book});

  @override
  State<DocumentModal> createState() => _DocumentModalState();
}

class _DocumentModalState extends State<DocumentModal> {
  double offsetX1 = 0;
  double offsetX2 = 0;

  _print() async {
    try {
      if (widget.reportViewModel.body.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('NO TIENES FACTURAS')));
        return;
      }

      var result = await Printing.layoutPdf(
          format: PdfPageFormat.standard,
          onLayout: (PdfPageFormat format) async =>
              await widget.reportViewModel.pdf!.save());

      if (result) {
        ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
            content: Text('SE AGREGO EL DOCUMENTO A LA COLA DE IMPRESION')));
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  String get _title {
    return buildReportTitle(
        widget.reportViewModel.rangeValues!.start.toInt() - 1,
        widget.reportViewModel.rangeValues!.end.toInt() - 1,
        widget.book);
  }

  _save() async {
    try {
      if (widget.reportViewModel.body.isNotEmpty) {
        var filePath = path.join(
            Platform.environment['URESAX_STATIC_LOCAL_SERVER_PATH']!,
            'URESAX',
            widget.book.companyName?.trim(),
            widget.book.year.toString(),
            '606',
            '$_title.PDF');
        var file = File(filePath);
        await file.writeAsBytes(await widget.reportViewModel.pdf!.save());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('SE CREO EL REPORTE PDF'),
            action: SnackBarAction(
                label: 'ABRIR ARCHIVO',
                onPressed: () async {
                  await launchFile(path.dirname(filePath));
                })));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  _onUpdate(RangeValues v) async {
    try {
      setState(() {
        offsetX1 = v.start;
        offsetX2 = v.end;
      });
      widget.reportViewModel = await Purchase.getReportViewForInvoiceType(
          id: widget.book.id!, start: v.start.toInt(), end: v.end.toInt());

      widget.reportViewModel.rangeValues = v;
      widget.reportViewModel.rangeLabels =
          RangeLabels(months[v.start.toInt() - 1], months[v.end.toInt() - 1]);

      widget.reportViewModel.book = widget.book;

      widget.reportViewModel.start = v.start.toInt() - 1;
      widget.reportViewModel.end = v.end.toInt() - 1;


      var footer = {...widget.reportViewModel.footer};

      widget.reportViewModel.footer = {};
      widget.reportViewModel.footer
          .addAll({'ITBIS EN SERVICIOS': widget.reportViewModel.taxServices});

      widget.reportViewModel.footer
          .addAll({'ITBIS EN BIENES': widget.reportViewModel.taxGood});
   

      widget.reportViewModel.pdf = pw.Document();

      widget.reportViewModel.pdf
          ?.addPage(buildReportViewModel(widget.reportViewModel));
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  TableRow get _head {
    return TableRow(
        children: widget.reportViewModel.body[0]?.keys.map((key) {
      return TableCell(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          key,
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500),
        ),
      ));
    }).toList());
  }

  List<TableRow> get _rows {
    return widget.reportViewModel.body.map((item) {
      return TableRow(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.2)))),
          children: item!.entries.map((entry) {
            return TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    entry.value ?? '\$0.00',
                    style: const TextStyle(fontSize: 16),
                  ),
                ));
          }).toList());
    }).toList();
  }

  @override
  void initState() {
    setState(() {
      offsetX1 = widget.reportViewModel.rangeValues!.start;
      offsetX2 = widget.reportViewModel.rangeValues!.end;
    });
    super.initState();
  }

  Widget get _viewData {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Table(
          children: [_head, ..._rows],
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.reportViewModel.footer.entries
                  .map((e) => Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor)),
                          const SizedBox(height: 20),
                          Text(e.value ?? '\$0.00',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87))
                        ],
                      )))
                  .toList(),
            ))
      ],
    );
  }

  Widget get _content {
    return Dialog(
      child: SizedBox(
          width: 1300,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(_title,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor)),
                        const Spacer(),
                        /*IconButton(
                            onPressed: _print,
                            color: Theme.of(context).primaryColor,
                            icon: const Icon(Icons.print)),*/
                        IconButton(
                            onPressed: _save,
                            color: Theme.of(context).primaryColor,
                            icon: const Icon(Icons.picture_as_pdf)),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close))
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  RangeSlider(
                      min: 1,
                      max: 12,
                      divisions: 11,
                      values: RangeValues(offsetX1, offsetX2),
                      labels: widget.reportViewModel.rangeLabels,
                      onChanged: _onUpdate),
                  widget.reportViewModel.body.isNotEmpty
                      ? _viewData
                      : Container()
                ],
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () {},
            child: _content,
          )),
    );
  }
}
