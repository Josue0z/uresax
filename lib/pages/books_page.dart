// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/modals/add-book-modal.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/pages/book_details.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class BooksPage extends StatefulWidget {
  Company company;
  BookType bookType;
  BooksPage({super.key, required this.company, required this.bookType});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List<Book> books = [];
  List<Sheet> sheets = [];
  var invoicesLogs = {};
  var invoices = [];

  _fetchBooks() async {
    try {
      books = await Book.getBooks(companyId: widget.company.id);
    } catch (e) {
      print(e);
    } finally {
      setState(() {});
    }
  }

  _delete(Book book, int index) async {
    try {
      await book.delete();
      books.removeAt(index);
      setState(() {});
      return;
    } catch (e) {
      print(e);
    }
  }

  _preloadBookData(Book book) async {
    try {
      showLoader(context);

      var inUse = await book.checkIfBookIsUsed();

      if (inUse) {
        throw 'EL LIBRO YA ESTA EN USO';
      }

      var data = await fetchDataBook(
          bookId: book.id!, sheetId: book.latestSheetVisited ?? 'x');

      await Future.delayed(const Duration(milliseconds: 100));
      await book.updateBookUseStatus(true);

      Navigator.pop(context);
      invoices = data['invoices'];
      invoicesLogs = data['invoicesLogs'];
      sheets = data['sheets'];

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => BookDetailsPage(
                  book: book,
                  invoices: invoices,
                  invoicesLogs: invoicesLogs,
                  sheets: sheets)));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
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
    return ListView.separated(
        itemCount: books.length,
        separatorBuilder: (ctx, index) => const Divider(),
        itemBuilder: (ctx, index) {
          Book book = books[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.book, size: 25, color: Colors.white),
            ),
            title:
                Text(book.name!, style: Theme.of(context).textTheme.headline5),
            minVerticalPadding: 15,
            subtitle: Text(
              'RNC ${book.companyRnc} ${book.createdAt?.format("DD/MM/y")} / ${book.bookTypeName}',
              style: const TextStyle(fontSize: 18),
            ),
            trailing: Wrap(
              children: [
                IconButton(
                    onPressed: () => _preloadBookData(book),
                    icon: const Icon(Icons.remove_red_eye)),
                IconButton(
                    onPressed: null, //() => _delete(book, index),
                    color: Theme.of(context).errorColor,
                    icon: const Icon(Icons.delete))
              ],
            ),
          );
        });
  }

  Widget get _emptyView {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 150,
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LIBROS: ${widget.company.name}')),
      body: books.isNotEmpty ? _bookView : _emptyView,
      floatingActionButton: FloatingActionButton(
        tooltip: 'AÑADIR LIBRO',
        onPressed: () async {
          int y = books.isNotEmpty ? books.last.year! + 1 : DateTime.now().year;
          var book = await showDialog(
              context: context,
              builder: (ctx) => AddBookModal(
                  company: widget.company,
                  books: books,
                  bookTypeId: widget.bookType == BookType.purchases ? 1 : 2,
                  bookYear: y));
          if (book is Book) {
            books.add(book);
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
