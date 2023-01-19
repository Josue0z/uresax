// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
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
import 'package:uresaxapp/utils/modals-actions.dart';

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
  int currentSheetIndex = -1;
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
        var result =
            await generate606(sheetId: current!.id, filePath: filePath);
        var arr = [
          [606, widget.book.companyRnc, current?.sheetDate, result.length]
        ];

        for (var item in result) {
          var values = item?.values.toList();

          for (int i = 0; i < values!.length; i++) {
            if (values[i] == null) values[i] = '';
          }

          arr.add(values);
        }
        var content =
            const ListToCsvConverter(fieldDelimiter: '|').convert(arr);

        await file.writeAsString(content);

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
    try {
      RawKeyboard.instance.removeListener(_handlerKeys);
      var result = await showDialog(
          context: context,
          builder: (ctx) =>
              AddPurchaseModal(book: widget.book, sheet: current!));
      RawKeyboard.instance.addListener(_handlerKeys);

      if (result['method'] == 'INSERT') {
        var data = await fetchDataBook(sheetId: current!.id);
        widget.invoicesLogs = data['invoicesLogs'];
        widget.invoices = data['invoices'];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'SE INSERTO LA FACTURA CON EL RNC: ${result['RNC']} Y EL NCF: ${result['NCF']}')));
        setState(() {});
      }
    } catch (_) {}
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
        currentSheetIndex = widget.sheets.indexOf(newSheet);
        stream.add(newSheet.id);
      }
    } catch (_) {}
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
        if (widget.sheets.isNotEmpty) {
          var sheet = widget.sheets.firstWhere((sheet) => sheet.id == sheetId);
          current = sheet;
        }
        widget.book.latestSheetVisited = sheetId;
        await widget.book.updateLatestSheetVisited();
        showLoader(context);
        var data =
            await fetchDataBook(bookId: widget.book.id!, sheetId: sheetId);
        widget.invoices = data['invoices'];
        widget.invoicesLogs = data['invoicesLogs'];
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pop(context);

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {});
    }
  }

  Future<void> _setCurrentSheet(Sheet sheet, int index) async {
    currentSheetIndex = index;
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
    } catch (_) {}
  }

  _setupScrollViews() {
    _horizontalScrollController.jumpTo(_scrollController.offset);
  }

  _selectInvoice(invoice) async {
    try {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'SE ELIMINO LA FACTURA CON EL RNC: ${result['invoice']['RNC']} Y EL NCF: ${result['invoice']['NCF']}')));
        setState(() {});
      }

      if (result['method'] == 'UPDATE') {
        var data =
            await fetchDataBook(bookId: widget.book.id!, sheetId: current!.id!);
        widget.invoices = data['invoices'];
        widget.invoicesLogs = data['invoicesLogs'];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'SE ACTUALIZO LA FACTURA CON EL RNC: ${result['RNC']} Y EL NCF: ${result['NCF']}')));
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  _deleteSheet() async {
    try {
      if (widget.sheets.isNotEmpty) {
        var isConfirm =
            await showConfirm(context, body: 'DESEAS ELIMINAR ESTA HOJA?');

        if (isConfirm!) {
          await Sheet(id: current!.id!).delete();
          widget.sheets.remove(current!);
          widget.book.latestSheetVisited = current!.id;

          if (currentSheetIndex == 0 && widget.sheets.isNotEmpty) {
            widget.book.latestSheetVisited =
                widget.sheets[currentSheetIndex].id;
            currentSheetIndex += 1;
          }
          if (currentSheetIndex >= 0 && widget.sheets.isNotEmpty) {
            currentSheetIndex -= 1;
            widget.book.latestSheetVisited =
                widget.sheets[currentSheetIndex].id;
          }

          stream.add(widget.book.latestSheetVisited);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    try {
      RawKeyboard.instance.addListener(_handlerKeys);
      stream.stream.listen(_onSheetChanged);
      _scrollController.addListener(_setupScrollViews);

      if (mounted) {
        current = widget.sheets
            .firstWhere((s) => s.id == widget.book.latestSheetVisited);
        currentSheetIndex = widget.sheets.indexOf(current!);
        setState(() {});
      }
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
    widget.book.updateBookUseStatus(false);
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
            style: const TextStyle(color: Colors.blue, fontSize: 17)),
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
                                        fontSize: 17,
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
          var index = widget.sheets.indexOf(sheet);
          return GestureDetector(
            onTap: () => _setCurrentSheet(sheet, index),
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
            IconButton(
                onPressed: _deleteSheet,
                icon: const Icon(Icons.delete),
                tooltip: 'ELIMINAR ESTA HOJA'),
            IconButton(onPressed: _generate606, icon: const Icon(Icons.save)),
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
