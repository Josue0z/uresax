// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uresaxapp/models/banking.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/invoicetype.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:uresaxapp/models/payment-method.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/retention.dart';
import 'package:uresaxapp/models/retention.tax.dart';
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/models/tax.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/ncf-editor-widget.dart';
import 'package:simple_moment/simple_moment.dart';
import '../utils/extra.dart';

class AddPurchaseModal extends StatefulWidget {
  final Purchase? purchase;
  final Book book;
  final Sheet sheet;
  bool isEditing;
  List<Concept> concepts = [];
  List<Banking> bankings = [];
  List<InvoiceType> invoiceTypes = [];
  List<PaymentMethod> paymentMethods = [];
  List<Retention> retentions = [];
  List<NcfType> ncfs = [];
  List<RetentionTax> retentionTaxes = [];
  List<Tax> taxes = [];

  AddPurchaseModal({
    super.key,
    this.purchase,
    this.isEditing = false,
    required this.concepts,
    required this.bankings,
    required this.invoiceTypes,
    required this.paymentMethods,
    required this.retentions,
    required this.retentionTaxes,
    required this.ncfs,
    required this.taxes,
    required this.book,
    required this.sheet,
  });

  @override
  State<AddPurchaseModal> createState() => _AddPurchaseModalState();
}

class _AddPurchaseModalState extends State<AddPurchaseModal> {
  int? currentConcept;
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

  TextEditingController rnc = TextEditingController();
  TextEditingController ck = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController day = TextEditingController();
  TextEditingController total = TextEditingController();
  TextEditingController tax = TextEditingController();
  TextEditingController company = TextEditingController();
  TextEditingController ncf = TextEditingController();
  TextEditingController ncfModifed = TextEditingController();
  TextEditingController invoicePayYear = TextEditingController();
  TextEditingController invoicePayMonth = TextEditingController();
  TextEditingController invoicePayDay = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool get isAllCorrect {
    return _formKey.currentState!.validate();
  }

  String get _title {
    return widget.isEditing ? 'COMPRA SELECCIONADA...' : 'AÑANIENDO COMPRA...';
  }

  String get _titleBtn {
    return widget.isEditing ? 'EDITAR COMPRA' : 'AÑADIR COMPRA';
  }

  bool get isGoodCode =>
      currentType == 8 || currentType == 9 || currentType == 10;

  @override
  void initState() {
    rnc.addListener(_verifyTaxPayer);
    _initElements();
    super.initState();
  }

  Future<void> _initElements() async {
    try {
      if (widget.purchase != null) {
        rnc.value = TextEditingValue(text: widget.purchase!.invoiceRnc!);
        currentConcept = widget.purchase?.invoiceConceptId;
        currentNcfTypeId = widget.purchase?.invoiceNcfTypeId;
        ncf.value = TextEditingValue(text: widget.purchase!.invoiceNcf!);
        currentNcfModifedTypeId = widget.purchase?.invoiceNcfModifedTypeId;
        ncfModifed.value =
            TextEditingValue(text: widget.purchase?.invoiceNcfModifed ?? '');
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
        total.value = myformatter.formatEditUpdate(TextEditingValue.empty,
            TextEditingValue(text: widget.purchase!.invoiceTotal.toString()));
        tax.value = myformatter.formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(
                text: widget.purchase!.invoiceTax == 0
                    ? ''
                    : widget.purchase!.invoiceTax.toString()));
        invoicePayYear.value = TextEditingValue(
            text: widget.purchase?.invoicePayYear?.toString() ?? '');
        invoicePayMonth.value = TextEditingValue(
            text: widget.purchase?.invoicePayMonth?.toString() ?? '');
        invoicePayDay.value = TextEditingValue(
            text: widget.purchase?.invoicePayDay?.toString() ?? '');
        currentNcfType = widget.ncfs
            .where((element) => element.id == currentNcfTypeId)
            .first;
        currentNcfModifedType = widget.ncfs
            .where((element) => element.id == currentNcfModifedTypeId)
            .first;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  _verifyTaxPayer() async {
    try {
      var data = await verifyTaxPayer(rnc.value.text);
      company.value = TextEditingValue(text: data['tax_payer_company_name']);
      isCorrectRnc = true;
      return;
    } catch (e) {
      if (rnc.value.text.characters.length == 11) {
        company.value = const TextEditingValue(text: 'PERSONAL');
      } else {
        company.value = const TextEditingValue(text: '');
      }
      isCorrectRnc = false;
      return;
    }
  }

  String? _validateTax(val) {
    if (val != null && val.isNotEmpty) {
      var n1 = double.parse(val.replaceAll(',', ''));

      var n2 = double.tryParse(total.text.replaceAll(',', '')) ?? 0;

      var rates = widget.taxes.map((e) => (e.rate / 100) * n2).toList();

      var sumRates = rates.reduce((value, element) => value + element);

      if (n1 > sumRates) {
        return 'EL ITBIS ES MAYOR QUE LA TASA APLICADA POR LEY';
      }
    }

    return null;
  }

  Future<void> _onSubmit() async {
    try {
      var factor = currentNcfTypeId == 4 || currentNcfTypeId == 34 ? -1 : 1;

      if (isAllCorrect) {
        var purchase = Purchase(
          id: widget.purchase?.id,
          invoiceRnc: rnc.text,
          invoiceConceptId: currentConcept,
          invoiceTypeId: currentType,
          invoicePaymentMethodId: currentPaymentMethod,
          invoiceNcf: '${currentNcfType?.ncfTag}${ncf.text}',
          invoiceNcfTypeId: currentNcfType?.id,
          invoiceNcfModifed: currentNcfModifedTypeId == null
              ? ''
              : '${currentNcfModifedType?.ncfTag}${ncfModifed.text}',
          invoiceNcfModifedTypeId: currentNcfModifedType?.id,
          invoiceYear: widget.book.year,
          invoiceMonth: widget.sheet.sheetMonth,
          invoiceNcfDay: day.text,
          invoiceSheetId: widget.sheet.id,
          invoiceBookId: widget.book.id,
          invoiceCompanyId: widget.book.companyId,
          invoiceBankingId: currentBanking,
          invoicePayYear: int.tryParse(invoicePayYear.text),
          invoicePayMonth: int.tryParse(invoicePayMonth.text),
          invoicePayDay: int.tryParse(invoicePayDay.text),
          invoiceCk: int.tryParse(ck.text.trim()),
          invoiceRetentionId: currentRetention,
          invoiceTaxRetentionId: currentRetentionTaxId,
          invoiceTax: tax.text.isEmpty
              ? 0
              : double.tryParse(tax.text.trim().replaceAll(',', ''))! * factor,
          invoiceTotalAsService: total.text.isEmpty
              ? 0
              : !isGoodCode
                  ? double.tryParse(total.text.trim().replaceAll(',', ''))! *
                      factor
                  : 0,
          invoiceTotalAsGood: total.text.isEmpty
              ? 0
              : isGoodCode
                  ? double.tryParse(total.text.trim().replaceAll(',', ''))! *
                      factor
                  : 0,
        );

        if (!widget.isEditing) {
          await purchase.checkIfExistsPurchase();
          var newPurchase = await purchase.create();
          Navigator.pop(context, {'method': 'INSERT', 'data': newPurchase});
        } else {
          var purchaseUpdated = await purchase.update();

          Navigator.pop(context, {'method': 'UPDATE', 'data': purchaseUpdated});
        }
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  Future<void> _deletePurchase() async {
    try {
      await widget.purchase?.delete();
      Navigator.pop(context, {'method': 'DELETE', 'data': widget.purchase});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        content: SizedBox(
            width: 550,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(_title,
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Theme.of(context).primaryColor)),
                          const Spacer(),
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close))
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                          child: ListView(
                        shrinkWrap: true,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                style: const TextStyle(fontSize: 18),
                                controller: company,
                                enabled: false,
                                decoration: const InputDecoration(
                                    hintText: 'EMPRESA',
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  controller: rnc,
                                  maxLength: 11,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 18),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (val) => val == null
                                      ? 'CAMPO REQUERIDO'
                                      : val.length != 9 && val.length != 11
                                          ? 'LA CANTIDA DE CARACTERES NO ES VALIDA'
                                          : null,
                                  decoration: const InputDecoration(
                                      hintText: 'RNC',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: DropdownButtonFormField<int?>(
                                    value: currentConcept,
                                    validator: (val) =>
                                        val == null ? 'CAMPO REQUERIDO' : null,
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                    ),
                                    hint: const Text('CONCEPTO'),
                                    dropdownColor: Colors.white,
                                    enableFeedback: false,
                                    isExpanded: true,
                                    focusColor: Colors.white,
                                    onChanged: (val) {
                                      currentConcept = val;
                                    },
                                    items: widget.concepts.map((concept) {
                                      return DropdownMenuItem(
                                        value: concept.id,
                                        child: Text(concept.name!),
                                      );
                                    }).toList(),
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: ck,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: const TextStyle(fontSize: 18),
                                  decoration: const InputDecoration(
                                      hintText: 'NUMERO DE CHEQUE',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: DropdownButtonFormField<int?>(
                                    value: currentBanking,
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                    ),
                                    hint: const Text('BANCO'),
                                    dropdownColor: Colors.white,
                                    enableFeedback: false,
                                    isExpanded: true,
                                    focusColor: Colors.white,
                                    onChanged: (val) {
                                      currentBanking = val;
                                    },
                                    items: widget.bankings.map((banking) {
                                      return DropdownMenuItem(
                                        value: banking.id,
                                        child: Text(banking.name),
                                      );
                                    }).toList(),
                                  )),
                              NcfEditorWidget(
                                currentNcfTypeId: currentNcfTypeId,
                                controller: ncf,
                                hintText: 'NCF',
                                onChanged: (type) {
                                  currentNcfType = type;
                                  currentNcfTypeId = type?.id;
                                },
                                ncfs: widget.ncfs,
                                validator: (val) =>
                                    val == null ? 'CAMPO REQUERIDO' : null,
                              ),
                              NcfEditorWidget(
                                currentNcfTypeId: currentNcfModifedTypeId,
                                isNcfModifed: true,
                                controller: ncfModifed,
                                hintText: 'NCF MODIFICADO',
                                onChanged: (type) {
                                  currentNcfModifedType = type;
                                  currentNcfModifedTypeId = type?.id;
                                },
                                ncfs: widget.ncfs,
                                validator: (val) =>
                                    val == null ? 'CAMPO REQUERIDO' : null,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                child: TextFormField(
                                  controller: day,
                                  keyboardType: TextInputType.number,
                                  maxLength: 2,
                                  validator: (val) => val!.isEmpty
                                      ? 'CAMPO REQUERIDO'
                                      : !(int.parse(val) >= 1 &&
                                              int.parse(val) <= 31)
                                          ? 'EL RANGO DEBE SER ENTRE 1 Y 31'
                                          : null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'^[0]'))
                                  ],
                                  style: const TextStyle(fontSize: 18),
                                  decoration: const InputDecoration(
                                      hintText: 'DIA DE COMPROBANTE',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: DropdownButtonFormField<int?>(
                                    value: currentType,
                                    validator: (val) =>
                                        val == null ? "CAMPO REQUERIDO" : null,
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                    ),
                                    hint: const Text('TIPO DE FACTURA'),
                                    dropdownColor: Colors.white,
                                    enableFeedback: false,
                                    isExpanded: true,
                                    focusColor: Colors.white,
                                    onChanged: (id) {
                                      currentType = id;
                                    },
                                    items:
                                        widget.invoiceTypes.map((invoiceType) {
                                      return DropdownMenuItem(
                                        value: invoiceType.id,
                                        child: Text(invoiceType.name),
                                      );
                                    }).toList(),
                                  )),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: DropdownButtonFormField<int?>(
                                    value: currentPaymentMethod,
                                    validator: (val) =>
                                        val == null ? 'CAMPO REQUERIDO' : null,
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                    ),
                                    hint: const Text('METODO DE PAGO'),
                                    dropdownColor: Colors.white,
                                    enableFeedback: false,
                                    isExpanded: true,
                                    focusColor: Colors.white,
                                    onChanged: (val) {
                                      currentPaymentMethod = val;
                                    },
                                    items: widget.paymentMethods.map((item) {
                                      return DropdownMenuItem(
                                        value: item.id,
                                        child: Text(item.name),
                                      );
                                    }).toList(),
                                  )),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: DropdownButtonFormField<int?>(
                                    value: currentRetentionTaxId,
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                    ),
                                    hint: const Text('RETENCION DE ITBIS'),
                                    dropdownColor: Colors.white,
                                    enableFeedback: false,
                                    isExpanded: true,
                                    focusColor: Colors.white,
                                    onChanged: (val) {
                                      currentRetentionTaxId = val;
                                    },
                                    items:
                                        widget.retentionTaxes.map((retention) {
                                      return DropdownMenuItem(
                                        value: retention.id,
                                        child: Text(retention.name!),
                                      );
                                    }).toList(),
                                  )),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: DropdownButtonFormField<int?>(
                                    value: currentRetention,
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        //<-- SEE HERE
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                    ),
                                    hint: const Text('RETENCION ISR'),
                                    dropdownColor: Colors.white,
                                    enableFeedback: false,
                                    isExpanded: true,
                                    focusColor: Colors.white,
                                    onChanged: (val) {
                                      currentRetention = val;
                                    },
                                    items: widget.retentions.map((retention) {
                                      return DropdownMenuItem(
                                        value: retention.id,
                                        child: Text(retention.name!),
                                      );
                                    }).toList(),
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: invoicePayYear,
                                  validator: currentRetention != null
                                      ? (val) =>
                                          val == null ? "CAMPO REQUERIDO" : null
                                      : null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: const TextStyle(fontSize: 18),
                                  decoration: const InputDecoration(
                                      hintText: 'AÑO DE PAGO',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: invoicePayMonth,
                                  validator: currentRetention != null
                                      ? (val) =>
                                          val == null ? "CAMPO REQUERIDO" : null
                                      : null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: const TextStyle(fontSize: 18),
                                  decoration: const InputDecoration(
                                      hintText: 'MES DE PAGO',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: invoicePayDay,
                                  validator: currentRetention != null
                                      ? (val) =>
                                          val == null ? "CAMPO REQUERIDO" : null
                                      : null,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: const TextStyle(fontSize: 18),
                                  decoration: const InputDecoration(
                                      hintText: 'DIA DE PAGO',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  style: const TextStyle(fontSize: 18),
                                  controller: total,
                                  inputFormatters: [myformatter],
                                  validator: (val) => val == null || val == ''
                                      ? 'CAMPO REQUERIDO'
                                      : null,
                                  decoration: const InputDecoration(
                                      hintText: 'TOTAL FACTURADO',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: TextFormField(
                                  style: const TextStyle(fontSize: 18),
                                  controller: tax,
                                  validator: _validateTax,
                                  inputFormatters: [myformatter],
                                  decoration: const InputDecoration(
                                      hintText: 'ITBIS FACTURADO',
                                      border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(height: 10),
                              widget.isEditing
                                  ? Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: 'EDITADO POR ULTIMA VEZ POR ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      TextSpan(text: widget.purchase?.author)
                                    ]))
                                  : Container(),
                              widget.purchase?.createdAt != null
                                  ? Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        Text.rich(TextSpan(children: [
                                          TextSpan(
                                              text: 'CREADO EL',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                          TextSpan(
                                              text: Moment.fromDate(widget
                                                      .purchase!.createdAt!)
                                                  .format(
                                                      'dd/MM/yyyy HH:mm:ss'))
                                        ])),
                                      ],
                                    )
                                  : Container(),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ],
                      )),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          widget.isEditing
                              ? Expanded(
                                  child: ElevatedButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(18)),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                  onPressed: _deletePurchase,
                                  child: const Text('ELIMINAR COMPRA',
                                      style: TextStyle(fontSize: 19)),
                                ))
                              : Container(),
                          SizedBox(width: widget.isEditing ? 20 : 0),
                          Expanded(
                              child: ElevatedButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(18)),
                            ),
                            onPressed: _onSubmit,
                            child: Text(_titleBtn,
                                style: const TextStyle(fontSize: 19)),
                          )),
                        ],
                      )
                    ],
                  )),
            )));
  }
}
