import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/import.dart';

class ImportController extends GetxController {
  Company company;
  DateTime startDate;
  DateTime endDate;
  RxBool loading = false.obs;
  RxBool error = false.obs;
  RxString dateRangeLabel = ''.obs;
  RxList<Import> imports = <Import>[].obs;

  Uint8List? pdfBytes;

  FocusNode focusNode = FocusNode();

  ImportController(
      {required this.company, required this.startDate, required this.endDate});

  List<String> get cols {
    return imports[0].toDisplay().keys.toList();
  }

  List<num> get totals {
    var import = imports.reduce((previousValue, element) {
      var copy = imports[0].copyWith(
          cif: previousValue.cif + element.cif,
          tax: previousValue.tax + element.tax,
          encumbrance: previousValue.encumbrance + element.encumbrance,
          selectiveTax: previousValue.selectiveTax + element.selectiveTax,
          fines: previousValue.fines + element.fines,
          surcharges: previousValue.surcharges + element.surcharges,
          dgaServiceFee: previousValue.dgaServiceFee + element.dgaServiceFee,
          otherConcepts: previousValue.otherConcepts + element.otherConcepts,
          total: previousValue.total + element.total);
      return copy;
    });
    return [
      import.cif,
      import.tax,
      import.encumbrance,
      import.selectiveTax,
      import.fines,
      import.surcharges,
      import.dgaServiceFee,
      import.otherConcepts,
      import.total
    ];
  }

  @override
  void onInit() async {
    focusNode.requestFocus();
    try {
      dateRangeLabel.value =
          '${startDate.format(payload: 'DD/MM/YYYY')} - ${endDate.format(payload: 'DD/MM/YYYY')}';
      error.value = false;
      loading.value = true;
      var r = await Import.get(
          company: company, startDate: startDate, endDate: endDate);
      imports.value = r['result'];
      pdfBytes = r['pdfBytes'];
      loading.value = false;
      print('Imports loaded: ${imports.length}');
    } catch (e) {
      loading.value = false;
      error.value = true;
    }
    super.onInit();
  }

  @override
  void dispose() {
    imports.value = [];
    focusNode.dispose();
    super.dispose();
  }
}
