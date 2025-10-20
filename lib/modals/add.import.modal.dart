// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/controllers/imports.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/models/import.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/date.selector.widget.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uuid/uuid.dart';

class AddImportModal extends StatefulWidget {
  final CompanyDetailsPage companyDetailsPage;
  final Import? import;

  bool isEditing;

  AddImportModal(
      {super.key,
      required this.companyDetailsPage,
      this.import,
      this.isEditing = false});

  @override
  State<AddImportModal> createState() => _AddImportModalState();
}

class _AddImportModalState extends State<AddImportModal> {
  TextEditingController declarationNumber = TextEditingController();

  TextEditingController cif = TextEditingController();

  TextEditingController receiptNumber = TextEditingController();

  TextEditingController invoiceNumber = TextEditingController();

  TextEditingController tax = TextEditingController();

  TextEditingController encumbrance = TextEditingController();

  TextEditingController selectiveTax = TextEditingController();

  TextEditingController fines = TextEditingController();

  TextEditingController surcharges = TextEditingController();

  TextEditingController dgaServiceFee = TextEditingController();

  TextEditingController otherConcepts = TextEditingController();

  TextEditingController total = TextEditingController();

  StreamController<String?> paymentDateLabel = StreamController();

  StreamController<String?> invoiceDateLabel = StreamController();

  DateTime? paymentDate;

  DateTime? invoiceDate;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String get title {
    return widget.isEditing ? 'EDITANDO IMPORTACION' : 'AÑADIENDO IMPORTACION';
  }

  String get btnTitle {
    return widget.isEditing ? 'EDITAR IMPORTACION' : 'AÑADIR IMPORTACION';
  }

  onSelected(DateTime? date) async {
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(paymentDate!),
      );

      if (time != null) {
        paymentDate = DateTimeField.combine(date, time);
      }

      paymentDateLabel.add(paymentDate!.format(payload: 'DD/MM/YYYY HH:mm'));
    }
  }

  onSelectedInvoiceDate(DateTime? date) async {
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(invoiceDate!),
      );
      if (time != null) {
        invoiceDate = DateTimeField.combine(date, time);
      }
      invoiceDateLabel.add(invoiceDate?.format(payload: 'DD/MM/YYYY HH:mm'));
    } else {
      invoiceDateLabel.add(null);
    }
  }

  onSubmit() async {
    if (formKey.currentState!.validate()) {
      try {
        var import = Import(
            id: widget.isEditing && widget.import != null
                ? widget.import!.id
                : const Uuid().v1(),
            companyId: widget.companyDetailsPage.company.id!,
            cif: double.tryParse(cif.text.replaceAll(',', '')) ?? 0,
            declarationNumber: declarationNumber.text.trim(),
            receiptNumber: receiptNumber.text.trim(),
            invoiceNumber: invoiceNumber.text.trim(),
            tax: double.tryParse(tax.text.replaceAll(',', '')) ?? 0,
            encumbrance:
                double.tryParse(encumbrance.text.replaceAll(',', '')) ?? 0,
            selectiveTax:
                double.tryParse(selectiveTax.text.replaceAll(',', '')) ?? 0,
            fines: double.tryParse(fines.text.replaceAll(',', '')) ?? 0,
            surcharges:
                double.tryParse(surcharges.text.replaceAll(',', '')) ?? 0,
            dgaServiceFee:
                double.tryParse(dgaServiceFee.text.replaceAll(',', '')) ?? 0,
            otherConcepts: num.tryParse(otherConcepts.text) ?? 0,
            total: double.tryParse(total.text.replaceAll(',', '')) ?? 0,
            paymentDate: paymentDate!,
            invoiceDate: invoiceDate!);
        if (!widget.isEditing) {
          await import.create();
        } else {
          await import.update();
        }

        var c = Get.find<ImportController>();

        var c2 = Get.find<PurchasesController>();

        var start = paymentDate!.startOfMonth();
        var end = paymentDate!.endOfMonth();

        widget.companyDetailsPage.startDate = start;
        widget.companyDetailsPage.endDate = end;
        widget.companyDetailsPage.controller2.date.value = TextEditingValue(
            text:
                '${start.format(payload: 'DD/MM/YYYY')} - ${end.format(payload: 'DD/MM/YYYY')}');
        c.dateRangeLabel.value =
            '${start.format(payload: 'DD/MM/YYYY')} - ${end.format(payload: 'DD/MM//YYYY')}';

        await storage.write(
            key: "STARTDATE_${widget.companyDetailsPage.company.id}",
            value: widget.companyDetailsPage.startDateLargeAsString);
        await storage.write(
            key: "ENDDATE_${widget.companyDetailsPage.company.id}",
            value: widget.companyDetailsPage.endDateLargeAsString);

        var r = await Import.get(
            company: widget.companyDetailsPage.company,
            startDate: start,
            endDate: end);

        c.imports.value = r['result'];
        c.pdfBytes = r['pdfBytes'];

        c2.purchases.value = await Purchase.get(
            companyId: widget.companyDetailsPage.company.id!,
            startDate: start,
            endDate: end);

        Get.back();

        if (!widget.isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE INSERTO LA IMPORTACION')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE ACTUALIZO LA IMPORTACION')));
        }
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  deleteImport() async {
    try {
      await widget.import?.delete();
      var c = Get.find<ImportController>();
      var r = await Import.get(
          company: widget.companyDetailsPage.company,
          startDate: widget.companyDetailsPage.startDate,
          endDate: widget.companyDetailsPage.endDate);
      c.imports.value = r['result'];
      c.pdfBytes = r['pdfBytes'];
      Get.back();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('IMPORTACION ELIMINADA')));
    } catch (e) {
      rethrow;
    }
  }

  setupEditionMode() {
    if (widget.isEditing && widget.import != null) {
      declarationNumber.value =
          TextEditingValue(text: widget.import!.declarationNumber);
      cif.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.cif == 0
                  ? ''
                  : widget.import?.cif.toStringAsFixed(2) ?? ''));
      tax.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.tax == 0
                  ? ''
                  : widget.import?.tax.toStringAsFixed(2) ?? ''));

      encumbrance.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.encumbrance == 0
                  ? ''
                  : widget.import?.encumbrance.toStringAsFixed(2) ?? ''));

      selectiveTax.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.selectiveTax == 0
                  ? ''
                  : widget.import?.selectiveTax.toStringAsFixed(2) ?? ''));

      fines.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.fines == 0
                  ? ''
                  : widget.import?.fines.toStringAsFixed(2) ?? ''));

      surcharges.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.surcharges == 0
                  ? ''
                  : widget.import?.surcharges.toStringAsFixed(2) ?? ''));

      dgaServiceFee.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.dgaServiceFee == 0
                  ? ''
                  : widget.import?.dgaServiceFee.toStringAsFixed(2) ?? ''));

      otherConcepts.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.otherConcepts == 0
                  ? ''
                  : widget.import?.otherConcepts.toStringAsFixed(2) ?? ''));

      total.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.import?.total == 0
                  ? ''
                  : widget.import?.total.toStringAsFixed(2) ?? ''));

      receiptNumber.value =
          TextEditingValue(text: widget.import?.receiptNumber ?? '');
      invoiceNumber.value =
          TextEditingValue(text: widget.import?.invoiceNumber ?? '');
      paymentDate = widget.import?.paymentDate;
      invoiceDate = widget.import?.invoiceDate;
    }
  }

  @override
  initState() {
    paymentDate = DateTimeField.combine(widget.companyDetailsPage.startDate,
        const TimeOfDay(hour: 0, minute: 0));

    invoiceDate = DateTimeField.combine(widget.companyDetailsPage.startDate,
        const TimeOfDay(hour: 0, minute: 0));

    setupEditionMode();

    paymentDateLabel.add(paymentDate!.format(payload: 'DD/MM/YYYY HH:mm'));

    invoiceDateLabel.add(invoiceDate!.format(payload: 'DD/MM/YYYY HH:mm'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Dialog(
          child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: SizedBox(
                  width: 450,
                  child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(title,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor)),
                              const Spacer(),
                              IconButton(
                                  onPressed: () => Get.back(),
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: declarationNumber,
                                      validator: (val) => val!.isEmpty
                                          ? 'CAMPO REQUERIDO'
                                          : null,
                                      style: const TextStyle(fontSize: 18),
                                      decoration: const InputDecoration(
                                          hintText: 'NUMERO DE DECLARACION',
                                          labelText: 'NUMERO DE DECLARACION',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: cif,
                                      style: const TextStyle(fontSize: 18),
                                      inputFormatters: [myformatter],
                                      decoration: const InputDecoration(
                                          hintText: 'CIF',
                                          labelText: 'CIF',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    DateSelectorWidget(
                                      stream: paymentDateLabel,
                                      onSelected: onSelected,
                                      isImportMode: true,
                                      hintText: 'FECHA DE PAGO',
                                      labelText: 'FECHA DE PAGO',
                                      startDate: paymentDate!,
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: receiptNumber,
                                      validator: (val) => val!.isEmpty
                                          ? 'CAMPO REQUERIDO'
                                          : null,
                                      style: const TextStyle(fontSize: 18),
                                      decoration: const InputDecoration(
                                          hintText: 'NUMERO DE RECIBO',
                                          labelText: 'NUMERO DE RECIBO',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: invoiceNumber,
                                      validator: (val) => val!.isEmpty
                                          ? 'CAMPO REQUERIDO'
                                          : null,
                                      style: const TextStyle(fontSize: 18),
                                      decoration: const InputDecoration(
                                          hintText: 'NUMERO DE FACTURA',
                                          labelText: 'NUMERO DE FACTURA',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    DateSelectorWidget(
                                        stream: invoiceDateLabel,
                                        onSelected: onSelectedInvoiceDate,
                                        isImportMode: true,
                                        hintText: 'FECHA DE FACTURA',
                                        labelText: 'FECHA DE FACTURA',
                                        startDate: invoiceDate!),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: tax,
                                      style: const TextStyle(fontSize: 18),
                                      inputFormatters: [myformatter],
                                      decoration: const InputDecoration(
                                          hintText: 'ITBIS',
                                          labelText: 'ITBIS',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: encumbrance,
                                      style: const TextStyle(fontSize: 18),
                                      inputFormatters: [myformatter],
                                      decoration: const InputDecoration(
                                          hintText: 'GRAVAMEN',
                                          labelText: 'GRAVAMEN',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: selectiveTax,
                                      style: const TextStyle(fontSize: 18),
                                      inputFormatters: [myformatter],
                                      decoration: const InputDecoration(
                                          hintText: 'IMPUESTO SELECTIVOS',
                                          labelText: 'IMPUESTO SELECTIVOS',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: fines,
                                      style: const TextStyle(fontSize: 18),
                                      inputFormatters: [myformatter],
                                      decoration: const InputDecoration(
                                          hintText: 'MULTAS',
                                          labelText: 'MULTAS',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: surcharges,
                                      style: const TextStyle(fontSize: 18),
                                      inputFormatters: [myformatter],
                                      decoration: const InputDecoration(
                                          hintText: 'RECARGOS',
                                          labelText: 'RECARGOS',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: dgaServiceFee,
                                      style: const TextStyle(fontSize: 18),
                                      inputFormatters: [myformatter],
                                      decoration: const InputDecoration(
                                          hintText: 'TASA DE SERVICIO DGA',
                                          labelText: 'TASA DE SERVICIO DGA',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: otherConcepts,
                                      inputFormatters: [myformatter],
                                      style: const TextStyle(fontSize: 18),
                                      decoration: const InputDecoration(
                                          hintText: 'OTROS CONCEPTOS',
                                          labelText: 'OTROS CONCEPTOS',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: total,
                                      validator: (val) => val!.isEmpty
                                          ? 'CAMPO REQUERIDO'
                                          : null,
                                      style: const TextStyle(fontSize: 18),
                                      inputFormatters: [myformatter],
                                      decoration: const InputDecoration(
                                          hintText: 'TOTAL',
                                          labelText: 'TOTAL',
                                          border: OutlineInputBorder()),
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                )),
                          ),
                          Row(
                            children: [
                              widget.isEditing
                                  ? Expanded(
                                      child: SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                          onPressed: deleteImport,
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .error)),
                                          child: const Text(
                                              'ELIMINAR IMPORTACION')),
                                    ))
                                  : Container(),
                              widget.isEditing
                                  ? const SizedBox(width: 15)
                                  : Container(),
                              Expanded(
                                  child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                    onPressed: onSubmit, child: Text(btnTitle)),
                              ))
                            ],
                          )
                        ],
                      )))),
        )));
  }
}
