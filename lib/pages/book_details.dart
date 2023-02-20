// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/modals/add-purchase-modal.dart';
import 'package:uresaxapp/modals/add-sheet-modal.dart';
import 'package:uresaxapp/modals/document-data-modal.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/companies_page.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:path/path.dart' as path;
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:window_manager/window_manager.dart';

class ShowPurchaseModalIntent extends Intent {
  final String name;
  const ShowPurchaseModalIntent({required this.name});
}

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
String _formatNumber(String value, String pattern) {
  int i = 0;
  var result = pattern.replaceAllMapped(RegExp('X'), (match) => value[i++]);
  return result;
}

class BookDetailsPage extends StatefulWidget {
  Book book;
  Sheet? currentSheet;
  List<Sheet> sheets = [];
  List<Purchase> purchases = [];
  var invoicesLogs = {};
  int currentSheetIndex;
  BookDetailsPage(
      {super.key,
      this.currentSheet,
      this.currentSheetIndex = -1,
      required this.book,
      required this.purchases,
      required this.invoicesLogs,
      required this.sheets});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> with WindowListener {
  late StreamController<String?> stream = StreamController();

  final ScrollController _scrollController = ScrollController();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  Sheet? oldSheet;

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
    if (widget.currentSheet == null) return widget.book.bookTypeName ?? '';
    return '${widget.book.bookTypeName!.toUpperCase()} ${_formatNumber(widget.currentSheet!.sheetDate!, 'XXXX-XX')}';
  }

  void _handlerKeys(RawKeyEvent value) {
    try {
      var key = value.logicalKey.keyId;

      if (value.isControlPressed) {
        if (key == LogicalKeyboardKey.keyN.keyId) {
          _showModalPurchase();
        }
        if (key == LogicalKeyboardKey.keyS.keyId) {
          _generate606();
        }
      }

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
      var purchases = [...widget.purchases];
      purchases.removeWhere((element) =>
          element.invoiceNcfTypeId == 2 || element.invoiceNcfTypeId == 32);

      var elements = purchases.map((e) => e.to606()).toList();

      if (purchases.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NO TIENES FACTURAS EN ESTA HOJA'),
        ));
        return;
      }

      List<List<dynamic>> rows = [];

      for (int i = 0; i < elements.length; i++) {
        var item = elements[i];
        var values = item.values.toList();
        rows.add(values);
      }
      var result = const ListToCsvConverter().convert([
        [
          606,
          widget.book.companyRnc,
          widget.currentSheet?.sheetDate,
          purchases.length
        ],
        ...rows
      ], fieldDelimiter: '|');

      var filePath = path.join(
          Platform.environment['URESAX_STATIC_LOCAL_SERVER_PATH']!,
          'URESAX',
          widget.book.companyName?.trim(),
          widget.book.year.toString(),
          '606',
          'DGII_F_606_${widget.book.companyRnc}_${widget.currentSheet?.sheetDate}.TXT');

      var file = File(filePath.trim());

      await file.create(recursive: true);

      await file.writeAsString(result);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL 606'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                var dirPath = path.dirname(file.path);
                launchFile(dirPath);
              })));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    return;
  }

  _showModalPurchase() async {
    try {
      RawKeyboard.instance.removeListener(_handlerKeys);
      var result = await showDialog(
          context: context,
          builder: (ctx) =>
              AddPurchaseModal(book: widget.book, sheet: widget.currentSheet!));
      RawKeyboard.instance.addListener(_handlerKeys);

      if (result['method'] == 'INSERT') {
        var purchase = result['data'] as Purchase;
        widget.purchases = await widget.currentSheet?.getPurchases() ?? [];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'SE INSERTO LA FACTURA CON EL RNC: ${purchase.invoiceRnc} Y EL NCF: ${purchase.invoiceFullNcf}')));
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
        oldSheet = newSheet;
        widget.sheets = await widget.book.getSheets();
        widget.currentSheetIndex =
            widget.sheets.indexWhere((e) => e.id == newSheet.id);
        widget.book.latestSheetVisited = newSheet.id;
        widget.purchases = [];
        widget.invoicesLogs = {};
        widget.currentSheet = newSheet;
        await widget.book.updateLatestSheetVisited();
        setState(() {});
      }
    } catch (_) {}
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
        showLoader(context);

        if (widget.sheets.isNotEmpty) {
          widget.currentSheet =
              widget.sheets.firstWhere((sheet) => sheet.id == sheetId);
          widget.currentSheetIndex =
              widget.sheets.indexWhere((element) => element.id == sheetId);
          oldSheet = widget.currentSheet;
        }

        widget.book.latestSheetVisited = sheetId;

        widget.purchases = await widget.currentSheet?.getPurchases() ?? [];
        await widget.book.updateLatestSheetVisited();

        Navigator.pop(context);

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
          _verticalScrollController.jumpTo(0);
        }
      }
    } catch (_) {
      Navigator.pop(context);
    } finally {
      setState(() {});
    }
  }

  Future<void> _setCurrentSheet(Sheet sheet, int index) async {
    widget.currentSheet = sheet;
    widget.currentSheetIndex = index;
    stream.add(sheet.id);
  }

  _setupScrollViews() {
    _horizontalScrollController.jumpTo(_scrollController.offset);
  }

  _selectInvoice(Purchase purchase) async {
    try {
      var result = await showDialog(
          context: context,
          builder: (ctx) => AddPurchaseModal(
              book: widget.book,
              sheet: widget.currentSheet!,
              purchase: purchase,
              isEditing: true));

      if (result['method'] == 'DELETE') {
        widget.purchases = await widget.currentSheet?.getPurchases() ?? [];
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SE ELIMINO LA FACTURA')));
        setState(() {});
      }

      if (result['method'] == 'UPDATE') {
        widget.purchases = await widget.currentSheet?.getPurchases() ?? [];
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SE ACTUALIZO LA FACTURA')));
        setState(() {});
      }
    } catch (_) {}
  }

  _deleteSheet() async {
    try {
      if (widget.sheets.isNotEmpty) {
        var isConfirm =
            await showConfirm(context, title: 'Eliminar esta hoja?');

        if (isConfirm!) {
          widget.currentSheetIndex = widget.sheets
              .indexWhere((element) => element.id == widget.currentSheet?.id);
          await widget.currentSheet?.delete();

          var pindex = widget.currentSheetIndex;

          oldSheet = widget.currentSheet;

          if (widget.currentSheetIndex > 0) {
            widget.currentSheetIndex -= 1;
          } else if (widget.currentSheetIndex == 0 &&
              widget.sheets.length > 1) {
            widget.currentSheetIndex += 1;
          }

          widget.currentSheet = widget.sheets[widget.currentSheetIndex];

          widget.sheets.removeAt(pindex);

          if (widget.sheets.isEmpty) {
            widget.book.latestSheetVisited = null;
            await widget.book.updateLatestSheetVisited();
            widget.currentSheet = null;
            widget.currentSheetIndex = 0;
            pindex = 0;
            widget.purchases = [];
          }

          widget.book.latestSheetVisited = widget.currentSheet?.id;

          await widget.book.updateLatestSheetVisited();

          widget.purchases = await widget.currentSheet?.getPurchases() ?? [];

          setState(() {});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    try {
      if (mounted) {
        windowManager.addListener(this);
        RawKeyboard.instance.addListener(_handlerKeys);
        stream.stream.listen(_onSheetChanged);
        _scrollController.addListener(_setupScrollViews);
        widget.book.updateBookUseStatus(true);
      }
    } catch (_) {}
    super.initState();
  }

  @override
  void onWindowClose() async {
    await widget.book.updateBookUseStatus(false);
  }

  @override
  void dispose() {
    widget.purchases = [];
    widget.invoicesLogs = {};
    widget.sheets = [];
    widget.currentSheet = null;
    stream.close();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    widget.book.updateBookUseStatus(false);
    super.dispose();
  }

  _goHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (ctx) => const CompaniesPage()),
        (route) => false);
  }

  Widget get _invoicesView {
    var invs = widget.purchases.map((e) => e.toDisplay()).toList();
    var columns = invs[0].keys.toList();

    columns = [invs.length.toString(), ...columns];
    var widgets = List.generate(columns.length, (index) {
      return Container(
        width: index == 0 ? 80 : 250,
        padding: const EdgeInsets.all(15),
        child: Text(columns[index],
            style: const TextStyle(color: Colors.blue, fontSize: 17),
            softWrap: false),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          alignment: Alignment.center,
          child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [...widgets])
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(invs.length, (i) {
                            var invoice = invs[i];
                            var values = invoice.entries.toList();
                            values = [MapEntry('', (i + 1)), ...values];

                            var widgets = List.generate(values.length, (j) {
                              var cell = values[j];
                              return GestureDetector(
                                onTap: () => _selectInvoice(
                                    widget.purchases[invs.indexOf(invoice)]),
                                child: Container(
                                  width: j == 0 ? 80 : 250,
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
          var isCurrent = widget.currentSheet?.id == sheet.id;
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
                    child: Text(months[sheet.sheetMonth! - 1],
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
            IconButton(onPressed: _goHome, icon: const Icon(Icons.home)),
            User.current?.isAdmin && widget.sheets.isNotEmpty
                ? IconButton(
                    onPressed: _deleteSheet,
                    icon: const Icon(Icons.delete),
                    tooltip: 'ELIMINAR ESTA HOJA')
                : const SizedBox(),
            IconButton(onPressed: _generate606, icon: const Icon(Icons.save)),
          ],
        ),
        body: widget.purchases.isNotEmpty ? _invoicesView : _emptyContainer,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
                heroTag: null,
                tooltip: 'VER REPORTE DEL MES',
                onPressed: () {
                  if (widget.currentSheet != null) {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return ScaffoldMessenger(
                              child: Builder(builder: (ctx) {
                            return DocumentModal(
                                context: ctx,
                                start:
                                    widget.currentSheet!.sheetMonth!.toDouble(),
                                end:
                                    widget.currentSheet!.sheetMonth!.toDouble(),
                                book: widget.book);
                          }));
                        });
                  }
                },
                child: const Icon(Icons.document_scanner)),
            const SizedBox(width: 10),
            FloatingActionButton(
                heroTag: null,
                tooltip: widget.sheets.isEmpty
                    ? 'AÑADE UNA HOJA PRIMERO'
                    : 'AÑADIR FACTURA DE ${widget.book.bookTypeName}',
                onPressed: widget.sheets.isNotEmpty ? _showModalPurchase : null,
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
