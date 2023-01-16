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
  List<Sheet> sheets = [];
  var invoices = [];
  var invoicesLogs = {};
  BookDetailsPage(
      {super.key,
      required this.book,
      required this.invoices,
      required this.invoicesLogs,
      required this.sheets});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  Sheet? current;
  late StreamController<String?> stream = StreamController();

  final ScrollController _scrollController = ScrollController();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  Map<String, dynamic> invoicesLogs = {};

  Sheet? get _latestSheet {
    return widget.sheets.isNotEmpty ? widget.sheets.last : null;
  }

  bool get _checkSheetLimit {
    return widget.sheets.length != 12;
  }

  String get _title {
    return '${widget.book.name!} RNC ${widget.book.companyRnc} $_topTitle';
  }

  String get _topTitle {
    if (current == null) return widget.book.bookTypeName!;
    return '${widget.book.bookTypeName!.toUpperCase()} ${_formatNumber(current!.sheetDate!, 'XXXX-XX')}';
  }

  String get _date {
    return _formatNumber(current!.sheetDate!, 'XXXXXX');
  }

  _moveLeft() {
    var currentOffset = _scrollController.offset;
    if (currentOffset >= 0) {
      _scrollController.jumpTo(_scrollController.offset - 50);
    }
  }

  _moveUp() {
    _verticalScrollController.jumpTo(_verticalScrollController.offset - 50);
  }

  _moveDown() {
    _verticalScrollController.jumpTo(_verticalScrollController.offset + 50);
  }

  _generate606() async {
    try {
      if (widget.invoices.isNotEmpty) {
        var filePath =
            'c:\\URESAX\\${widget.book.companyRnc}\\${widget.book.year}\\606\\DGII_F_606_${widget.book.companyRnc}_$_date.TXT';
        var file = File(filePath);
        await file.create(recursive: true);
        await httpClient.post('/generate-606?sheetId=${current?.id}',
            data: {'FILE_PATH': filePath});
        var content = await file.readAsString();

        var l = widget.invoices
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
    var result = await showDialog(
        context: context,
        builder: (ctx) => AddPurchaseModal(book: widget.book, sheet: current!));
    RawKeyboard.instance.addListener(_handlerKeys);

    if (result != null) {
      var data = await fetchDataBook(sheetId: current!.id);
      widget.invoicesLogs = data['invoicesLogs'];
      widget.invoices = data['invoices'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('SE INSERTO LA FACTURA CON EL RNC: ${result['RNC']} Y EL NCF: ${result['NCF']}')));
      setState(() {});
    }
  }

  _showModalSheet() async {
    try {
      var newSheet = await showDialog<Sheet>(
          context: context,
          builder: (ctx) => AddSheetModal(
              book: widget.book, latestSheetInserted: _latestSheet));

      if (newSheet is Sheet) {
        widget.sheets.add(newSheet);
        widget.sheets.sort(((a, b) => a.sheetMonth! - b.sheetMonth!));
        stream.add(newSheet.id);
      }
    } catch (e) {}
  }

  _showModal() {
    _showModalPurchase();
  }

  _moveRight() {
    var maxOffset = _scrollController.position.maxScrollExtent;
    var currentOffset = _scrollController.offset;

    if (currentOffset <= maxOffset) {
      _scrollController.jumpTo(_scrollController.offset + 50);
    }
  }

  Future<void> _onSheetChanged(String? sheetId) async {
    try {
      if (sheetId != null) {
        var sheet = widget.sheets.firstWhere((sheet) => sheet.id == sheetId);
        current = sheet;
        widget.book.latestSheetVisited = sheetId;
        await widget.book.updateLatestSheetVisited(sheetId);
        showLoader(context);
        var data = await fetchDataBook(bookId: widget.book.id!, sheetId: sheetId);
        widget.invoices = data['invoices'];
        widget.invoicesLogs = data['invoicesLogs'];
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pop(context);
        _scrollController.jumpTo(0);
      }
    } catch (_) {
    } finally {
      setState(() {});
    }
  }

  Future<void> _setCurrentSheet(Sheet sheet) async {
    stream.add(sheet.id);
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
    _horizontalScrollController.jumpTo(_scrollController.offset);
  }

  _selectInvoice(invoice) async {
    var result = await showDialog(
        context: context,
        builder: (ctx) => AddPurchaseModal(
            book: widget.book,
            sheet: current!,
            invoice: invoice,
            isEditing: true));

    if (result['method'] == 'DELETE') {
      var data =
          await fetchDataBook(bookId: widget.book.id!, sheetId: current!.id!);
      widget.invoices = data['invoices'];
      widget.invoicesLogs = data['invoicesLogs'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SE ELIMINO LA FACTURA CON EL RNC: ${result['invoice']['RNC']} Y EL NCF: ${result['invoice']['NCF']}')));
      setState(() {});
    }
  }

  @override
  void initState() {
    try {
      if (widget.sheets.isNotEmpty) {
        var sheet = widget.sheets
            .firstWhere((sheet) => sheet.id == widget.book.latestSheetVisited);
        current = sheet;
      }
      RawKeyboard.instance.addListener(_handlerKeys);
      stream.stream.listen(_onSheetChanged);
      _scrollController.addListener(_setupScrollViews);
    } catch (e) {}
    super.initState();
  }

  @override
  void dispose() {
    widget.invoices = [];
    widget.invoicesLogs = {};
    widget.sheets = [];
    stream.close();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  Widget get _infoTop {
    return ListView(
        scrollDirection: Axis.horizontal,
        children: widget.invoicesLogs.keys.map((key) {
          var val = widget.invoicesLogs[key];
          return Container(
            margin: const EdgeInsets.only(left: 30, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(key,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor)),
                Text(l.NumberFormat().format(double.tryParse(val ?? 'b')),
                    style: const TextStyle(fontSize: 18, color: Colors.black54))
              ],
            ),
          );
        }).toList());
  }

  Widget get _invoicesView {
    var invs = [...widget.invoices];
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
        SizedBox(height: 80, child: _infoTop),
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
                                onTap: () => _selectInvoice(invoice),
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
        children: widget.sheets.map((sheet) {
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
        body: widget.invoices.isNotEmpty ? _invoicesView : _emptyContainer,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
                heroTag: null,
                tooltip: widget.sheets.isEmpty
                    ? 'AÑADE UNA HOJA PRIMERO'
                    : 'AÑADIR FACTURA DE ${widget.book.bookTypeName}',
                onPressed: widget.sheets.isNotEmpty ? _showModal : null,
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
