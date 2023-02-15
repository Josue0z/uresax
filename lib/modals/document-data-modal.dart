import 'package:flutter/material.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/purchase.dart';

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

  List<Map<String, dynamic>?> data = [];

  Map<String, dynamic>? headdata = {};

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

  _onUpdate(v) async {
    setState(() {
      rangeValues = v;
      rangeLabels =
          RangeLabels(months[v.start.toInt() - 1], months[v.end.toInt() - 1]);
      widget.start = v.start;
      widget.end = v.end;
    });
    data = await Purchase.getReportViewForInvoiceType(
        id: widget.book.id!,
        start: widget.start.toInt(),
        end: widget.end.toInt()) as dynamic;

    setState(() {});
  }

  TableRow get _head {
    return TableRow(
        children: data[0]!.keys.map((key) {
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
    return data.map((item) {
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
                    entry.value,
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
    data = await Purchase.getReportViewForInvoiceType(
        id: widget.book.id!,
        start: widget.start.toInt(),
        end: widget.end.toInt()) as dynamic;

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
        _infoWidget,
        const SizedBox(height: 20),
        Table(
          children: [_head, ..._rows],
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
    var c = '${widget.book.companyName} ${widget.book.year}';
    String t = '$c $a';
    if (a == b) return t;
    t = '$a - $b';
    return '$c $t';
  }

  Widget get _infoWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: headdata!.entries.map((e) {
        return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.key,
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500)),
                Text(
                  e.value.toString(),
                  style: const TextStyle(fontSize: 15),
                )
              ],
            ));
      }).toList(),
    );
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
                        data.isNotEmpty ? _viewData : Container()
                      ],
                    ))),
          )
        : Container();
  }
}
