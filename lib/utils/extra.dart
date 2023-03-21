import 'package:flutter/services.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

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

var myformatter = NumberTextInputFormatter(
  integerDigits: 10,
  decimalDigits: 2,
  maxValue: '1000000000.00',
  decimalSeparator: '.',
  groupDigits: 3,
  groupSeparator: ',',
  allowNegative: false,
  overrideDecimalPoint: true,
  insertDecimalPoint: false,
  insertDecimalDigits: true,
);

var pointFormatter = NumberTextInputFormatter(
  integerDigits: 10,
  decimalDigits: 2,
  maxValue: '1000000000.00',
  decimalSeparator: '.',
  groupDigits: 3,
  groupSeparator: ',',
  allowNegative: true,
  overrideDecimalPoint: true,
  insertDecimalPoint: false,
  insertDecimalDigits: true,
);

String execPointFormatter(dynamic value) {
  return pointFormatter
      .formatEditUpdate(
          TextEditingValue.empty, TextEditingValue(text: value.toString()))
      .text;
}
