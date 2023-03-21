// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/modals/add-book-modal.dart';
import 'package:uresaxapp/modals/document-data-modal.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/book_details.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom-appbar.dart';
import 'package:pdf/widgets.dart' as pw;

class BooksPage extends StatefulWidget {
  Company company;
  BookType bookType;
  BooksPage({super.key, required this.company, required this.bookType});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List<Book> books = [];

  Widget get _searchWidget {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 80),
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        onChanged: _fetchBooksByYear,
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'BUSCAR LIBROS... (AÑO)',
            suffixIcon: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.search, size: 28))),
      ),
    );
  }

  _fetchBooks() async {
    try {
      books =
          await Book.all(where: ''' "companyId" = '${widget.company.id}' ''');
    } catch (_) {
    } finally {
      setState(() {});
    }
  }

  _fetchBooksByYear(String year) async {
    try {
      if (year.isNotEmpty) {
        books = await Book.all(
            where:
                ''' "companyId" = '${widget.company.id}' and book_year::text like '%${year.trim()}%' ''');
      } else {
        books =
            await Book.all(where: ''' "companyId" = '${widget.company.id}' ''');
      }
    } catch (_) {
    } finally {
      setState(() {});
    }
  }

  _delete(Book book, int index) async {
    try {
      var isConfirm = await showConfirm(context, title: 'Eliminar libro?');

      if (isConfirm!) {
        await book.delete();
        books.removeAt(index);
        setState(() {});
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _preloadBookData(Book book) async {
    try {
      showLoader(context);

      List<Purchase> purchases = [];

      List<Sheet> sheets = [];

      Sheet? currentSheet;
      int currentSheetIndex = 1;

      var inUse = await book.checkIfBookIsUsed();

      if (inUse) {
        throw 'EL LIBRO YA ESTA EN USO';
      }

      sheets = await book.getSheets();

      if (sheets.isNotEmpty) {
        currentSheet = sheets.firstWhere(
            (element) => element.id == book.latestSheetVisited,
            orElse: () => Sheet());
        currentSheetIndex =
            sheets.indexWhere((element) => element.id == currentSheet?.id);
      }

      purchases = await currentSheet?.getPurchases() ?? [];

      Navigator.pop(context);

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => BookDetailsPage(
                  book: book,
                  currentSheet: currentSheet,
                  currentSheetIndex: currentSheetIndex,
                  purchases: purchases,
                  invoicesLogs: const {},
                  sheets: sheets)));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  _showModal() async {
    int y = books.isNotEmpty ? books.last.year! + 1 : DateTime.now().year;
    var book = await showDialog(
        context: context,
        builder: (ctx) => AddBookModal(
            company: widget.company, books: books, bookTypeId: 1, bookYear: y));
    if (book is Book) {
      books =
          await Book.all(where: ''' "companyId" = '${widget.company.id}' ''');
      setState(() {});
    }
  }

  _showReport(Book book) async {
    await showLoader(context);
    try {
      var r = await Purchase.getReportViewByInvoiceType(
          reportType: ReportType.year,
          id: widget.company.id!,
          start: book.year!,
          end: book.year!);

      r.book = book;

      r.rangeValues = RangeValues(r.start!.toDouble(), r.end!.toDouble());

      r.footer = {};
      r.footer.addAll({'ITBIS EN SERVICIOS': r.taxServices});
      r.footer.addAll({'ITBIS EN BIENES': r.taxGood});

      r.pdf = pw.Document();

      r.pdf?.addPage(buildReportViewModel(r));

      Navigator.pop(context);

      showDialog(
          context: context,
          builder: (ctx) {
            return ScaffoldMessenger(child: Builder(builder: (ctx) {
              return DocumentModal(
                  context: ctx,
                  reportType: ReportType.year,
                  reportViewModel: r,
                  book: book);
            }));
          });
    } catch (e) {
      Navigator.pop(context);
      await showAlert(context, message: e.toString());
    }
  }

  @override
  void initState() {
    _fetchBooks();
    super.initState();
  }

  @override
  void dispose() {
    books = [];
    super.dispose();
  }

  Widget get _bookView {
    if (books.isEmpty) return _emptyView;

    return Expanded(
        child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (ctx, index) {
              Book book = books[index];
              String title =
                  'RNC ${book.companyRnc} ${book.createdAt?.format("DD/MM/y")} / ${book.bookTypeName}';
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 80),
                minVerticalPadding: 15,
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.book, size: 25, color: Colors.white),
                ),
                title: Text(book.name!,
                    style: Theme.of(context).textTheme.headline5),
                subtitle: Text(
                  title,
                  style: const TextStyle(fontSize: 18),
                ),
                trailing: Wrap(
                  children: [
                    IconButton(
                        onPressed: () => _preloadBookData(book),
                        icon: const Icon(Icons.remove_red_eye)),
                    const SizedBox(width: 10),
                    IconButton(
                        color: Theme.of(context).primaryColor,
                        tooltip:
                            'VER REPORTE DE ${book.companyName} ${book.year}',
                        onPressed: () => _showReport(book),
                        icon: const Icon(Icons.document_scanner)),
                    const SizedBox(width: 10),
                    User.current!.isAdmin
                        ? IconButton(
                            tooltip: 'ELIMINAR',
                            onPressed: () => _delete(book, index),
                            color: Theme.of(context).colorScheme.error,
                            icon: const Icon(Icons.delete))
                        : const SizedBox()
                  ],
                ),
              );
            }));
  }

  Widget get _emptyView {
    return Expanded(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 100,
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: widget.company.name!),
      ),
      body: Column(
        children: [_searchWidget, _bookView],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'AÑADIR LIBRO',
        onPressed: _showModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
