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
  TextEditingController? _monthYear;

  final _formKey = GlobalKey<FormState>();

  int _month = 0;

  Future<void> _addSheet() async {
    try {
      if (_formKey.currentState!.validate()) {
        var y = int.parse(_bookYear!.text);
        var m =  _month;

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
    _monthYear = TextEditingController();
    int year = widget.book.year ?? DateTime.now().year;
    _month = widget.latestSheetInserted?.sheetMonth ?? 0;
    _month = _month == 12 ? _month : _month + 1;
    _bookYear!.value = TextEditingValue(text: (year).toString());
    _monthYear!.value = TextEditingValue(text: (_month).toString());
    super.initState();
  }

  @override
  void dispose() {
    _bookYear?.dispose();
    _monthYear?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
          key: _formKey,
          child: SizedBox(
              width: 500,
              child: Material(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      children: [
                        Text('Añadiendo  Nueva Hoja...',
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor)),
                        const Spacer(),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close))
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: _bookYear,
                      style: const TextStyle(fontSize: 19),
                      enabled: false,
                      decoration: const InputDecoration(
                          hintText: 'AÑO', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                        value: _month,
                        items: months
                            .map((e) => DropdownMenuItem(
                                value: months.indexOf(e) + 1, child: Text(e)))
                            .toList(),
                        onChanged: (n) {
                          _month = n!;
                        }),
                    const SizedBox(height: 10),
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
              )))),
    );
  }
}
