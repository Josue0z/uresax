import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class DocumentModal extends StatefulWidget {
  double start = 1;
  double end = 12;
  final Book book;
  DocumentModal(
      {super.key, required this.start, required this.end, required this.book});

  @override
  State<DocumentModal> createState() => _DocumentModalState();
}

class _DocumentModalState extends State<DocumentModal> {
  int startIndex = -1;
  int endIndex = -1;
  late RangeLabels rangeLabels;

  late RangeValues rangeValues;

  List<Map<String, dynamic>?> body = [];

  Map<String, dynamic> taxServices = {};

  Map<String, dynamic> taxGoods = {};

  Map<String, dynamic> footer = {};

  String totalGeneral = '';

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

  bool isLoading = false;

  get _dhead {
    return pw.TableRow(
        children: body[0]!.keys.map((key) {
      return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              key,
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColor.fromInt(0x0000000),
              ),
            ),
          ]);
    }).toList());
  }

  get _drows {
    return body.map((item) {
      return pw.TableRow(
          children: item!.entries.map((entry) {
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Text(entry.value ?? '\$0.00',
                    style: const pw.TextStyle(fontSize: 8)),
              )
            ]);
      }).toList());
    }).toList();
  }

  _print() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
            child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_title,
                style: const pw.TextStyle(
                    fontSize: 14, color: PdfColor.fromInt(0x000000))),
            pw.SizedBox(height: 20),
            pw.Table(
              children: [
                _dhead,
                ..._drows,
                pw.TableRow(
                    children: ['TOTAL GENERAL', ...footer.values.toList()]
                        .map((e) => pw.Container(
                            child: pw.Text(e ?? '\$0.00',
                                style: const pw.TextStyle(fontSize: 8))))
                        .toList())
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'ITBIS FACTURADO EN SERVICIOS: ${taxServices['ITBIS FACTURADO EN SERVICIOS'] ?? '\$0.00'}',
                style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 10),
            pw.Text(
                'ITBIS FACTURADO EN BIENES: ${taxGoods['ITBIS FACTURADO EN BIENES'] ?? '\$0.00'}',
                style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 10),
            pw.Text('TOTAL FACTURADO: $totalGeneral',
                style: const pw.TextStyle(fontSize: 9))
          ],
        )); // Center
      })); // Page

      await Printing.layoutPdf(
          format: PdfPageFormat.standard,
          onLayout: (PdfPageFormat format) async => await pdf.save());
    } catch (e) {
      print(e);
    }
  }

  _onUpdate(v) async {
    setState(() {
      rangeValues = v;
      rangeLabels =
          RangeLabels(months[v.start.toInt() - 1], months[v.end.toInt() - 1]);
      widget.start = v.start;
      widget.end = v.end;
    });
    var r = await Purchase.getReportViewForInvoiceType(
        id: widget.book.id!,
        start: widget.start.toInt(),
        end: widget.end.toInt());

    body = r.body;
    taxGoods = r.taxGood;
    taxServices = r.taxServices;
    totalGeneral = r.totalGeneral;
    footer = r.footer;
    setState(() {});
  }

  TableRow get _head {
    return TableRow(
        children: body[0]!.keys.map((key) {
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
    return body.map((item) {
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

  _init() async {
    setState(() {
      isLoading = true;
      startIndex = widget.start.toInt() - 1;
      endIndex = widget.end.toInt() - 1;
      rangeValues = RangeValues(widget.start, widget.end);
      rangeLabels = RangeLabels(months[startIndex], months[endIndex]);
    });
    var r = await Purchase.getReportViewForInvoiceType(
        id: widget.book.id!,
        start: widget.start.toInt(),
        end: widget.end.toInt());

    body = r.body;
    footer = r.footer;
    taxGoods = r.taxGood;
    taxServices = r.taxServices;
    totalGeneral = r.totalGeneral;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (mounted) {
      _init();
    }
    super.initState();
  }

  Widget get _viewData {
    var entries = [...footer.entries];
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        // const SizedBox(height: 15),
        Table(
          children: [_head, ..._rows],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: footer.entries
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
        )
      ],
    );
  }

  Widget get _viewEmpty {
    return SizedBox(
      height: 325,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner,
                size: 100, color: Theme.of(context).primaryColor)
          ],
        ),
      ),
    );
  }

  String get _title {
    var a = months[widget.start.toInt() - 1];
    var b = months[widget.end.toInt() - 1];
    var c = '${widget.book.companyName}';
    String t = '$c $a ${widget.book.year}';
    if (a == b) return t;
    t = '$a - $b ${widget.book.year}';
    return '$c $t';
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Dialog(
            child: SizedBox(
                width: 1200,
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
                              IconButton(
                                  onPressed: _print,
                                  icon: const Icon(Icons.print)),
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
                            values: rangeValues,
                            labels: rangeLabels,
                            onChanged: _onUpdate),
                        body.isNotEmpty ? _viewData : Container()
                      ],
                    ))),
          )
        : Container();
  }
}
