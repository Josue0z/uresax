import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';

class DateSelectorWidget extends StatefulWidget {
  TextEditingController controller;

  Function(DateTime?) onSelected;

  String hintText;

  String labelText;

  DateTime startDate;

  DateTime? date;

  bool isPayNcf;

  DateSelectorWidget(
      {super.key,
      this.isPayNcf = false,
      required this.controller,
      required this.onSelected,
      required this.hintText,
      required this.labelText,
      required this.startDate,
      required this.date});

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {

  _showDatePicker() async {
    var d = await showDatePicker(
        context: context,
        initialDate: widget.date ?? widget.startDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(3000));
    if (d != null) {
      widget.controller.value =
          TextEditingValue(text: d.format(payload: 'DD/MM/YYYY'));
      widget.date = d;
    } else if (d == null && widget.isPayNcf) {
      widget.controller.value = TextEditingValue.empty;
      widget.date = null;
    }
    widget.onSelected(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_month)),
      onTap: _showDatePicker,
    );
  }
}
