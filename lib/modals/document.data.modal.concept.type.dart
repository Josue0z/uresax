
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:path/path.dart' as path;

class DocumentModalForConceptType extends StatefulWidget {
  
  final BuildContext context;

  final Book book;

  final Sheet? currentSheet;

  ReportType reportType;

  ReportViewModelForConceptType reportViewModel;

  List<Purchase> purchases;

  DocumentModalForConceptType(
      {super.key,
      required this.context,
      this.purchases = const [],
      this.reportType = ReportType.month,
      required this.reportViewModel,
      this.currentSheet,
      required this.book});

  @override
  State<DocumentModalForConceptType> createState() => _DocumentModalState();
}

class _DocumentModalState extends State<DocumentModalForConceptType> {
  
  double offsetX1 = 0;

  double offsetX2 = 0;

  TextEditingController startYear = TextEditingController();

  TextEditingController endYear = TextEditingController();

  QueryContext queryContext = QueryContext.tax;

  String label = '';

  @override
  void initState() {
    setState(() {
      label = ncfsTypes[1]['NAME'];
      widget.reportViewModel.title = _title;
      offsetX1 = widget.reportViewModel.rangeValues!.start;
      offsetX2 = widget.reportViewModel.rangeValues!.end;
      startYear.value = TextEditingValue(text: offsetX1.toInt().toString());
      endYear.value = TextEditingValue(text: offsetX2.toInt().toString());
    });
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<bool> _onPopContext() async {
    try {
      await Purchase.dispose();
      return true;
    } catch (e) {
      showAlert(context, message: e.toString());
    }
    return false;
  }

  bool get isEmpty {
    return widget.reportViewModel.body.length == 1;
  }

  /* _print() async {
    try {
      if (widget.reportViewModel.body.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('NO TIENES FACTURAS')));
        return;
      }

      var result = await Printing.layoutPdf(
          format: PdfPageFormat.a4,
          onLayout: (PdfPageFormat format) async =>
              await widget.reportViewModel.pdf!.save());

      if (result) {
        ScaffoldMessenger.of(widget.context).showSnackBar(const SnackBar(
            content: Text('SE AGREGO EL DOCUMENTO A LA COLA DE IMPRESION')));
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }*/

  String get _title {
    if (widget.reportType == ReportType.month) {
      var a = months[widget.reportViewModel.rangeValues!.start.toInt() - 1];
      var b = months[widget.reportViewModel.rangeValues!.end.toInt() - 1];
      var c = 'C5 - $label - ${widget.book.companyName}';
      String t = '$c $a ${widget.book.year}';
      if (a == b) return t;
      t = '$a - $b ${widget.book.year}';
      return '$c $t';
    } else {
      String t = '$label - ${widget.book.companyName}';
      if (widget.reportViewModel.rangeValues!.start ==
          widget.reportViewModel.rangeValues!.end) {
        return '$t ${widget.reportViewModel.rangeValues!.start.toInt()}';
      }
      return '$t ${widget.reportViewModel.rangeValues!.start.toInt()} - ${widget.reportViewModel.rangeValues!.end.toInt()}';
    }
  }

  _save() async {
    try {
      if (isEmpty) {
        throw 'NO TIENES DATOS QUE GENERAR';
      }

      if (widget.reportViewModel.body.length > 1) {
        var filePath = path.join(
            Platform.environment['URESAX_STATIC_LOCAL_SERVER_PATH']!,
            'URESAX',
            widget.book.companyName?.trim(),
            widget.book.year.toString(),
            '606',
            '$_title.PDF');
        var file = File(filePath.trim());
        await file.create(recursive: true);
        await file.writeAsBytes(await widget.reportViewModel.pdf!.save());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('SE CREO EL REPORTE PDF'),
            action: SnackBarAction(
                label: 'ABRIR ARCHIVO',
                onPressed: () async {
                  await launchFile(filePath);
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

      var id = widget.book.id;

      widget.reportViewModel = await Purchase.getReportViewByConceptType(
          id: id!,
          start: v.start.toInt(),
          end: v.end.toInt(),
          queryContext: queryContext);

      widget.reportViewModel.rangeValues = v;
      widget.reportViewModel.rangeLabels =
          RangeLabels(months[v.start.toInt() - 1], months[v.end.toInt() - 1]);

      widget.reportViewModel.book = widget.book;

      widget.reportViewModel.start = v.start.toInt() - 1;
      widget.reportViewModel.end = v.end.toInt() - 1;


      widget.reportViewModel.pdf = pw.Document();

      widget.reportViewModel.title = _title;

     /* widget.reportViewModel.pdf
          ?.addPage(buildReportViewModel(widget.reportViewModel));*/
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _fecthReport() async {
    try {
      var start = int.tryParse(startYear.text);

      var end = int.tryParse(endYear.text);

      var id = widget.book.companyId;

      widget.reportViewModel = await Purchase.getReportViewByConceptType(
          reportType: ReportType.year,
          id: id!,
          start: start!,
          end: end!,
          queryContext: queryContext);

      widget.reportViewModel.rangeValues =
          RangeValues(start.toDouble(), end.toDouble());

      widget.reportViewModel.book = widget.book;

      widget.reportViewModel.pdf = pw.Document();

      widget.reportViewModel.title = _title;

      /*widget.reportViewModel.pdf
          ?.addPage(buildReportViewModel(widget.reportViewModel));*/
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  TableRow get _head {
    return TableRow(
        children: widget.reportViewModel.body[0]?.keys.map((key) {
      var index = widget.reportViewModel.body[0]?.keys.toList().indexOf(key);
      return TableCell(
          child: Padding(
        padding: EdgeInsets.only(left: index! > 0 ? 10 : 0),
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
      var index = widget.reportViewModel.body.indexOf(item);
      return TableRow(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.2)))),
          children: item!.entries.map((entry) {
            var j = item.values.toList().indexOf(entry.value);

            bool isTotal =
                j == 0 && index == widget.reportViewModel.body.length - 1;

            bool isFirstCol = j == 0;

            return TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10, bottom: 10, left: !isFirstCol ? 10 : 0),
                  child: Text(
                    entry.value ?? '\$0.00',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: isTotal ? FontWeight.w500 : null,
                        color: isTotal ? Theme.of(context).primaryColor : null),
                  ),
                ));
          }).toList());
    }).toList();
  }

  Widget get _viewData {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        Row(
          children: [
            Text(_title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor)),
            const Spacer(),
            SizedBox(
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
                          value: e['TIPO'] as QueryContext,
                          child: Text(e['NAME'])))
                      .toList(),
                  onChanged: (type) {
                    queryContext = type!;
                    label = ncfsTypes
                        .where((element) => element['TIPO'] == type)
                        .first['NAME'];
                    if (widget.reportType == ReportType.month) {
                      _onUpdate(widget.reportViewModel.rangeValues!);
                    } else {
                      _fecthReport();
                    }
                  }),
            ),
            const SizedBox(width: 15),
            /*IconButton(
                onPressed: _save,
                color: Theme.of(context).primaryColor,
                icon: const Icon(Icons.picture_as_pdf)),*/
            //const SizedBox(width: 15),
            IconButton(
                onPressed: () async {
                  if (await _onPopContext()) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.close))
          ],
        ),
        const SizedBox(height: 10),
        widget.reportType == ReportType.month
            ? SliderTheme(
                data:
                    SliderThemeData(overlayShape: SliderComponentShape.noThumb),
                child: RangeSlider(
                    min: 1,
                    max: 12,
                    divisions: 11,
                    values: RangeValues(offsetX1, offsetX2),
                    labels: widget.reportViewModel.rangeLabels,
                    onChanged: _onUpdate))
            : Row(
                children: _selectorYears,
              ),
        const SizedBox(height: 20),
        !isEmpty
            ? Wrap(
                children: [
                  Table(
                    columnWidths: const {0: FixedColumnWidth(350)},
                    children: [_head, ..._rows],
                  ),
                ],
              )
            : _emptyContainer
      ],
    );
  }

  List<Widget> get _selectorYears {
    return [
      SizedBox(
          width: 100,
          height: 30,
          child: TextFormField(
            controller: startYear,
            decoration: const InputDecoration(
                hintText: 'AÑO INCIAL',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.only(left: 5, right: 5)),
          )),
      const SizedBox(width: 10),
      SizedBox(
        width: 100,
        height: 30,
        child: TextFormField(
          controller: endYear,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'AÑO FINAL',
              contentPadding: EdgeInsets.only(left: 5, right: 5)),
        ),
      ),
      const SizedBox(width: 10),
      ElevatedButton(onPressed: _fecthReport, child: const Text('BUSCAR'))
    ];
  }

  Widget get _emptyContainer {
    return SizedBox(
      height: 178,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 60, color: Theme.of(context).primaryColor)
          ],
        ),
      ),
    );
  }

  Widget get _content {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
          content: SizedBox(
            width: 1300,
            child: Padding(padding: const EdgeInsets.all(10), child: _viewData),
          ),
        ));
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
