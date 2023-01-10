// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/apis/http-client.dart';
import 'package:uresaxapp/modals/add-purchase-modal.dart';
import 'package:uresaxapp/modals/add-sheet-modal.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:intl/intl.dart' as l;
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:path/path.dart' as path;

String _formatNumber(String value, String pattern) {
  int i = 0;
  var result = pattern.replaceAllMapped(RegExp('X'), (match) => value[i++]);
  return result;
}

class BookDetailsPage extends StatefulWidget {
  Book book;
  BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  List<Map<String, dynamic>> invoices = [];

  Sheet? current;
  String? currentId;

  late StreamController<String?> _stream;

  ScrollController _scrollController = ScrollController();
  ScrollController? _horizontalScrollController;
  ScrollController? _verticalScrollController;

  List<Sheet> _sheets = [];

  Map<String, dynamic> invoicesLogs = {};

  Widget? page;

  Sheet? get _latestSheet {
    return _sheets.isNotEmpty ? _sheets.last : null;
  }

  bool get _checkSheetLimit {
    return _sheets.length != 12;
  }

  String get _title {
    return '${widget.book.name!} RNC ${widget.book.companyRnc}';
  }

  String get _topTitle {
    if (current == null) return widget.book.bookTypeName!;
    return '${widget.book.bookTypeName!.toUpperCase()} ${_formatNumber(current!.sheetDate!, 'XXXX-XX')}';
  }

  _generate606() async {
    try {
      if (invoices.isNotEmpty) {
        var filePath =
            'c:\\URESAX\\${widget.book.companyRnc}\\${widget.book.year}\\606\\606_${_topTitle.toLowerCase()}.txt';
        var file = File(filePath);
        await file.create(recursive: true);
        await httpClient.post('/generate-606?sheetId=${current?.id}',
            data: {'FILE_PATH': filePath});
        var content = await file.readAsString();

        var l = invoices
            .where((e) => !((e['NCF'] as String).contains('B02')))
            .toList()
            .length;

        await file.writeAsString(
            '606|${widget.book.companyRnc}|${current?.sheetDate}|$l\n');
        await file.writeAsString(content, mode: FileMode.append);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL 606!'),
          action: SnackBarAction(
            label: 'ABRIR ARCHIVO',
            onPressed: () async {
              var dirPath = path.dirname(filePath);
              await launchFile(dirPath);
            },
          ),
        ));
      }
    } catch (e) {
      print(e);
    }
  }

  _showModalPurchase() async {
    RawKeyboard.instance.removeListener(_handlerKeys);
    var invoice = await showDialog(
        context: context,
        builder: (ctx) => AddPurchaseModal(book: widget.book, sheet: current!));
    RawKeyboard.instance.addListener(_handlerKeys);
    if (invoice != null) {
      invoicesLogs = await calcData(sheetId: current!.id);
      invoices = await Purchase.getPurchases(sheetId: current!.id!);
      setState(() {});
    }
  }

  _showModalSale() {}

  _showModalSheet() async {
    try {
      var newSheet = await showDialog<Sheet>(
          context: context,
          builder: (ctx) => AddSheetModal(
              book: widget.book, latestSheetInserted: _latestSheet));

      if (newSheet is Sheet) {
        _sheets.add(newSheet);
        _sheets.sort(((a, b) => a.sheetMonth! - b.sheetMonth!));
        _stream.add(newSheet.id);
      }
    } catch (e) {}
  }

  _showModal() {
    switch (widget.book.bookType) {
      case BookType.purchases:
        _showModalPurchase();
        break;
      case BookType.sales:
        _showModalSale();
        break;
      default:
    }
  }

  _moveRight() {
    var maxOffset = _scrollController.position.maxScrollExtent;
    var currentOffset = _scrollController.offset;

    if (currentOffset <= maxOffset) {
      _scrollController.jumpTo(_scrollController.offset + 50);
    }
  }

  _moveLeft() {
    var currentOffset = _scrollController.offset;
    if (currentOffset >= 0) {
      _scrollController.jumpTo(_scrollController.offset - 50);
    }
  }

  _moveUp() {
    _verticalScrollController?.jumpTo(_verticalScrollController!.offset - 50);
  }

  _moveDown() {
    _verticalScrollController?.jumpTo(_verticalScrollController!.offset + 50);
  }

  Future<void> _fecthPurchases(String sheetId) async {
    try {
      invoices = await Purchase.getPurchases(sheetId: sheetId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchSales(String sheetId) async {}

  Future<void> _requestsInvoices(String sheetId) async {
    try {
      invoicesLogs = await calcData(sheetId: sheetId);

      switch (widget.book.bookType!) {
        case BookType.purchases:
          await _fecthPurchases(sheetId);
          break;
        case BookType.sales:
          await _fetchSales(sheetId);
          break;
        default:
          break;
      }
    } catch (e) {
      invoices = [];
      invoicesLogs = {};
    } finally {
      setState(() {});
    }
  }

  Future<void> _onSheetChanged(String? sheetId) async {
    try {
      if (sheetId != null) {
        var sheet = _sheets.firstWhere((sheet) => sheet.id == sheetId);
        current = sheet;
        widget.book.latestSheetVisited = current!.id;
        await _requestsInvoices(sheetId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _setCurrentSheet(Sheet sheet) async {
    try {
      await widget.book.updateLatestSheetVisited(sheet.id!);
      _stream.add(sheet.id);
      _scrollController.jumpTo(0);
    } catch (e) {}
  }

  Future<void> _fetchSheets() async {
    _sheets = await Sheet.getSheetsByBookId(bookId: widget.book.id ?? '');
    _stream.add(widget.book.latestSheetVisited);
  }

  void _handlerKeys(RawKeyEvent value) {
    try {
      var key = value.logicalKey.keyId;

      if (key == LogicalKeyboardKey.arrowLeft.keyId) {
        _moveLeft();
      }
      if (key == LogicalKeyboardKey.arrowRight.keyId) {
        _moveRight();
      }

      if (key == LogicalKeyboardKey.arrowUp.keyId) {
        _moveUp();
      }
      if (key == LogicalKeyboardKey.arrowDown.keyId) {
        _moveDown();
      }
    } catch (e) {}
  }

  _setupScrollViews() {
    _horizontalScrollController?.jumpTo(_scrollController.offset);
  }

  @override
  void initState() {
    _fetchSheets();
    RawKeyboard.instance.addListener(_handlerKeys);
    _stream = StreamController();
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();
    _stream.stream.listen(_onSheetChanged);
    _scrollController.addListener(_setupScrollViews);
    super.initState();
  }

  @override
  void dispose() {
    invoices = [];
    invoicesLogs = {};
    _stream.close();
    _scrollController.dispose();
    _horizontalScrollController?.dispose();
    _verticalScrollController?.dispose();
    super.dispose();
  }

  Widget get _infoTop {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('TOTAL FACTURADO',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor)),
            Text(
                l.NumberFormat().format(
                        double.tryParse(invoicesLogs['TOTAL FACTURADO'])) ??
                    '0.00',
                style: const TextStyle(fontSize: 18, color: Colors.black54))
          ],
        ),
        const SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('TOTAL NETO FACTURADO',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor)),
            Text(
                l.NumberFormat().format(double.tryParse(
                        invoicesLogs['TOTAL NETO FACTURADO'])) ??
                    '0.00',
                style: const TextStyle(fontSize: 18, color: Colors.black54))
          ],
        ),
        const SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('ITBIS FACTURADO',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor)),
            Text(
                l.NumberFormat().format(double.tryParse(
                        invoicesLogs['TOTAL ITBIS FACTURADO'])) ??
                    '0.00',
                style: const TextStyle(fontSize: 18, color: Colors.black54))
          ],
        )
      ],
    );
  }

  Widget get _invoicesView {
    var invs = [...invoices];
    var columns = invs[0].keys.toList();
    columns.remove('id');
    columns = [invs.length.toString(), ...columns];
    var widgets = List.generate(columns.length, (index) {
      return Container(
        width: index == 0 ? 80 : 260,
        padding: const EdgeInsets.all(15),
        child: Text(columns[index],
            style: const TextStyle(color: Colors.blue, fontSize: 19)),
      );
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Text(_topTitle,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 24)),
                const Spacer(),
                _infoTop
              ],
            )),
        Container(
          height: 60,
          alignment: Alignment.center,
          child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                Row(children: [...widgets])
              ]),
        ),
        Expanded(
            child: SizedBox(
                child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _horizontalScrollController,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(invs.length, (i) {
                            var invoice = invs[i];
                            var values = invoice.entries.toList();
                            values = [MapEntry('', (i + 1)), ...values];
                            values.removeAt(1);
                            var widgets = List.generate(values.length, (j) {
                              var cell = values[j];
                              return GestureDetector(
                                onTap: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (ctx) => AddPurchaseModal(
                                          isEditing: true,
                                          book: widget.book,
                                          sheet: current!,
                                          invoice: invoice));
                                },
                                child: Container(
                                  width: j == 0 ? 80 : 260,
                                  color: Colors.grey.withOpacity(0.09),
                                  padding: const EdgeInsets.all(15),
                                  child: Text(
                                    cell.value == null || cell.value == ''
                                        ? 'NINGUNO'
                                        : cell.value.toString(),
                                    style: const TextStyle(
                                        fontSize: 19,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              );
                            });
                            return Column(
                              children: [
                                Row(children: widgets),
                                Container(height: 5, color: Colors.grey)
                              ],
                            );
                          })),
                    ))))
      ],
    );
  }

  Widget get _bottomBar {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.2),
          border:
              const Border(top: BorderSide(color: Colors.grey, width: 0.5))),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _sheets.map((sheet) {
          var isCurrent = widget.book.latestSheetVisited == sheet.id;
          return GestureDetector(
            onTap: () => _setCurrentSheet(sheet),
            child: AnimatedContainer(
                decoration: BoxDecoration(
                    color: isCurrent ? Colors.blue : Colors.transparent,
                    border: Border.symmetric(
                        vertical: BorderSide(
                            width: 0.5,
                            color:
                                isCurrent ? Colors.transparent : Colors.grey))),
                duration: const Duration(milliseconds: 150),
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Text(sheet.sheetDate!,
                        style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.black45,
                            fontSize: 17,
                            fontWeight: FontWeight.w500)))),
          );
        }).toList(),
      ),
    );
  }

  Widget get _emptyContainer {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined,
              color: Theme.of(context).primaryColor, size: 100)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
          actions: [
            IconButton(onPressed: _generate606, icon: const Icon(Icons.save))
          ],
        ),
        body: invoices.isNotEmpty ? _invoicesView : _emptyContainer,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
                heroTag: null,
                tooltip: _sheets.isEmpty
                    ? 'AÑADE UNA HOJA PRIMERO'
                    : 'AÑADIR FACTURA DE ${widget.book.bookTypeName}',
                onPressed: _sheets.isNotEmpty ? _showModal : null,
                child: const Icon(Icons.insert_drive_file_outlined)),
            const SizedBox(width: 10),
            FloatingActionButton(
                heroTag: null,
                tooltip: _checkSheetLimit
                    ? 'AÑADIR HOJA'
                    : 'YA NO SE PUEDE AÑADIR MAS MESES PARA ESTE LIBRO',
                onPressed: _checkSheetLimit ? _showModalSheet : null,
                child: const Icon(Icons.add))
          ],
        ),
        bottomNavigationBar: _bottomBar);
  }
}
