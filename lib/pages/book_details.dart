// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/modals/add-concept-modal.dart';
import 'package:uresaxapp/modals/add-purchase-modal.dart';
import 'package:uresaxapp/modals/add-sheet-modal.dart';
import 'package:uresaxapp/modals/document.data.modal.concept.type.dart';
import 'package:uresaxapp/modals/document.data.modal.for.invoice.type.dart';
import 'package:uresaxapp/models/banking.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/invoicetype.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:uresaxapp/models/payment-method.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/retention.dart';
import 'package:uresaxapp/models/retention.tax.dart';
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/models/tax.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/companies_page.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:path/path.dart' as path;
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.floating-action.button.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';
import 'package:window_manager/window_manager.dart';
import 'package:pdf/widgets.dart' as pw;

class ShowPurchaseModalIntent extends Intent {
  final String name;
  const ShowPurchaseModalIntent({required this.name});
}

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

  late pw.Document pdf;

  late ReportViewModelForInvoiceType _reportViewModelForInvoiceType;

  late ReportViewModelForConceptType _reportViewModelForConceptType;

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

  String get _fileName {
    return path.join(
        Platform.environment['URESAX_STATIC_LOCAL_SERVER_PATH']!,
        'URESAX',
        widget.book.companyName?.trim(),
        widget.book.year.toString(),
        '606',
        'DGII_F_606_${widget.book.companyRnc}_${widget.currentSheet?.sheetDate}');
  }

  String get _filePath {
    return '$_fileName.TXT';
  }

  String get _filePathCsv {
    return '$_fileName.CSV';
  }

  String get _dirPath {
    return path.dirname(_filePath);
  }

  Future<void> _showConceptModal() async {
    try {
      var concepts = await Concept.getConcepts();
      await showLoader(context);
      Navigator.pop(context);
      await showDialog(
          context: context,
          builder: (ctx) => AddConceptModal(concepts: concepts));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
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

  _moveLeft() {
    if (_scrollController.offset == 0) return;
    _scrollController.jumpTo(_scrollController.offset - 50);
  }

  _moveRight() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent)
      return;
    _scrollController.jumpTo(_scrollController.offset + 50);
  }

  _moveUp() {
    if (_verticalScrollController.offset == 0) return;
    _verticalScrollController.jumpTo(_verticalScrollController.offset - 50);
  }

  _moveDown() {
    if (_verticalScrollController.offset ==
        _verticalScrollController.position.maxScrollExtent) return;
    _verticalScrollController.jumpTo(_verticalScrollController.offset + 50);
  }

  _generate606() async {
    try {
      var purchases = [...widget.purchases];

      purchases.removeWhere((element) =>
          element.invoiceNcfTypeId == 2 || element.invoiceNcfTypeId == 32);

      var elements = purchases.map((e) => e.to606()).toList();
      var elements2 = purchases.map((e) => e.to606Display()).toList();

      if (purchases.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('NO TIENES FACTURAS EN ESTA HOJA'),
        ));
        return;
      }

      List<List<dynamic>> rows = [];

      List<List<dynamic>> rows2 = [];

      for (int i = 0; i < elements.length; i++) {
        var item = elements[i];
        var values = item.values.toList();
        rows.add(values);
      }

      for (int i = 0; i < elements2.length; i++) {
        var item = elements2[i];
        var values = item.values.toList();
        rows2.add(values);
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

      var r2 = const ListToCsvConverter().convert([
        [
          'RNC',
          'TIPO ID',
          'TIPO DE FACTURA',
          'NCF',
          'NCF MODIFICADO',
          'FECHA DE COMPROBANTE',
          'FECHA DE PAGO',
          'TOTAL EN SERVICIOS',
          'TOTAL EN BIENES',
          'TOTAL FACTURADO',
          'ITBIS FACTURADO',
          'ITBIS RETENIDO',
          'ITBIS ART. 349',
          'ITBIS LLEVADO AL COSTO',
          'ITBIS POR ADELANTAR',
          'ITBIS PERCIBIDO EN COMPRAS',
          'TIPO DE RETENCION EN ISR',
          'MONTO DE RETENCION RENTA',
          'ISR PERCIBIDO EN COMPRAS',
          'IMPUESTO PERCIBIDO AL CONSUMO',
          'OTROS IMPUESTOS O TASAS',
          'MONTO PROPINA LEGAL',
          'FORMA DE PAGO'
        ],
        ...rows2
      ], fieldDelimiter: '|');

      var file = File(_filePath.trim());

      var file2 = File(_filePathCsv.trim());

      await file.create(recursive: true);

      await file2.create(recursive: true);

      await file.writeAsString(result);

      await file2.writeAsString(r2);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('FUE GENERADO EL 606'),
          action: SnackBarAction(
              label: 'ABRIR ARCHIVO',
              onPressed: () {
                launchFile(_dirPath);
              })));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  _openFolder() async {
    try {
      await launchFile(_dirPath);
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _getPurchaseContext({bool isEditing = false, Purchase? purchase}) async {
    var concepts = [Concept(name: 'CONCEPTO'), ...(await Concept.getConcepts())]
        .cast<Concept>();

    var bankings = [Banking(name: 'BANCO'), ...(await Banking.getBankings())]
        .cast<Banking>();

    var invoiceTypes = [
      InvoiceType(name: 'TIPO DE FACTURA'),
      ...(await InvoiceType.getInvoiceTypes())
    ].cast<InvoiceType>();

    var paymentMethods = [
      PaymentMethod(name: 'METODO DE PAGO'),
      ...(await PaymentMethod.getPaymentMethods())
    ].cast<PaymentMethod>();

    var retentions = [
      Retention(name: 'RETENCION ISR'),
      ...(await Retention.all())
    ].cast<Retention>();

    var ncfs = [
      NcfType(name: 'TIPO DE COMPROBANTE'),
      ...(await NcfType.getNcfs())
    ].cast<NcfType>();

    var retentionTaxes = [
      RetentionTax(name: 'RETENCION DE ITBIS'),
      ...(await RetentionTax.all())
    ].cast<RetentionTax>();

    var taxes = await Tax.all();

    Navigator.pop(context);

    return await showDialog(
        context: context,
        builder: (ctx) => AddPurchaseModal(
              book: widget.book,
              sheet: widget.currentSheet!,
              purchase: purchase,
              concepts: concepts,
              bankings: bankings,
              invoiceTypes: invoiceTypes,
              paymentMethods: paymentMethods,
              retentions: retentions,
              retentionTaxes: retentionTaxes,
              ncfs: ncfs,
              taxes: taxes,
              isEditing: isEditing,
            ));
  }

  _showModalPurchase() async {
    try {
      await showLoader(context);

      RawKeyboard.instance.removeListener(_handlerKeys);

      var result = await _getPurchaseContext();

      if (result is Map) {
        if (result['method'] == 'INSERT') {
          var purchase = result['data'] as Purchase;
          widget.purchases = await widget.currentSheet?.getPurchases() ?? [];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'SE INSERTO LA FACTURA CON EL RNC: ${purchase.invoiceRnc} Y EL NCF: ${purchase.invoiceNcf}')));

          setState(() {});
        }
      }
      RawKeyboard.instance.addListener(_handlerKeys);
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
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

  Future<void> _onSheetChanged(String? sheetId) async {
    await showLoader(context);
    try {
      if (sheetId != null) {
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

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
          _verticalScrollController.jumpTo(0);
        }

        Navigator.pop(context);
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
      await showLoader(context);

      RawKeyboard.instance.removeListener(_handlerKeys);
      var result =
          await _getPurchaseContext(isEditing: true, purchase: purchase);
      if (result is Map) {
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
      }

      RawKeyboard.instance.addListener(_handlerKeys);
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
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

  _init() async {
    try {
      windowManager.addListener(this);
      await windowManager.setPreventClose(true);
      await widget.book.updateBookUseStatus(true);
      RawKeyboard.instance.addListener(_handlerKeys);
      stream.stream.listen(_onSheetChanged);
      _scrollController.addListener(_setupScrollViews);
    } catch (_) {}
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            child: SizedBox(
                width: 400,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  shrinkWrap: true,
                  children: [
                    Text('ESTAS SEGURO QUE DESEAS SALIR?',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).primaryColor)),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.grey)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('NO'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).primaryColor)),
                          child: const Text('OK'),
                          onPressed: () async {
                            try {
                              widget.book.updateBookUseStatus(false);
                              Navigator.of(context).pop();
                              await windowManager.destroy();
                            } catch (e) {
                              showAlert(context, message: e.toString());
                            }
                          },
                        ),
                      ],
                    )
                  ],
                )),
          );
        },
      );
    }
  }

  Future<bool> _onBeforeClose() async {
    try {
      await widget.book.dispose();
      await windowManager.setPreventClose(false);
      Navigator.pop(context);
      return true;
    } catch (e) {
      showAlert(context, message: e.toString());
      return false;
    }
  }

  Future<void> _preloadReportDataForInvoiceType() async {
    await showLoader(context);

    try {
      if (widget.currentSheet != null) {
        _reportViewModelForInvoiceType =
            await Purchase.getReportViewByInvoiceType(
                id: widget.book.id!,
                start: widget.currentSheet!.sheetMonth!,
                end: widget.currentSheet!.sheetMonth!);

        _reportViewModelForInvoiceType.book = widget.book;
        _reportViewModelForInvoiceType.start =
            widget.currentSheet!.sheetMonth! - 1;
        _reportViewModelForInvoiceType.end =
            widget.currentSheet!.sheetMonth! - 1;
        _reportViewModelForInvoiceType.rangeValues = RangeValues(
            widget.currentSheet!.sheetMonth!.toDouble(),
            widget.currentSheet!.sheetMonth!.toDouble());
        _reportViewModelForInvoiceType.rangeLabels = RangeLabels(
            months[_reportViewModelForInvoiceType.start!],
            months[_reportViewModelForInvoiceType.end!]);

        _reportViewModelForInvoiceType.book = widget.book;

        _reportViewModelForInvoiceType.footer = {};
        _reportViewModelForInvoiceType.footer.addAll(
            {'ITBIS EN SERVICIOS': _reportViewModelForInvoiceType.taxServices});

        _reportViewModelForInvoiceType.footer.addAll(
            {'ITBIS EN BIENES': _reportViewModelForInvoiceType.taxGood});

        _reportViewModelForInvoiceType.pdf = pw.Document();

        //_reportViewModelForInvoiceType.pdf?.addPage(buildReportViewModel(_reportViewModelForInvoiceType));

        Navigator.pop(context);

        showDialog(
            context: context,
            builder: (ctx) {
              return ScaffoldMessenger(child: Builder(builder: (ctx) {
                return DocumentModalForInvoiceType(
                    context: ctx,
                    reportViewModel: _reportViewModelForInvoiceType,
                    book: widget.book,
                    currentSheet: widget.currentSheet);
              }));
            });
      } else {
        throw 'AGREGA UNA HOJA AL MENOS';
      }
    } catch (e) {
      Navigator.pop(context);
      await showAlert(context, message: e.toString());
    }
  }

  Future<void> _preloadReportDataForConceptType() async {
    await showLoader(context);

    try {
      if (widget.currentSheet != null) {
        _reportViewModelForConceptType =
            await Purchase.getReportViewByConceptType(
                id: widget.book.id!,
                start: widget.currentSheet!.sheetMonth!,
                end: widget.currentSheet!.sheetMonth!);

        _reportViewModelForConceptType.book = widget.book;
        _reportViewModelForConceptType.start =
            widget.currentSheet!.sheetMonth! - 1;
        _reportViewModelForConceptType.end =
            widget.currentSheet!.sheetMonth! - 1;
        _reportViewModelForConceptType.rangeValues = RangeValues(
            widget.currentSheet!.sheetMonth!.toDouble(),
            widget.currentSheet!.sheetMonth!.toDouble());
        _reportViewModelForConceptType.rangeLabels = RangeLabels(
            months[_reportViewModelForConceptType.start!],
            months[_reportViewModelForConceptType.end!]);

        _reportViewModelForConceptType.pdf = pw.Document();

        _reportViewModelForConceptType.title = _title;
        _reportViewModelForConceptType.pdf?.addPage(
            buildReportViewModelForConceptType(_reportViewModelForConceptType));

        Navigator.pop(context);

        showDialog(
            context: context,
            builder: (ctx) {
              return ScaffoldMessenger(child: Builder(builder: (ctx) {
                return DocumentModalForConceptType(
                    context: ctx,
                    reportViewModel: _reportViewModelForConceptType,
                    book: widget.book,
                    currentSheet: widget.currentSheet);
              }));
            });
      } else {
        throw 'AGREGA UNA HOJA AL MENOS';
      }
    } catch (e) {
      Navigator.pop(context);
      await showAlert(context, message: e.toString());
    }
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
    windowManager.removeListener(this);
    super.dispose();
  }

  _copyRnc() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.book.companyRnc));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('RNC DE ${widget.book.companyName} COPIADO!')));
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _goHome() async {
    try {
      await widget.book.dispose();
      await windowManager.setPreventClose(false);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => const CompaniesPage()),
          (route) => false);
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _onSelectedOption(Map<String, dynamic> option) {
    if (option['type'] == ReportModelType.invoiceType)
      _preloadReportDataForInvoiceType();
    if (option['type'] == ReportModelType.conceptType)
      _preloadReportDataForConceptType();
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
                                onDoubleTap: () => _selectInvoice(
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
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _setCurrentSheet(sheet, index),
              child: AnimatedContainer(
                  decoration: BoxDecoration(
                      color: isCurrent ? Colors.blue : Colors.transparent,
                      border: Border.symmetric(
                          vertical: BorderSide(
                              width: 0.5,
                              color: isCurrent
                                  ? Colors.transparent
                                  : Colors.grey))),
                  duration: const Duration(milliseconds: 150),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: Text(months[sheet.sheetMonth! - 1],
                          style: TextStyle(
                              color: isCurrent ? Colors.white : Colors.black45,
                              fontSize: 17,
                              fontWeight: FontWeight.w500)))),
            ),
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
          Icon(Icons.edit_document,
              color: Theme.of(context).primaryColor, size: 100)
        ],
      ),
    );
  }

  String get _count01 {
    return widget.purchases
        .where((element) =>
            element.invoiceNcfTypeId != 2 && element.invoiceNcfTypeId != 32)
        .toList()
        .length
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        leadingWidth: 0,
        title: Text(_title),
        elevation: 0,
        actions: [
          Row(
            children: [
              SizedBox(
                  height: kToolbarHeight,
                  width: 50,
                  child: Tooltip(
                    message: 'CANTIDAD DE NCFS QUE SERAN REPORTADOS A LA DGII',
                    child: Center(
                      child: Text(_count01,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  )),
              ToolButton(
                  onTap: _copyRnc,
                  toolTip: 'COPIAR RNC DE ${widget.book.companyName}',
                  icon: const Icon(Icons.copy)),
              ToolButton(
                  onTap: _goHome,
                  toolTip: 'IR A INICIO',
                  icon: const Icon(Icons.home)),
              ToolButton(
                  onTap: _onBeforeClose,
                  toolTip: 'IR A LA BIBLIOTECA DE ${widget.book.companyName}',
                  icon: const Icon(Icons.book)),
              ToolButton(
                  onTap: _showConceptModal,
                  toolTip: 'ABRIR CATALOGO DE CATEGORIAS',
                  icon: const Icon(Icons.category)),
              ToolButton(
                  onTap: _openFolder,
                  toolTip: 'ABRIR CARPETA DE ${widget.book.companyName}',
                  icon: const Icon(Icons.folder)),
              ToolButton(
                  onTap: _generate606,
                  toolTip: 'GENERAR 606',
                  icon: const Icon(Icons.save)),
              User.current!.isAdmin
                  ? ToolButton(
                      onTap: _deleteSheet,
                      toolTip: 'ELIMNINAR ESTA HOJA',
                      icon: const Icon(Icons.delete))
                  : Container()
            ],
          )
        ],
      ),
      body: widget.purchases.isNotEmpty ? _invoicesView : _emptyContainer,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFloatingActionButton(
              title: 'VER REPORTE POR TIPO DE FACTURA',
              child: PopupMenuButton<Map<String, dynamic>>(
                  onSelected: _onSelectedOption,
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (ctx) {
                    return reportTypes
                        .map((e) => PopupMenuItem<Map<String, dynamic>>(
                            value: e, child: Text(e['name'])))
                        .toList();
                  })),
          const SizedBox(width: 10),
          CustomFloatingActionButton(
              onTap: widget.sheets.isNotEmpty ? _showModalPurchase : null,
              title: widget.sheets.isEmpty
                  ? 'AÑADE UNA HOJA PRIMERO'
                  : 'AÑADIR FACTURA DE ${widget.book.bookTypeName}',
              child: const Icon(Icons.insert_drive_file_outlined,
                  color: Colors.white)),
          const SizedBox(width: 10),
          CustomFloatingActionButton(
              onTap: _showModalSheet,
              title: _checkSheetLimit
                  ? 'AÑADIR HOJA'
                  : 'YA NO SE PUEDE AÑADIR MAS MESES PARA ESTE LIBRO',
              child: const Icon(Icons.add, color: Colors.white))
        ],
      ),
      bottomNavigationBar: _bottomBar,
    );
  }
}
