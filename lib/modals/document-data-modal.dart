// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uresaxapp/utils/modals-actions.dart';

class DocumentModal extends StatefulWidget {
  double start = 1;
  double end = 12;
  BuildContext context;
  final Book book;
  DocumentModal(
      {super.key,
      required this.context,
      required this.start,
      required this.end,
      required this.book});

  @override
  State<DocumentModal> createState() => _DocumentModalState();
}

class _DocumentModalState extends State<DocumentModal> {
  int startIndex = -1;
  int endIndex = -1;
  late RangeLabels rangeLabels;

  late RangeValues rangeValues;

  List<Map<String, dynamic>?> body = [];

  String taxServices = '';

  String taxGoods = '';

  Map<String, dynamic> footer = {};

  String totalGeneral = '';

  String totalTax = '';

  dynamic r;

  List<String?> values = [];

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
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0x0000000),
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
                padding: const pw.EdgeInsets.only(top: 10),
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
            pw.Text(_title, style: const pw.TextStyle(fontSize: 13)),
            pw.SizedBox(height: 20),
            pw.Table(
              columnWidths: {
                0: const pw.IntrinsicColumnWidth(),
                1: const pw.FixedColumnWidth(100),
                2: const pw.FixedColumnWidth(100),
                3: const pw.FixedColumnWidth(100),
                4: const pw.FixedColumnWidth(100),
                5: const pw.FixedColumnWidth(100)
              },
              children: [
                _dhead,
                ..._drows,
                pw.TableRow(
                    children: values
                        .map((e) => pw.Container(
                            padding: const pw.EdgeInsets.only(top: 10),
                            child: pw.Text(e ?? '\$0.00',
                                style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: values.indexOf(e) == 0
                                        ? pw.FontWeight.bold
                                        : null))))
                        .toList())
              ],
            ),
            pw.SizedBox(height: 20),
            pw.RichText(
                text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9),
                    children: [
                  pw.TextSpan(
                      text: 'ITBIS FACTURADO EN SERVICIOS: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: taxServices)
                ])),
            pw.SizedBox(height: 10),
            pw.RichText(
                text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9),
                    children: [
                  pw.TextSpan(
                      text: 'ITBIS FACTURADO EN BIENES: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: taxGoods)
                ])),
            pw.SizedBox(height: 10),
            pw.RichText(
                text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9),
                    children: [
                  pw.TextSpan(
                      text: 'TOTAL ITBIS FACTURADO: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: totalTax)
                ])),
            pw.SizedBox(height: 10),
            pw.RichText(
                text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9),
                    children: [
                  pw.TextSpan(
                      text: 'TOTAL FACTURADO: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: totalGeneral)
                ])),
          ],
        )); // Center
      })); // Page

      await Printing.layoutPdf(
          format: PdfPageFormat.standard,
          onLayout: (PdfPageFormat format) async => await pdf.save());

      ScaffoldMessenger.of(widget.context).showSnackBar(
          const SnackBar(content: Text('COMENZO LA IMPRESION DEL REPORTE')));
    } catch (e) {
      showAlert(context, message: e.toString());
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
    r = await Purchase.getReportViewForInvoiceType(
        id: widget.book.id!,
        start: widget.start.toInt(),
        end: widget.end.toInt());

    body = r.body;
    taxGoods = r.taxGood;
    taxServices = r.taxServices;
    totalGeneral = r.totalGeneral;
    totalTax = r.totalTax;
    footer = r.footer;
    values = ['TOTAL GENERAL', ...r.footer.values.toList()];
    footer = {};
    footer.addAll({'ITBIS EN SERVICIOS': taxServices});
    footer.addAll({'ITBIS EN BIENES': taxGoods});
    footer.addAll({'ITBIS RETENIDO': r.footer['ITBIS RETENIDO']});
    footer.addAll({'ISR RETENIDO': r.footer['ISR RETENIDO']});
    footer.addAll({'TOTAL ITBIS FACTURADO': r.footer['TOTAL ITBIS FACTURADO']});
    footer.addAll({'TOTAL EN SERVICIOS': r.footer['TOTAL EN SERVICIOS']});
    footer.addAll({'TOTAL EN BIENES': r.footer['TOTAL EN BIENES']});
    footer.addAll({'TOTAL GENERAL': totalGeneral});
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
    r = await Purchase.getReportViewForInvoiceType(
        id: widget.book.id!,
        start: widget.start.toInt(),
        end: widget.end.toInt());

    body = r.body;
    taxGoods = r.taxGood;
    totalTax = r.totalTax;
    taxServices = r.taxServices;
    totalGeneral = r.totalGeneral;
    values = ['TOTAL GENERAL', ...r.footer.values.toList()];
    footer = {};
    footer.addAll({'ITBIS EN SERVICIOS': taxServices});
    footer.addAll({'ITBIS EN BIENES': taxGoods});
    footer.addAll({'ITBIS RETENIDO': r.footer['ITBIS RETENIDO']});
    footer.addAll({'ISR RETENIDO': r.footer['ISR RETENIDO']});
    footer.addAll({'TOTAL ITBIS FACTURADO': r.footer['TOTAL ITBIS FACTURADO']});
    footer.addAll({'TOTAL EN SERVICIOS': r.footer['TOTAL EN SERVICIOS']});
    footer.addAll({'TOTAL EN BIENES': r.footer['TOTAL EN BIENES']});
    footer.addAll({'TOTAL GENERAL': totalGeneral});

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
            ))
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
        ? GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: GestureDetector(
                  onTap: (){},
                  child: Dialog(
                      child: SizedBox(
                          width: 1300,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      children: [
                                        Text(_title,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        const Spacer(),
                                        IconButton(
                                            onPressed: _print,
                                            color:
                                                Theme.of(context).primaryColor,
                                            icon: const Icon(Icons.print)),
                                        IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
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
                              )))),
                )),
          )
        : Container();
  }
}
