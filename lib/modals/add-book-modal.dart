// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class AddBookModal extends StatefulWidget {
  List<Book> books = [];
  Company company;
  int bookTypeId;
  int bookYear;

  AddBookModal(
      {super.key,
      required this.books,
      required this.bookYear,
      required this.company,
      required this.bookTypeId});

  @override
  State<AddBookModal> createState() => _AddBookModalState();
}

class _AddBookModalState extends State<AddBookModal> {
  TextEditingController bookYear = TextEditingController();
  @override
  void initState() {
    if (mounted) {
      bookYear.value = TextEditingValue(text: (widget.bookYear).toString());
    }
    super.initState();
  }

  _addBook() async {
    try {
      int year = int.parse(bookYear.text);
      if (widget.books.any((element) => element.year == year)) {
        throw 'YA EXISTE ESTE LIBRO';
      }
      var book = await Book(
              year: year,
              companyRnc: widget.company.rnc,
              companyId: widget.company.id,
              bookTypeId: widget.bookTypeId)
          .create();

      Navigator.pop(context, book);
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  @override
  void dispose() {
    bookYear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      content: Form(
          child: SizedBox(
              width: 450,
              child: Material(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Row(
                          children: [
                            Text('AÑADIENDO LIBRO...',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: Theme.of(context).primaryColor)),
                            const Spacer(),
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: TextField(
                              controller: bookYear,
                              style: const TextStyle(fontSize: 20),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'AÑO DE IBRO')),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: _addBook,
                              child: const Text(
                                'CREAR LIBRO',
                                style: TextStyle(fontSize: 19),
                              )),
                        )
                      ],
                    ),
                  )))),
    );
  }
}
