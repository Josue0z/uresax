// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:simple_moment/simple_moment.dart' as sm;
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/models/banking.dart';
import 'package:uresaxapp/models/check.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/invoicetype.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:uresaxapp/models/payment-method.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/retention.dart';
import 'package:uresaxapp/models/retention.tax.dart';
import 'package:uresaxapp/models/tax.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/date.selector.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uresaxapp/widgets/ncf-editor-widget.dart';
import 'package:uresaxapp/widgets/rnc.query.widget.dart';
import 'package:uresaxapp/widgets/widget.concept.selector.dart';
import '../utils/extra.dart';

class AddPurchaseModal extends StatefulWidget {
  final Purchase? purchase;
  bool isEditing;
  DateTime startDate;
  DateTime? ncfPayDate;
  String startDateLargeAsString;
  CompanyDetailsPage widget;

  Map<String,dynamic> metadata;

  AddPurchaseModal(
      {super.key,
      this.purchase,
      this.isEditing = false,
      required this.startDateLargeAsString,
      required this.widget,
      required this.startDate,
      required this.metadata});

  @override
  State<AddPurchaseModal> createState() => _AddPurchaseModalState();
}

class _AddPurchaseModalState extends State<AddPurchaseModal> {
  int? currentConceptId;
  Concept? currentConcept;
  int? currentBanking;
  int? currentType;
  int? currentPaymentMethod;
  int? currentRetention;
  int? currentNcfTypeId;
  NcfType? currentNcfType;
  int? currentNcfModifedTypeId;
  NcfType? currentNcfModifedType;
  int? currentRetentionTaxId;

  bool isCorrectRnc = false;

  bool show = false;

  bool isAuthorized = true;

  bool isLoading = true;

  bool isError = false;

  List<Concept> concepts = [];

  List<Banking> bankings = [];

  List<InvoiceType> invoiceTypes = [];

  List<PaymentMethod> paymentMethods = [];

  List<Retention> retentions = [];

  List<NcfType> ncfs = [];

  List<RetentionTax> retentionTaxes = [];

  List<Tax> taxes = [];

  late DateTime startDate;

  DateTime? endDate;

  DateTime? ncfPayDate;

  DateTime? retentionDate;

  String startDateLargeAsString = '';

  String endDateLargeAsString = '';

  String startDateAsString = '';

  String endDateAsString = '';

  TextEditingController ck = TextEditingController();

  TextEditingController year = TextEditingController();

  TextEditingController day = TextEditingController();

  TextEditingController total = TextEditingController();

  TextEditingController netTotal = TextEditingController();

  TextEditingController totalEx = TextEditingController();

  TextEditingController rate = TextEditingController();

  TextEditingController tax = TextEditingController();

  TextEditingController taxCon = TextEditingController();

  TextEditingController ncf = TextEditingController();

  TextEditingController ncfModifed = TextEditingController();

  TextEditingController invoiceLegalTipAmount = TextEditingController();

  TextEditingController invoiceIsrInPurchases = TextEditingController();

  TextEditingController invoiceTaxInPurchases = TextEditingController();

  TextEditingController invoiceSelectiveConsumptionTax =
      TextEditingController();

  TextEditingController invoiceOthersTaxes = TextEditingController();

  TextEditingController amountPaid = TextEditingController();

  TextEditingController debt = TextEditingController();

  StreamController<String?> ncfDate = StreamController();

  StreamController<String?> ncfPaymentDate = StreamController();

  TextEditingController ckBeneficiary = TextEditingController();

  TextEditingController rnc = TextEditingController();

  TextEditingController company = TextEditingController();

  StreamController<String?> checkController = StreamController<String?>();

  final _formKey = GlobalKey<FormState>();

  Check? currentCheck;

  String? currentCheckId;

  String? defaultTotal;

  String? defaultTax;

  String? defaultTotalEx;

  bool calculated = false;

  bool loading = false;

  String messageError = '';

  bool get isAllCorrect {
    return _formKey.currentState!.validate();
  }

  String get _title {
    return widget.isEditing
        ? 'FACTURA SELECCIONADA...'
        : 'AÑANIENDO FACTURA...';
  }

  String get _titleBtn {
    return widget.isEditing ? 'EDITAR FACTURA' : 'AÑADIR FACTURA';
  }

  Future<List<Purchase>> get get async {
    return await Purchase.get(
        companyId: widget.widget.company.id!,
        startDate: widget.widget.startDate,
        endDate: widget.widget.endDate);
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
        total.value = myformatter.formatEditUpdate(TextEditingValue.empty,
            TextEditingValue(text: tt.toStringAsFixed(2)));
        tax.value = myformatter.formatEditUpdate(TextEditingValue.empty,
            TextEditingValue(text: t.toStringAsFixed(2)));
        calculated = true;
      }
      setState(() {});
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  String? _validateTax(val) {
    if (val != null && val.isNotEmpty) {
      var n1 = double.tryParse(total.text.replaceAll(',', '')) ?? 0;
      var n2 = double.parse(val.replaceAll(',', ''));
      var net = n1 / 1.18;
      var t = double.parse(((net * 0.18)).toStringAsFixed(2));
      if (n2 > t) return 'EL ITBIS ES MAYOR QUE LA TASA APLICADA POR LEY';
    }
    return null;
  }

  String? _validateTotal(val) {
    if (val == null || val == '') {
      netTotal.value = TextEditingValue.empty;
      return 'CAMPO REQUERIDO';
    }
    var n1 = double.parse(val.replaceAll(',', ''));
    var n2 = double.tryParse(tax.text.replaceAll(',', '')) ?? 0;
    if (n1 < n2) return 'EL TOTAL ES MENOR QUE EL ITBIS APLICADO';
    return null;
  }

  String? validateAmountPaid(String? val) {
    var n1 = double.tryParse(val!.replaceAll(',', '')) ?? 0;
    var n2 = double.tryParse(total.text.replaceAll(',', '')) ?? 0;

    if (n1 == 0) {
      debt.value = TextEditingValue.empty;
      return null;
    }

    if (n1 > n2) {
      debt.value = TextEditingValue.empty;
      return 'EL MONTO PAGADO ES MAYOR QUE EL TOTAL FACTURADO';
    } else {
      var de = n2 - n1;
      debt.value = myformatter.formatEditUpdate(TextEditingValue.empty,
          TextEditingValue(text: de.toStringAsFixed(2)));
    }

    return null;
  }



  initElements() async {
    try {
      concepts = widget.metadata['concepts'];

      invoiceTypes =  widget.metadata['invoiceTypes'];

      paymentMethods = widget.metadata['paymentMethods'];

      retentions = widget.metadata['retentions'];

      ncfs = widget.metadata['ncfs'];

      retentionTaxes = widget.metadata['retentionTaxes'];
      startDate = widget.startDate;
      startDateLargeAsString = widget.startDateLargeAsString;
      if (widget.purchase != null && widget.isEditing) {
        if (widget.purchase?.checkId != null) {
          currentCheck = await Check.find(widget.purchase?.checkId);
          currentCheckId = currentCheck?.id;
          checkController.sink.add(currentCheck?.fullName);
        }
        isAuthorized = widget.purchase!.authorized;
        rnc.value = TextEditingValue(text: widget.purchase!.invoiceRnc!);
        ckBeneficiary.value =
            TextEditingValue(text: widget.purchase?.ckBeneficiary ?? '');
        currentConcept = Concept(
          id: widget.purchase?.invoiceConceptId,
          name: widget.purchase?.invoiceConceptName ?? ''
        );

        if (widget.purchase?.invoiceNcfTypeId != null) {
          currentNcfTypeId = widget.purchase?.invoiceNcfTypeId;
          currentNcfType =
              ncfs.firstWhere((element) => element.id == currentNcfTypeId);

          ncf.value = TextEditingValue(
              text: widget.purchase?.invoiceNcf?.substring(3) ?? '');
        }

        currentNcfModifedTypeId = widget.purchase?.invoiceNcfModifedTypeId;

        if (widget.purchase?.invoiceNcfModifedTypeId != null) {
          ncfModifed.value = TextEditingValue(
              text: widget.purchase?.invoiceNcfModifed?.substring(3) ?? '');
        }

        currentType = widget.purchase?.invoiceTypeId;
        currentPaymentMethod = widget.purchase?.invoicePaymentMethodId;
        currentRetention = widget.purchase?.invoiceRetentionId;
        currentBanking = widget.purchase?.invoiceBankingId;
        currentRetentionTaxId = widget.purchase?.invoiceTaxRetentionId;

        ck.value = TextEditingValue(
            text: widget.purchase?.invoiceCk == null
                ? ''
                : widget.purchase!.invoiceCk.toString());
        day.value = TextEditingValue(
            text: widget.purchase?.invoiceNcfDay?.trim() ?? '');
        total.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceTotal!.toStringAsFixed(2)));
        tax.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceTax == 0
                    ? ''
                    : widget.purchase!.invoiceTax!.toStringAsFixed(2)));

        netTotal.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceNetTotal!
                    .toStringAsFixed(2)));

        taxCon.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceTaxCon == 0
                    ? ''
                    : widget.purchase!.invoiceTaxCon!.toStringAsFixed(2)));

        invoiceLegalTipAmount.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceLegalTipAmount == 0
                    ? ''
                    : widget.purchase!.invoiceLegalTipAmount!
                        .toStringAsFixed(2)));

        invoiceTaxInPurchases.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceTaxInPurchases == 0
                    ? ''
                    : widget.purchase!.invoiceTaxInPurchases!
                        .toStringAsFixed(2)));

        invoiceIsrInPurchases.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceIsrInPurchases == 0
                    ? ''
                    : widget.purchase!.invoiceIsrInPurchases!
                        .toStringAsFixed(2)));

        invoiceSelectiveConsumptionTax.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceSelectiveConsumptionTax == 0
                    ? ''
                    : widget.purchase!.invoiceSelectiveConsumptionTax!
                        .toStringAsFixed(2)));

        invoiceOthersTaxes.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceOthersTaxes == 0
                    ? ''
                    : widget.purchase!.invoiceOthersTaxes!.toStringAsFixed(2)));

        totalEx.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase?.totalInForeignCurrency == 0
                    ? ''
                    : widget.purchase!.totalInForeignCurrency!
                        .toStringAsFixed(2)));
        rate.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase?.rate == 0
                    ? ''
                    : widget.purchase!.rate!.toStringAsFixed(2)));

        amountPaid.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase?.amountPaid == 0
                    ? ''
                    : widget.purchase!.amountPaid!.toStringAsFixed(2)));

        currentNcfModifedType =
            ncfs.firstWhere((element) => element.id == currentNcfModifedTypeId);

        startDate = widget.purchase!.invoiceIssueDate!;
        if (widget.purchase?.invoicePayDate != null) {
          ncfPayDate = widget.purchase!.invoicePayDate;
          retentionDate = ncfPayDate;
          ncfPaymentDate
              .add(sm.Moment.fromDate(ncfPayDate!).format('dd/MM/yyyy'));
        }
      }
      endDate = startDate.endOfMonth();
      startDateLargeAsString = startDate.format(payload: 'YYYY-MM-DD');
      endDateLargeAsString = sm.Moment.fromDate(endDate!).format('yyyy-MM-dd');
      ncfDate.add(startDate.format(payload: 'DD/MM/YYYY'));
      defaultTotal = total.text;
      defaultTotalEx = totalEx.text;
      defaultTax = tax.text;
      setState(() {
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        messageError = e.toString();
      });
    }
  }

  resInfo() {
    var n1 = double.tryParse(total.text.replaceAll(',', '')) ?? 0;
    var n2 = double.tryParse(tax.text.replaceAll(',', '')) ?? 0;
    var n3 = double.tryParse(invoiceLegalTipAmount.text.replaceAll(',', '')) ?? 0;
    var n4 = double.tryParse(invoiceSelectiveConsumptionTax.text.replaceAll(',', '')) ?? 0;
    var n5 = double.tryParse(invoiceOthersTaxes.text.replaceAll(',', '')) ?? 0;

    var t = n1 - n2 - n3 - n4 - n5;
    if (t != 0) {
      netTotal.value = myformatter.formatEditUpdate(TextEditingValue.empty,
          TextEditingValue(text: (t).toStringAsFixed(2)));
    }
  }

  init() async {
    if (!mounted) return;
    await initElements();
    total.addListener(resInfo);
    tax.addListener(resInfo);
    invoiceLegalTipAmount.addListener(resInfo);
    invoiceSelectiveConsumptionTax.addListener(resInfo);
    invoiceOthersTaxes.addListener(resInfo);
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> _onSubmit() async {

    if(loading)return;
    
    if (isAllCorrect) {
      setState(() {
        loading = true;
      });
      try {
        var factor = currentNcfTypeId == 4 || currentNcfTypeId == 34 ? -1 : 1;
   
        if (currentConcept == null) {
          throw 'SELECCIONA UN CONCEPTO';
        }

        if (currentNcfModifedTypeId == null &&
            (currentNcfTypeId == 4 || currentNcfTypeId == 34)) {
          throw 'NO PUEDE ESTAR VACIO EL NCF MODIFICADO CON UNA NOTA DE CREDITO';
        }

   
        var purchase = Purchase(
            id: widget.purchase?.id,
            isDuplicate: false,
            totalInForeignCurrency: totalEx.text.isEmpty
                ? 0
                : double.tryParse(totalEx.text.replaceAll(',', '')),
            rate: rate.text.isEmpty
                ? 0
                : double.tryParse(rate.text.replaceAll(',', '')),
            authorized: isAuthorized,
            invoiceRnc: rnc.text,
            invoiceConceptId: currentConcept?.id,
            invoiceTypeId: currentType,
            invoicePaymentMethodId: currentPaymentMethod,
            ckBeneficiary:
                ckBeneficiary.text.isEmpty ? null : ckBeneficiary.text,
            invoiceNcf: currentNcfTypeId != null
                ? '${currentNcfType?.ncfTag}${ncf.text}'
                : null,
            invoiceNcfTypeId: currentNcfType?.id,
            invoiceNcfModifed: currentNcfModifedTypeId != null
                ? '${currentNcfModifedType?.ncfTag}${ncfModifed.text}'
                : null,
            invoiceNcfModifedTypeId: currentNcfModifedType?.id,
            invoiceCompanyId: widget.widget.company.id!,
            invoiceBankingId: currentBanking,
            invoiceIssueDate: startDate,
            invoiceCk: int.tryParse(ck.text.trim()),
            invoiceTaxInPurchases: invoiceTaxInPurchases.text.isEmpty
                ? 0
                : double.tryParse(
                    invoiceTaxInPurchases.text.trim().replaceAll(',', '')),
            invoiceIsrInPurchases: invoiceIsrInPurchases.text.isEmpty
                ? 0
                : double.tryParse(
                    invoiceIsrInPurchases.text.trim().replaceAll(',', '')),
            invoiceSelectiveConsumptionTax:
                invoiceSelectiveConsumptionTax.text.isEmpty
                    ? 0
                    : double.tryParse(invoiceSelectiveConsumptionTax.text
                        .trim()
                        .replaceAll(',', '')),
            invoiceOthersTaxes: invoiceOthersTaxes.text.isEmpty
                ? 0
                : double.tryParse(
                    invoiceOthersTaxes.text.trim().replaceAll(',', '')),
            invoiceLegalTipAmount: invoiceLegalTipAmount.text.isEmpty
                ? 0
                : double.tryParse(
                    invoiceLegalTipAmount.text.trim().replaceAll(',', '')),
            invoiceTax: tax.text.isEmpty ? 0 : double.tryParse(tax.text.trim().replaceAll(',', ''))! * (factor),
            invoiceTaxCon: taxCon.text.isEmpty ? 0 : double.tryParse(taxCon.text.trim().replaceAll(',', ''))! * (factor),
            invoiceTotal: double.tryParse(total.text.trim().replaceAll(',', ''))! * (factor),
            amountPaid: amountPaid.text.isEmpty ? double.tryParse(total.text.trim().replaceAll(',', '')) : double.tryParse(amountPaid.text.trim().replaceAll(',', '')),
            checkId: currentCheckId,
            invoicePayDate: retentionDate,
            invoiceRetentionId: currentRetention,
            invoiceTaxRetentionId: currentRetentionTaxId);

      

        var start = startDate.startOfMonth();

        var end = startDate.endOfMonth();

        if (retentionDate != null) {
          if (!DateTime.parse(retentionDate.toString())
              .isAtSameMonthAs(startDate)) {
            start = DateTime.parse(retentionDate.toString()).startOfMonth();
            end = DateTime.parse(retentionDate.toString()).endOfMonth();
          }
        }

        if (widget.purchase?.invoiceNcf != purchase.invoiceNcf ||
            widget.purchase?.invoiceRnc != purchase.invoiceRnc) {

          await purchase.checkIfExists(
              id: widget.widget.company.id!,
              purchaseId: widget.purchase?.id ?? '',
              startDate: start.format(payload: 'YYYY-MM-DD'),
              endDate: end.format(payload: 'YYYY-MM-DD'));
        }
        

        if (!widget.isEditing) {
          await purchase.create();
        } else {
          await purchase.update();
        }

        var controller = Get.find<PurchasesController>();

        widget.widget.startDate = start;
        widget.widget.endDate = end;

        widget.widget.date.value = TextEditingValue(
            text:
                '${widget.widget.startDateNormalAsString} - ${widget.widget.endDateNormalAsString}');

        await storage.write(
            key: "STARTDATE_${widget.widget.company.id}",
            value: widget.widget.startDateLargeAsString);

        await storage.write(
            key: "ENDDATE_${widget.widget.company.id}",
            value: widget.widget.endDateLargeAsString);

        controller.purchases.value = await Purchase.get(
            companyId: widget.widget.company.id!,
            startDate: widget.widget.startDate,
            endDate: widget.widget.endDate);

        if (!widget.isEditing) {
          Get.back(result: 'INSERT');
        } else {
          Get.back(result: 'UPDATE');
        }

        setState(() {
          loading = false;
        });
      } catch (e) {
        setState(() {
          loading = false;
        });
        showAlert(context, message: e.toString());
      }
    }
  }

  onSelectedNcfDate() async {
    var date = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(3000));
    if (date != null) {
      startDate = date;
      endDate = date.endOfMonth();
      startDateLargeAsString = startDate.format(payload: 'YYYY-MM-DD');
      endDateLargeAsString = endDate!.format(payload: 'YYYY-MM-DD');
      ncfDate.add(date.format(payload: 'DD/MM/YYYY'));
      setState(() {});
    }
  }

  Widget get contentView {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                  child: ListView(
                shrinkWrap: true,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RncQueryWidget(
                          rnc: rnc,
                          company: company,
                          onSelectedCorrectRnc: (val) {
                            try {
                              isCorrectRnc = val;
                              setState(() {});
                            } catch (_) {}
                          }),
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
                        hintText: 'NCF',
                        onChanged: (type) {
                          currentNcfType = type;
                          currentNcfTypeId = type?.id;
                        },
                        ncfs: ncfs,
                        validator: (val) =>
                            val == null ? 'CAMPO REQUERIDO' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int?>(
                        value: currentType,
                        validator: (val) =>
                            val == null ? "CAMPO REQUERIDO" : null,
                        decoration: InputDecoration(
                          labelText: 'TIPO DE FACTURA',
                          hintStyle: TextStyle(fontSize: kFontSize),
                          enabledBorder: const OutlineInputBorder(
                            //<-- SEE HERE
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            //<-- SEE HERE
                            borderSide:
                                BorderSide(color: Colors.blue, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                        hint: const Text('TIPO DE FACTURA'),
                        dropdownColor: Colors.white,
                        enableFeedback: false,
                        isExpanded: true,
                        focusColor: Colors.white,
                        onChanged: (id) {
                          currentType = id;
                        },
                        items: invoiceTypes.map((invoiceType) {
                          return DropdownMenuItem(
                            value: invoiceType.id,
                            child: Text(invoiceType.fullName),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int?>(
                        value: currentPaymentMethod,
                        validator: (val) =>
                            val == null ? 'CAMPO REQUERIDO' : null,
                        decoration: InputDecoration(
                          labelText: 'METODO DE PAGO',
                          hintStyle: TextStyle(fontSize: kFontSize),
                          enabledBorder: const OutlineInputBorder(
                            //<-- SEE HERE
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            //<-- SEE HERE
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                        hint: const Text('METODO DE PAGO'),
                        dropdownColor: Colors.white,
                        enableFeedback: false,
                        isExpanded: true,
                        focusColor: Colors.white,
                        onChanged: (val) {
                          currentPaymentMethod = val;
                        },
                        items: paymentMethods.map((item) {
                          return DropdownMenuItem(
                            value: item.id,
                            child: Text(item.fullName),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: total,
                        inputFormatters: [myformatter],
                        validator: _validateTotal,
                        decoration: const InputDecoration(
                            hintText: 'TOTAL FACTURADO',
                            labelText: 'TOTAL FACTURADO',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: tax,
                        validator: _validateTax,
                        inputFormatters: [myformatter],
                        decoration: const InputDecoration(
                            hintText: 'ITBIS FACTURADO',
                            labelText: 'ITBIS FACTURADO',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                           TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: invoiceOthersTaxes,
                        inputFormatters: [myformatter],
                        decoration: const InputDecoration(
                            hintText: 'OTROS IMPUESTOS O TASAS',
                            labelText: 'OTROS IMPUESTOS O TASAS',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                            TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: invoiceSelectiveConsumptionTax,
                        inputFormatters: [myformatter],
                        decoration: const InputDecoration(
                            hintText: 'IMPUESTO SELECTIVO AL CONSUMO',
                            labelText: 'IMPUESTO SELECTIVO AL CONSUMO',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                                        TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: invoiceLegalTipAmount,
                        inputFormatters: [myformatter],
                        decoration: const InputDecoration(
                            hintText: 'MONTO PROPINA LEGAL',
                            labelText: 'MONTO PROPINA LEGAL',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: netTotal,
                        inputFormatters: [myformatter],
                        readOnly: true,
                        decoration: const InputDecoration(
                            hintText: 'TOTAL NETO',
                            labelText: 'TOTAL NETO',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: totalEx,
                        inputFormatters: [myformatter],
                        decoration: const InputDecoration(
                            hintText: 'TOTAL FACTURADO EN MONEDA EXTRANJERA',
                            labelText: 'TOTAL FACTURADO EN MONEDA EXTRANJERA',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
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
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: amountPaid,
                        inputFormatters: [myformatter],
                        validator: validateAmountPaid,
                        decoration: const InputDecoration(
                            hintText: 'MONTO PAGADO',
                            labelText: 'MONTO PAGADO',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: debt,
                        inputFormatters: [myformatter],
                        readOnly: true,
                        decoration: const InputDecoration(
                            hintText: 'DEUDA',
                            labelText: 'DEUDA',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      NcfEditorWidget(
                        currentNcfTypeId: currentNcfModifedTypeId,
                        isNcfModifed: true,
                        controller: ncfModifed,
                        hintText: 'NCF MODIFICADO',
                        onChanged: (type) {
                          currentNcfModifedType = type;
                          currentNcfModifedTypeId = type?.id;
                        },
                        ncfs: ncfs,
                        validator: (val) =>
                            val == null ? 'CAMPO REQUERIDO' : null,
                      ),
                      const SizedBox(height: 10),
                      DateSelectorWidget(
                          onSelected: (date) {
                            ncfPayDate = date;
                            retentionDate = date;
                          },
                          stream: ncfPaymentDate,
                          isPayNcf: true,
                          hintText: 'FECHA DE RETENCION DE NCF',
                          labelText: 'FECHA DE RETENCION DE NCF',
                          startDate: startDate,
                          date: ncfPayDate),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int?>(
                        value: currentRetentionTaxId,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            //<-- SEE HERE
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            //<-- SEE HERE
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                        hint: const Text('RETENCION DE ITBIS'),
                        dropdownColor: Colors.white,
                        enableFeedback: false,
                        isExpanded: true,
                        focusColor: Colors.white,
                        onChanged: (val) {
                          currentRetentionTaxId = val;
                        },
                        items: retentionTaxes.map((retention) {
                          return DropdownMenuItem(
                            value: retention.id,
                            child: Text(retention.name!),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int?>(
                        value: currentRetention,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            //<-- SEE HERE
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            //<-- SEE HERE
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.error)),
                        ),
                        hint: const Text('RETENCION ISR'),
                        dropdownColor: Colors.white,
                        enableFeedback: false,
                        isExpanded: true,
                        focusColor: Colors.white,
                        onChanged: (val) {
                          currentRetention = val;
                        },
                        items: retentions.map((retention) {
                          return DropdownMenuItem(
                            value: retention.id,
                            child: Text(retention.name!),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: taxCon,
                        inputFormatters: [myformatter],
                        decoration: const InputDecoration(
                            hintText: 'ITBIS LLEVADO AL COSTO',
                            labelText: 'ITBIS LLEVADO AL COSTO',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: invoiceTaxInPurchases,
                        inputFormatters: [myformatter],
                        decoration: const InputDecoration(
                            hintText: 'ITBIS EN COMPRAS',
                            labelText: 'ITBIS EN COMPRAS',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: const TextStyle(fontSize: 18),
                        controller: invoiceIsrInPurchases,
                        inputFormatters: [myformatter],
                        decoration: const InputDecoration(
                            hintText: 'ISR EN COMPRAS',
                            labelText: 'ISR EN COMPRAS',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                
                 
    
                      Row(
                        children: [
                          Text('NCF AUTORIZADO',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor)),
                          const SizedBox(height: 10),
                          Switch(
                              value: isAuthorized,
                              onChanged: (val) async {
                                setState(() {
                                  isAuthorized = val;
                                });
                              }),
                        ],
                      ),
                      widget.isEditing
                          ? Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: 'EDITADO POR ULTIMA VEZ POR ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).primaryColor)),
                              TextSpan(text: widget.purchase?.author)
                            ]))
                          : Container(),
                      widget.purchase?.createdAt != null
                          ? Column(
                              children: [
                                const SizedBox(height: 10),
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: 'EDITADO EL ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  TextSpan(
                                      text: widget.purchase!.createdAt!.format(
                                          payload: 'DD/MM/YYYY HH:mm:ss'))
                                ])),
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              )),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    style: ButtonStyle(
                      padding:
                          WidgetStateProperty.all(const EdgeInsets.all(18)),
                    ),
                    onPressed: isCorrectRnc ? _onSubmit : null,
                    child: loading
                        ? const Center(
                            child: SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          ))
                        : Text(_titleBtn, style: const TextStyle(fontSize: 19)),
                  )),
                ],
              )
            ],
          )),
    );
  }

  Widget get loadingView {
    return const Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [CircularProgressIndicator()],
    ),
    );
  }

  Widget get errorView {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Padding(
      padding: EdgeInsets.all(kDefaultPadding / 2),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
       crossAxisAlignment: CrossAxisAlignment.center,
       children: [
      Icon(Icons.warning,
      size: 120, color: Theme.of(context).colorScheme.error),
      SizedBox(height: kDefaultPadding),
      Text(messageError, textAlign: TextAlign.center)
       ],
    ))
      ],
    ),
    );
  }

  Widget get content {
    return contentView;
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      width: 1,
      color: kWindowBorderColor,
      child:LayoutWithBar(child: AlertDialog(
         contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
         content: SizedBox(width: modalPurchasesWidth, child:Column(
          children: [
            Row(
                children: [
                  Text(_title,
                      style: TextStyle(
                          fontSize: 22, color: Theme.of(context).primaryColor)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 20),

              Expanded(child:  content)
          ],
         )),
        ))
    );
  }
}
