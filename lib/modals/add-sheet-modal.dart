import 'package:flutter/material.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class AddSheetModal extends StatefulWidget {
  final Book book;
  Sheet? latestSheetInserted;

  AddSheetModal({super.key, required this.book, this.latestSheetInserted});

  @override
  State<AddSheetModal> createState() => _AddSheetModalState();
}

class _AddSheetModalState extends State<AddSheetModal> {
  TextEditingController? _bookYear;

  final _formKey = GlobalKey<FormState>();

  int _month = 0;

  Future<void> _addSheet() async {
    try {
      if (_formKey.currentState!.validate()) {
        var y = int.parse(_bookYear!.text);
        var m = _month;

        var newSheet = await Sheet(
                bookId: widget.book.id,
                companyId: widget.book.companyId,
                sheetYear: y,
                sheetMonth: m)
            .create();
        Navigator.pop(context, newSheet);
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  @override
  void initState() {
    _bookYear = TextEditingController();
    int year = widget.book.year ?? DateTime.now().year;
    _month = widget.latestSheetInserted?.sheetMonth ?? 0;
    _month = _month == 12 ? _month : _month + 1;
    _bookYear!.value = TextEditingValue(text: (year).toString());
    super.initState();
  }

  @override
  void dispose() {
    _bookYear?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      content: SizedBox(
        width: 450,
        child: Form(
            key: _formKey,
            child: Material(
                child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Text('AÑADIENDO NUEVO MES...',
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
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                      value: _month,
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
                      items: months
                          .map((e) => DropdownMenuItem(
                              value: months.indexOf(e) + 1, child: Text(e)))
                          .toList(),
                      onChanged: (n) {
                        _month = n!;
                      }),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bookYear,
                    style: const TextStyle(fontSize: 19),
                    enabled: false,
                    decoration: const InputDecoration(
                        hintText: 'AÑO', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addSheet,
                      child: const Text('AÑADIR NUEVA HOJA',
                          style: TextStyle(fontSize: 19)),
                    ),
                  )
                ],
              ),
            ))),
      ),
    );
  }
}
