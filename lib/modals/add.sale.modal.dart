// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:uresaxapp/models/type.of.income.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/date.selector.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uresaxapp/widgets/ncf-editor-widget.dart';
import 'package:uresaxapp/widgets/rnc.query.widget.dart';
import 'package:uresaxapp/widgets/widget.concept.selector.dart';
import 'package:uuid/uuid.dart';

class AddSaleModal extends StatefulWidget {
  bool isEditing;
  Sale? sale;
  List<NcfType> ncfs;
  List<TypeOfIncome> typeOfIncomes;
  List<Concept> concepts;

  CompanyDetailsPage companyDetailsPage;

  AddSaleModal(
      {super.key,
      this.isEditing = false,
      this.sale,
      required this.ncfs,
      required this.typeOfIncomes,
      required this.concepts,
      required this.companyDetailsPage});

  @override
  State<AddSaleModal> createState() => _AddSaleModalState();
}

class _AddSaleModalState extends State<AddSaleModal> {
  TextEditingController rnc = TextEditingController();

  TextEditingController company = TextEditingController();

  int? currentIdValue = 1;

  String? currentTypeOfIncome;

  NcfType? currentNcfType;

  int? currentNcfTypeId;

  NcfType? currentNcfModifedType;

  int? currentNcfModifedId;

  TextEditingController ncf = TextEditingController();

  TextEditingController ncfModifed = TextEditingController();

  StreamController<String?> ncfDate = StreamController();

  TextEditingController total = TextEditingController();

  TextEditingController totalG = TextEditingController();

  TextEditingController tax = TextEditingController();

  TextEditingController totalEx = TextEditingController();

  TextEditingController rate = TextEditingController();

  TextEditingController retentionTaxByOthers = TextEditingController();

  TextEditingController retentionTaxByOthersPercent = TextEditingController();

  TextEditingController retentionIsrByOthersPercent = TextEditingController();

  TextEditingController taxPerceived = TextEditingController();

  TextEditingController incomeByThirdParties = TextEditingController();

  TextEditingController isrPerceived = TextEditingController();

  TextEditingController selectiveConsumptionTax = TextEditingController();

  TextEditingController otherTaxesFees = TextEditingController();

  TextEditingController legalTipAmount = TextEditingController();

  TextEditingController effective = TextEditingController();

  TextEditingController checkTransferDeposit = TextEditingController();

  TextEditingController debitCreditCard = TextEditingController();

  TextEditingController saleOnCredit = TextEditingController();

  TextEditingController vouchersOrGiftCertificates = TextEditingController();

  TextEditingController swap = TextEditingController();

  TextEditingController otherFormsOfSales = TextEditingController();

  Concept? currentConcept;

  bool isLoading = false;

  bool calculated = false;

  String? defaultTotal;

  String? defaultTax;

  String? defaultTotalEx;

  StreamController<String?> ncfPaymentDate = StreamController();

  DateTime? ncfPayDate;

  DateTime? ncfRetentionDate;

  late DateTime startDate;

  final formKey = GlobalKey<FormState>();

  final focusNode = FocusNode();

  void distribuirMontos() {
    final total = double.tryParse(totalG.text.replaceAll(',', '')) ?? 0;
    final retencion =
        double.tryParse(retentionTaxByOthers.text.replaceAll(',', '')) ?? 0;
    final totalAPagar = total - retencion;

    final efectivoAmount =
        double.tryParse(effective.text.replaceAll(',', '')) ?? 0;
    final transferenciaAmount =
        double.tryParse(checkTransferDeposit.text.replaceAll(',', '')) ?? 0;
    final tarjetaAmount =
        double.tryParse(debitCreditCard.text.replaceAll(',', '')) ?? 0;
    final creditoAmount =
        double.tryParse(saleOnCredit.text.replaceAll(',', '')) ?? 0;

    final pagado =
        efectivoAmount + transferenciaAmount + tarjetaAmount + creditoAmount;
    double restante = totalAPagar - pagado;

    print(restante);

    // Distribuir el restante entre campos vacíos
    final campos = <TextEditingController>[
      effective,
      checkTransferDeposit,
      debitCreditCard,
      saleOnCredit,
    ];

    if (restante <= 0 || campos.isEmpty) return;

    final porCampo = restante / campos.length;

    for (final controller in campos) {
      controller.value = myformatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: porCampo.toStringAsFixed(2)),
      );
    }
  }

  String get title {
    return widget.isEditing ? 'EDITANDO VENTA...' : 'AÑADIENDO VENTA...';
  }

  String get btnTitle {
    return widget.isEditing ? 'EDITAR VENTA' : 'AÑADIR VENTA';
  }

  String? _validateTax(val) {
    if (val != null && val.isNotEmpty) {
      var n1 = double.tryParse(totalG.text.replaceAll(',', '')) ?? 0;
      var n2 = double.parse(val.replaceAll(',', ''));
      var net = n1 / 1.18;
      var t = double.parse(((net * 0.18)).toStringAsFixed(2));
      if (n2 > t) return 'EL ITBIS ES MAYOR QUE LA TASA APLICADA POR LEY';
    }
    return null;
  }

  String? _validateTotal(val) {
    if (val == null || val == '') return 'CAMPO REQUERIDO';
    var n1 = double.parse(val.replaceAll(',', ''));
    var n2 = double.tryParse(tax.text.replaceAll(',', '')) ?? 0;
    if (n1 < n2) return 'EL TOTAL ES MENOR QUE EL ITBIS APLICADO';
    return null;
  }

  validateRate() {
    try {
      final n = double.tryParse(rate.text);
      final n2 = double.tryParse(totalEx.text.replaceAll(',', ''));

      if (calculated) {
        totalEx.value = TextEditingValue(text: defaultTotalEx ?? '');
        total.value = TextEditingValue(text: defaultTotal ?? '');
        tax.value = TextEditingValue(text: defaultTax ?? '');
        calculated = false;
        setState(() {});
        return;
      }

      if (n2 != null && n != null) {
        var r1 = n2 * n;
        var net = r1 / 1.18;
        var t = net * 0.18;
        var tt = net + t;

        totalG.value = myformatter.formatEditUpdate(TextEditingValue.empty,
            TextEditingValue(text: tt.toStringAsFixed(2)));
        tax.value = myformatter.formatEditUpdate(TextEditingValue.empty,
            TextEditingValue(text: t.toStringAsFixed(2)));
        total.value = myformatter.formatEditUpdate(TextEditingValue.empty,
            TextEditingValue(text: net.toStringAsFixed(2)));
        calculated = true;
      }
      setState(() {});
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  onSubmit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (currentConcept == null) {
          throw 'SELECCIONA UN CONCEPTO';
        }

        if (currentNcfType == null) {
          throw 'EL NCF ESTA VACIO';
        }

        var sale = Sale(
          id: widget.sale != null ? widget.sale!.id : const Uuid().v1(),
          totalInForeignCurrency: totalEx.text.isEmpty
              ? 0
              : double.tryParse(totalEx.text.replaceAll(',', '')),
          rate: rate.text.isEmpty
              ? 0
              : double.tryParse(rate.text.replaceAll(',', '')),
          companyId: widget.companyDetailsPage.company.id!,
          authorId: User.current!.id!,
          rncOrId: rnc.text,
          idType: currentIdValue!,
          conceptId: currentConcept?.id ?? -1,
          invoiceNcfTypeId: currentNcfTypeId!,
          invoiceNcf: '${currentNcfType!.ncfTag}${ncf.text}',
          invoiceNcfModifedTypeId: currentNcfModifedId,
          invoiceNcfModifed: currentNcfModifedType != null
              ? '${currentNcfModifedType!.ncfTag}${ncfModifed.text}'
              : null,
          typeOfIncome: currentTypeOfIncome!,
          invoiceNcfDate: startDate,
          retentionDate: ncfRetentionDate,
          total: double.tryParse(total.text.replaceAll(',', '')) ?? 0,
          tax: double.tryParse(tax.text.replaceAll(',', '')) ?? 0,
          taxRetentionOthers:
              double.tryParse(retentionTaxByOthers.text.replaceAll(',', '')) ??
                  0,
          perceivedTax:
              double.tryParse(taxPerceived.text.replaceAll(',', '')) ?? 0,
          retentionOthers:
              double.tryParse(incomeByThirdParties.text.replaceAll(',', '')) ??
                  0,
          perceivedISR:
              double.tryParse(isrPerceived.text.replaceAll(',', '')) ?? 0,
          selectiveConsumptionTax: double.tryParse(
                  selectiveConsumptionTax.text.replaceAll(',', '')) ??
              0,
          otherTaxesFees:
              double.tryParse(otherTaxesFees.text.replaceAll(',', '')) ?? 0,
          legalTipAmount:
              double.tryParse(legalTipAmount.text.replaceAll(',', '')) ?? 0,
          effective: double.tryParse(effective.text.replaceAll(',', '')) ?? 0,
          checkTransferDeposit:
              double.tryParse(checkTransferDeposit.text.replaceAll(',', '')) ??
                  0,
          debitCreditCard:
              double.tryParse(debitCreditCard.text.replaceAll(',', '')) ?? 0,
          saleOnCredit:
              double.tryParse(saleOnCredit.text.replaceAll(',', '')) ?? 0,
          vouchersOrGiftCertificates: double.tryParse(
                  vouchersOrGiftCertificates.text.replaceAll(',', '')) ??
              0,
          swap: double.tryParse(swap.text.replaceAll(',', '')) ?? 0,
          otherFormsOfSales:
              double.tryParse(otherFormsOfSales.text.replaceAll(',', '')) ?? 0,
        );

        if (widget.sale?.invoiceNcf != sale.invoiceNcf ||
            widget.sale?.rncOrId != sale.rncOrId) {
          await sale.checkIfExists(
              companyId: widget.companyDetailsPage.company.id!,
              saleId: sale.id,
              startDate: sale.invoiceNcfDate.startOfMonth(),
              endDate: sale.invoiceNcfDate.endOfMonth());
        }

        var c = Get.find<SalesController>();

        if (!widget.isEditing) {
          await sale.create();
        } else {
          await sale.update();
        }

        var start = sale.invoiceNcfDate.startOfMonth();

        var end = sale.invoiceNcfDate.endOfMonth();

        if (ncfRetentionDate != null) {
          if (!DateTime.parse(ncfRetentionDate.toString())
              .isAtSameMonthAs(startDate)) {
            start = DateTime.parse(ncfRetentionDate.toString()).startOfMonth();
            end = DateTime.parse(ncfRetentionDate.toString()).endOfMonth();
          }
        }

        widget.companyDetailsPage.startDate = start;

        widget.companyDetailsPage.endDate = end;

        widget.companyDetailsPage.date.value = TextEditingValue(
            text:
                '${start.format(payload: 'DD/MM/YYYY')} - ${end.format(payload: 'DD/MM/YYYY')}');

        await storage.write(
            key: "STARTDATE_SALES_${widget.companyDetailsPage.company.id}",
            value: start.format(payload: 'YYYY-MM-DD'));
        await storage.write(
            key: 'ENDDATE_SALES_${widget.companyDetailsPage.company.id}',
            value: end.format(payload: 'YYYY-MM-DD'));

        c.sales.value = await Sale.get(
            companyId: widget.companyDetailsPage.company.id!,
            startDate: start,
            endDate: end);

        Get.back();

        if (widget.isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE ACTUALIZO LA VENTA')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE INSERTO LA VENTA')));
        }
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  deleteSale() async {
    try {
      await widget.sale?.delete();
      var c = Get.find<SalesController>();
      c.sales.value = await Sale.get(
          companyId: widget.companyDetailsPage.company.id!,
          startDate: widget.companyDetailsPage.startDate,
          endDate: widget.companyDetailsPage.endDate);
      Get.back(result: 'DELETE');
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  setupEditContent() {
    if (widget.sale != null) {
      rnc.value = TextEditingValue(text: widget.sale!.rncOrId);
      startDate = widget.sale!.invoiceNcfDate;
      if (widget.sale?.retentionDate != null) {
        ncfPayDate = widget.sale!.retentionDate;
        ncfRetentionDate = ncfPayDate;
        ncfPaymentDate.add('${ncfPayDate?.format(payload: 'DD/MM/YYYY')}');
      }
      currentIdValue = widget.sale?.idType;
      currentConcept =
          Concept(id: widget.sale?.conceptId, name: widget.sale?.conceptName);
      currentNcfTypeId = widget.sale?.invoiceNcfTypeId;
      currentNcfType =
          widget.ncfs.firstWhere((element) => element.id == currentNcfTypeId);
      ncf.value = TextEditingValue(text: widget.sale!.invoiceNcf.substring(3));

      if (widget.sale?.invoiceNcfModifedTypeId != null) {
        currentNcfModifedId = widget.sale?.invoiceNcfModifedTypeId;
        currentNcfModifedType = widget.ncfs
            .firstWhere((element) => element.id == currentNcfModifedId);
        ncfModifed.value = TextEditingValue(
            text: widget.sale!.invoiceNcfModifed!.substring(3));
      }

      currentTypeOfIncome = widget.sale?.typeOfIncome;
      totalG.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text:
                  (widget.sale!.total + widget.sale!.tax).toStringAsFixed(2)));
      total.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.total == 0
                  ? ''
                  : widget.sale!.total.toStringAsFixed(2)));

      tax.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.tax == 0
                  ? ''
                  : widget.sale!.tax.toStringAsFixed(2)));

      retentionTaxByOthers.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.taxRetentionOthers == 0
                  ? ''
                  : widget.sale!.taxRetentionOthers.toStringAsFixed(2)));

      taxPerceived.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.perceivedTax == 0
                  ? ''
                  : widget.sale!.perceivedTax.toStringAsFixed(2)));

      incomeByThirdParties.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.retentionOthers == 0
                  ? ''
                  : widget.sale!.retentionOthers.toStringAsFixed(2)));

      isrPerceived.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.perceivedISR == 0
                  ? ''
                  : widget.sale!.perceivedISR.toStringAsFixed(2)));

      selectiveConsumptionTax.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.selectiveConsumptionTax == 0
                  ? ''
                  : widget.sale!.selectiveConsumptionTax.toStringAsFixed(2)));

      otherTaxesFees.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.otherTaxesFees == 0
                  ? ''
                  : widget.sale!.otherTaxesFees.toStringAsFixed(2)));

      legalTipAmount.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.legalTipAmount == 0
                  ? ''
                  : widget.sale!.legalTipAmount.toStringAsFixed(2)));

      effective.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.effective == 0
                  ? ''
                  : widget.sale!.effective.toStringAsFixed(2)));

      checkTransferDeposit.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.checkTransferDeposit == 0
                  ? ''
                  : widget.sale!.checkTransferDeposit.toStringAsFixed(2)));

      debitCreditCard.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.debitCreditCard == 0
                  ? ''
                  : widget.sale!.debitCreditCard.toStringAsFixed(2)));

      saleOnCredit.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.saleOnCredit == 0
                  ? ''
                  : widget.sale!.saleOnCredit.toStringAsFixed(2)));

      vouchersOrGiftCertificates.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.vouchersOrGiftCertificates == 0
                  ? ''
                  : widget.sale!.vouchersOrGiftCertificates
                      .toStringAsFixed(2)));

      swap.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.swap == 0
                  ? ''
                  : widget.sale!.swap.toStringAsFixed(2)));

      otherFormsOfSales.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.otherFormsOfSales == 0
                  ? ''
                  : widget.sale!.otherFormsOfSales.toStringAsFixed(2)));

      totalEx.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.totalInForeignCurrency == 0
                  ? ''
                  : widget.sale!.totalInForeignCurrency!.toStringAsFixed(2)));

      rate.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.sale?.rate == 0
                  ? ''
                  : widget.sale!.rate!.toStringAsFixed(2)));

      defaultTotal = total.text;
      defaultTax = tax.text;
      defaultTotalEx = totalEx.text;
    }
  }

  sumInfo() {
    var n1 = double.tryParse(totalG.text.replaceAll(',', '')) ?? 0;
    var n2 = double.tryParse(tax.text.replaceAll(',', '')) ?? 0;
    var t = n1 - n2;
    if (t != 0) {
      total.value = myformatter.formatEditUpdate(TextEditingValue.empty,
          TextEditingValue(text: (t).toStringAsFixed(2)));
    }

    /*if (ncfRetentionDate != null) {
      var percent = double.tryParse(
              retentionTaxByOthersPercent.text.replaceAll(',', '')) ??
          30;

      var n3 = n2 * (percent / 100);

      retentionTaxByOthersPercent.value =
          TextEditingValue(text: percent.toStringAsFixed(0));
      retentionTaxByOthers.value = myformatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: n3.toStringAsFixed(2)));
    }*/
  }

  init() async {
    startDate = widget.companyDetailsPage.startDate;
    await setupEditContent();
    totalG.addListener(sumInfo);
    tax.addListener(sumInfo);
    ncfDate.add(startDate.format(payload: 'DD/MM/YYYY'));
    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Widget get content {
    return Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Theme.of(context).primaryColor)),
                const Spacer(),
                IconButton(
                    onPressed: () => Get.back(), icon: const Icon(Icons.close))
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
                child: ListView(
              shrinkWrap: true,
              children: [
                RncQueryWidget(
                    rnc: rnc,
                    hintText: 'CLIENTE',
                    company: company,
                    onSelectedCorrectRnc: (c) {
                      if (rnc.text.length == 9) {
                        currentIdValue = 1;
                      } else if (rnc.text.length == 11) {
                        currentIdValue = 2;
                      } else if (rnc.text.length == 15) {
                        currentIdValue = 3;
                      } else {
                        currentIdValue = null;
                      }
                      setState(() {});
                    }),
                const SizedBox(height: 20),
                IgnorePointer(
                    ignoring: true,
                    child: DropdownButtonFormField(
                      value: currentIdValue,
                      onChanged: (c) {},
                      decoration: InputDecoration(
                        labelText: 'TIPO DE IDENTIFICACION',
                        enabledBorder: const OutlineInputBorder(
                          //<-- SEE HERE
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          //<-- SEE HERE
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error)),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error)),
                      ),
                      hint: const Text('TIPO DE IDENTIFICACION'),
                      dropdownColor: Colors.white,
                      enableFeedback: false,
                      isExpanded: true,
                      focusColor: Colors.white,
                      items: [
                        {'name': 'TIPO DE IDENTIFICACION', 'value': null},
                        {'name': 'RNC', 'value': 1},
                        {'name': 'CEDULA', 'value': 2},
                        {'name': 'PASAPORTE', 'value': 3}
                      ]
                          .map((e) => DropdownMenuItem(
                              enabled: false,
                              value: e['value'],
                              child: Text(e['name'].toString())))
                          .toList(),
                    )),
                const SizedBox(height: 20),
                DateSelectorWidget(
                    onSelected: (date) {
                      startDate = date!;
                      ncfPayDate = date;
                      setState(() {});
                    },
                    stream: ncfDate,
                    labelText: "FECHA DE EMISION DE NCF",
                    hintText: "FECHA DE EMISION DE NCF",
                    startDate: startDate,
                    date: startDate),
                const SizedBox(height: 20),
                SelectorConceptWidget(
                    value: currentConcept,
                    onSelected: (current, index) {
                      currentConcept = current;
                    }),
                const SizedBox(height: 20),
                NcfEditorWidget(
                    currentNcfTypeId: currentNcfTypeId,
                    controller: ncf,
                    ncfs: widget.ncfs,
                    hintText: 'NCF',
                    onChanged: (item) {
                      currentNcfType = item;
                      currentNcfTypeId = item?.id;
                    }),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: currentTypeOfIncome,
                  validator: (val) => val == null ? 'CAMPO REQUERIDO' : null,
                  onChanged: (c) {
                    currentTypeOfIncome = c;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'TIPO DE INGRESO',
                    enabledBorder: const OutlineInputBorder(
                      //<-- SEE HERE
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      //<-- SEE HERE
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                  hint: const Text('TIPO DE INGRESO'),
                  dropdownColor: Colors.white,
                  enableFeedback: false,
                  isExpanded: true,
                  focusColor: Colors.white,
                  items: widget.typeOfIncomes
                      .map((e) => DropdownMenuItem(
                          value: e.id, child: Text(e.name.toString())))
                      .toList(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: totalG,
                  validator: _validateTotal,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'TOTAL FACTURADO',
                      labelText: 'TOTAL FACTURADO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: tax,
                  focusNode: focusNode,
                  validator: _validateTax,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'ITBIS FACTURADO',
                      labelText: 'ITBIS FACTURADO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: total,
                  readOnly: true,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'TOTAL NETO',
                      labelText: 'TOTAL NETO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 18),
                    controller: totalEx,
                    inputFormatters: [myformatter],
                    decoration: const InputDecoration(
                        hintText: 'TOTAL FACTURADO EN MONEDA EXTRANJERA',
                        labelText: 'TOTAL FACTURADO EN MONEDA EXTRANJERA',
                        border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 18),
                    controller: rate,
                    inputFormatters: [myformatter],
                    decoration: InputDecoration(
                        hintText: 'TASA',
                        labelText: 'TASA',
                        suffixIcon: Wrap(children: [
                          IconButton(
                              onPressed: () => validateRate(),
                              icon: !calculated
                                  ? const Icon(Icons.calculate)
                                  : const Icon(Icons.close)),
                          const SizedBox(width: 10)
                        ]),
                        border: const OutlineInputBorder()),
                  ),
                ),
                const SizedBox(height: 15),
                NcfEditorWidget(
                    currentNcfTypeId: currentNcfModifedId,
                    controller: ncfModifed,
                    ncfs: widget.ncfs,
                    hintText: 'NCF MODIFICADO',
                    onChanged: (item) {
                      currentNcfModifedType = item;
                      currentNcfModifedId = item?.id;
                    }),
                DateSelectorWidget(
                    onSelected: (date) {
                      ncfPayDate = date;
                      ncfRetentionDate = date;
                    },
                    stream: ncfPaymentDate,
                    isPayNcf: true,
                    labelText: "FECHA DE RETENCION DE NCF",
                    hintText: "FECHA DE RETENCION DE NCF",
                    startDate: startDate,
                    date: ncfPayDate),
                const SizedBox(height: 20),
                TextFormField(
                  controller: retentionTaxByOthers,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: InputDecoration(
                      hintText: 'ITBIS RETENIDO POR TERCEROS',
                      labelText: 'ITBIS RETENIDO POR TERCEROS',
                      border: OutlineInputBorder(),
                      suffixIcon: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextFormField(
                          controller: retentionTaxByOthersPercent,
                          onChanged: (val) {
                            var n1 = double.tryParse(val.replaceAll(',', ''));

                            var n2 =
                                double.tryParse(tax.text.replaceAll(',', ''));

                            if (n1 is double && n2 is double) {
                              var n3 = n2 * (n1 / 100);

                              retentionTaxByOthers.value =
                                  myformatter.formatEditUpdate(
                                      TextEditingValue.empty,
                                      TextEditingValue(
                                          text: n3.toStringAsFixed(2)));
                            }
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(hintText: '0%'),
                        ),
                      )),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: taxPerceived,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'ITBIS PERCIBIDO',
                      labelText: 'ITBIS PERCIBIDO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: incomeByThirdParties,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: InputDecoration(
                      hintText: 'RETENCION DE RENTA POR TERCEROS',
                      labelText: 'RETENCION DE RENTA POR TERCEROS',
                      border: OutlineInputBorder(),
                      suffixIcon: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextFormField(
                          controller: retentionIsrByOthersPercent,
                          onChanged: (val) {
                            var n1 = double.tryParse(val.replaceAll(',', ''));

                            var n2 =
                                double.tryParse(total.text.replaceAll(',', ''));

                            if (n1 is double && n2 is double) {
                              var n3 = n2 * (n1 / 100);

                              incomeByThirdParties.value =
                                  myformatter.formatEditUpdate(
                                      TextEditingValue.empty,
                                      TextEditingValue(
                                          text: n3.toStringAsFixed(2)));
                            }
                          },
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(hintText: '0%'),
                        ),
                      )),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: isrPerceived,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'ISR PERCIBIDO',
                      labelText: 'ISR PERCIBIDO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: selectiveConsumptionTax,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'IMPUESTO SELECTIVO AL CONSUMO',
                      labelText: 'IMPUESTO SELECTIVO AL CONSUMO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: otherTaxesFees,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'OTROS IMPUESTOS O TASAS',
                      labelText: 'OTROS IMPUESTOS O TASAS',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: legalTipAmount,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'MONTO PROPINA LEGAL',
                      labelText: 'MONTO PROPINA LEGAL',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: effective,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  onChanged: (val) {
                    var total =
                        double.tryParse(totalG.text.replaceAll(',', '')) ?? 0;

                    var retentionItbis = double.tryParse(
                            retentionTaxByOthers.text.replaceAll(',', '')) ??
                        0;
                    var retentionIsr = double.tryParse(
                            incomeByThirdParties.text.replaceAll(',', '')) ??
                        0;

                    var totalToPay = total - (retentionItbis + retentionIsr);

                    var effectiveAmount =
                        double.tryParse(effective.text.replaceAll(',', '')) ??
                            0;

                    var debitCreditCardAmount = double.tryParse(
                            debitCreditCard.text.replaceAll(',', '')) ??
                        0;

                    var saleOnCreditAmount = double.tryParse(
                            saleOnCredit.text.replaceAll(',', '')) ??
                        0;

                    checkTransferDeposit.value = myformatter.formatEditUpdate(
                        TextEditingValue.empty,
                        TextEditingValue(
                            text: (totalToPay -
                                    (effectiveAmount +
                                        debitCreditCardAmount +
                                        saleOnCreditAmount))
                                .toStringAsFixed(2)));
                  },
                  decoration: InputDecoration(
                    hintText: 'EFECTIVO',
                    labelText: 'EEFCTIVO',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: checkTransferDeposit,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  onChanged: (val) {},
                  decoration: InputDecoration(
                      hintText: 'CHEQUE / TRANSFERENCIA / DEPOSITO',
                      labelText: 'CHEQUE / TRANSFERENCIA / DEPOSITO',
                      suffixIcon: IconButton(
                          onPressed: () {
                            var total = double.tryParse(
                                    totalG.text.replaceAll(',', '')) ??
                                0;

                            var retentionItbis = double.tryParse(
                                    retentionTaxByOthers.text
                                        .replaceAll(',', '')) ??
                                0;

                            var retentionIsr = double.tryParse(
                                    incomeByThirdParties.text
                                        .replaceAll(',', '')) ??
                                0;

                            var totalToPay =
                                total - (retentionItbis + retentionIsr);

                            var effectiveAmount = double.tryParse(
                                    effective.text.replaceAll(',', '')) ??
                                0;

                            var debitOrCreditCardAmount = double.tryParse(
                                    debitCreditCard.text.replaceAll(',', '')) ??
                                0;

                            var saleOnCreditAmount = double.tryParse(
                                    saleOnCredit.text.replaceAll(',', '')) ??
                                0;

                            totalToPay -= (effectiveAmount +
                                debitOrCreditCardAmount +
                                saleOnCreditAmount);
                            checkTransferDeposit.value =
                                myformatter.formatEditUpdate(
                                    TextEditingValue.empty,
                                    TextEditingValue(
                                        text: totalToPay.toStringAsFixed(2)));
                          },
                          icon: Icon(Icons.arrow_right)),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: debitCreditCard,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  onChanged: (val) {
                    var total =
                        double.tryParse(totalG.text.replaceAll(',', '')) ?? 0;

                    var retentionItbis = double.tryParse(
                            retentionTaxByOthers.text.replaceAll(',', '')) ??
                        0;
                    var retentionIsr = double.tryParse(
                            incomeByThirdParties.text.replaceAll(',', '')) ??
                        0;

                    var totalToPay = total - (retentionItbis + retentionIsr);

                    var debitCreditCardAmount = double.tryParse(
                            debitCreditCard.text.replaceAll(',', '')) ??
                        0;

                    var effectiveAmount =
                        double.tryParse(effective.text.replaceAll(',', '')) ??
                            0;

                    checkTransferDeposit.value = myformatter.formatEditUpdate(
                        TextEditingValue.empty,
                        TextEditingValue(
                            text: (totalToPay -
                                    (debitCreditCardAmount + effectiveAmount))
                                .toStringAsFixed(2)));
                  },
                  decoration: InputDecoration(
                    hintText: 'TARJETA DE DEBITO / CREDITO',
                    labelText: 'TARJETA DE DEBITO / CREDITO',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: saleOnCredit,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  onChanged: (val) {
                    var total =
                        double.tryParse(totalG.text.replaceAll(',', '')) ?? 0;

                    var retentionItbis = double.tryParse(
                            retentionTaxByOthers.text.replaceAll(',', '')) ??
                        0;
                    var retentionIsr = double.tryParse(
                            incomeByThirdParties.text.replaceAll(',', '')) ??
                        0;

                    var totalToPay = total - (retentionItbis + retentionIsr);

                    var saleOnCreditAmount = double.tryParse(
                            saleOnCredit.text.replaceAll(',', '')) ??
                        0;

                    var debitCreditCardAmount = double.tryParse(
                            debitCreditCard.text.replaceAll(',', '')) ??
                        0;

                    var effectiveAmount =
                        double.tryParse(effective.text.replaceAll(',', '')) ??
                            0;

                    checkTransferDeposit.value = myformatter.formatEditUpdate(
                        TextEditingValue.empty,
                        TextEditingValue(
                            text: (totalToPay -
                                    (saleOnCreditAmount +
                                        effectiveAmount +
                                        debitCreditCardAmount))
                                .toStringAsFixed(2)));
                  },
                  decoration: const InputDecoration(
                      hintText: 'VENTA A CREDITO',
                      labelText: 'VENTA A CREDITO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: vouchersOrGiftCertificates,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'BONOS O CERTIFICADOS DE REGALO',
                      labelText: 'BONOS O CERTIFICADOS DE REGALO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: swap,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'PERMUTA',
                      labelText: 'PERMUTA',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: otherFormsOfSales,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'OTRAS FORMAS DE VENTA',
                      labelText: 'OTRAS FORMAS DE VENTA',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
              ],
            )),
            Row(
              children: [
                Expanded(
                    child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: onSubmit,
                      child:
                          Text(btnTitle, style: const TextStyle(fontSize: 17))),
                ))
              ],
            )
          ],
        ));
  }

  @override
  dispose() {
    rnc.dispose();
    total.dispose();
    tax.dispose();
    widget.ncfs = [];
    widget.typeOfIncomes = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: AlertDialog(
                contentPadding: const EdgeInsets.all(15),
                content: SizedBox(width: modalSalesWidth, child: content))));
  }
}
