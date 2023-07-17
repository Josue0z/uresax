// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:simple_moment/simple_moment.dart' as sm;
import 'package:uresaxapp/controllers/add.purchase.controller.dart';
import 'package:uresaxapp/controllers/periods.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/modals/add-provider-modal.dart';
import 'package:uresaxapp/models/banking.dart';
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
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/date.selector.widget.dart';
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

  AddPurchaseModal(
      {super.key,
      this.purchase,
      this.isEditing = false,
      required this.startDateLargeAsString,
      required this.widget,
      required this.startDate});

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
  bool show = false;
  bool isAuthorized = true;
  bool isLoading = false;
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

  TextEditingController ncfDate = TextEditingController();

  TextEditingController ncfPayDateValue = TextEditingController();

  TextEditingController ckBeneficiary = TextEditingController();

  TextEditingController rnc = TextEditingController();

  TextEditingController company = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final GlobalKey dropdownKey = GlobalKey();

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


  Future<List<Purchase>> get getPurchases async {
    return await Purchase.getPurchases(
        id: widget.widget.company.id!,
        startDate: widget.widget.startDate,
        endDate: widget.widget.endDate);
  }

  Future<void> preloadDialogMetaData() async {
    concepts = [Concept(name: 'CONCEPTO'), ...(await Concept.getConcepts())]
        .cast<Concept>();

    bankings = [Banking(name: 'BANCO'), ...(await Banking.getBankings())]
        .cast<Banking>();

    invoiceTypes = [
      InvoiceType(name: 'TIPO DE FACTURA'),
      ...(await InvoiceType.getInvoiceTypes())
    ].cast<InvoiceType>();

    paymentMethods = [
      PaymentMethod(name: 'METODO DE PAGO'),
      ...(await PaymentMethod.getPaymentMethods())
    ].cast<PaymentMethod>();

    retentions = [Retention(name: 'RETENCION ISR'), ...(await Retention.all())]
        .cast<Retention>();

    ncfs = [NcfType(name: 'TIPO DE COMPROBANTE'), ...(await NcfType.getNcfs())]
        .cast<NcfType>();

    retentionTaxes = [
      RetentionTax(name: 'RETENCION DE ITBIS'),
      ...(await RetentionTax.all())
    ].cast<RetentionTax>();
  }

  @override
  void initState() {
    initElements();
    super.initState();
  }

  initElements() async {
    isLoading = true;
    await preloadDialogMetaData();
    try {
      startDate = widget.startDate;
      startDateLargeAsString = widget.startDateLargeAsString;
      if (widget.purchase != null) {
        isAuthorized = widget.purchase!.authorized;
        rnc.value = TextEditingValue(text: widget.purchase!.invoiceRnc!);
        ckBeneficiary.value =
            TextEditingValue(text: widget.purchase?.ckBeneficiary ?? '');
        currentConcept = widget.purchase?.invoiceConceptId;
        currentNcfTypeId = widget.purchase?.invoiceNcfTypeId;
        ncf.value = TextEditingValue(
            text: widget.purchase?.invoiceNcf?.substring(3) ?? '');

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
        currentNcfType =
            ncfs.where((element) => element.id == currentNcfTypeId).first;
        currentNcfModifedType = ncfs
            .where((element) => element.id == currentNcfModifedTypeId)
            .first;
        startDate = widget.purchase!.invoiceIssueDate!;
        if (widget.purchase?.invoicePayDate != null) {
          ncfPayDate = widget.purchase!.invoicePayDate;
          retentionDate = ncfPayDate;
          ncfPayDateValue.value = TextEditingValue(
              text: sm.Moment.fromDate(ncfPayDate!).format('dd/MM/yyyy'));
        }
      }
      endDate = startDate.endOfMonth();
      startDateLargeAsString = startDate.format(payload: 'YYYY-MM-DD');
      endDateLargeAsString = sm.Moment.fromDate(endDate!).format('yyyy-MM-dd');
      ncfDate.value =
          TextEditingValue(text: startDate.format(payload: 'DD/MM/YYYY'));
      isLoading = false;
    } catch (e) {
      print(e.toString());
    }
    setState(() {});
  }

  String? _validateTax(val) {
    if (val != null && val.isNotEmpty) {
      var n1 = double.tryParse(total.text.replaceAll(',', '')) ?? 0;
      var n2 = double.parse(val.replaceAll(',', ''));
      var n3 = n1 - n2;
      var t = double.parse(((n3 * 0.18)).toStringAsFixed(2));
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

  Future<void> _onSubmit() async {
    try {
      var factor = currentNcfTypeId == 4 || currentNcfTypeId == 34 ? -1 : 1;

      if (isAllCorrect) {
        var purchase = Purchase(
            id: widget.purchase?.id,
            authorized: isAuthorized,
            invoiceRnc: rnc.text,
            invoiceConceptId: currentConcept,
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
            invoicePayDate: retentionDate,
            invoiceCk: int.tryParse(ck.text.trim()),
            invoiceRetentionId: currentRetention,
            invoiceTaxRetentionId: currentRetentionTaxId,
            invoiceTaxInPurchases: invoiceTaxInPurchases.text.isEmpty
                ? 0
                : double.tryParse(
                    invoiceTaxInPurchases.text.replaceAll(',', '')),
            invoiceIsrInPurchases: invoiceIsrInPurchases.text.isEmpty
                ? 0
                : double.tryParse(
                    invoiceIsrInPurchases.text.replaceAll(',', '')),
            invoiceSelectiveConsumptionTax: invoiceSelectiveConsumptionTax
                    .text.isEmpty
                ? 0
                : double.tryParse(
                    invoiceSelectiveConsumptionTax.text.replaceAll(',', '')),
            invoiceOthersTaxes: invoiceOthersTaxes.text.isEmpty
                ? 0
                : double.tryParse(invoiceOthersTaxes.text),
            invoiceLegalTipAmount: invoiceLegalTipAmount.text.isEmpty
                ? 0
                : double.tryParse(
                    invoiceLegalTipAmount.text.replaceAll(',', '')),
            invoiceTax: tax.text.isEmpty
                ? 0
                : double.tryParse(tax.text.trim().replaceAll(',', ''))! *
                    factor,
            invoiceTaxCon: taxCon.text.isEmpty
                ? 0
                : double.tryParse(taxCon.text.trim().replaceAll(',', ''))! *
                    factor,
            invoiceTotal:
                double.tryParse(total.text.trim().replaceAll(',', ''))! * factor);

        if(currentConcept == null){
           throw 'SELECCIONA UN CONCEPTO';
        }

        if (purchase.invoiceNcfModifed == null && currentNcfTypeId == 4 ||
            currentNcfTypeId == 34) {
          throw 'NO PUEDE ESTAR VACIO EL NCF MODIFICADO CON UNA NOTA DE CREDITO';
        }

        if (currentNcfTypeId == null) {
          throw 'NCF ESTA VACIO';
        }


        var start = startDate.startOfMonth();

        var end = startDate.endOfMonth();

        await purchase.checkIfExists(
            id: widget.widget.company.id!,
            purchaseId: widget.purchase?.id ?? '',
            editing: widget.purchase != null,
            startDate: start.format(payload: 'YYYY-MM-DD'),
            endDate: end.format(payload: 'YYYY-MM-DD'));

        if (!widget.isEditing) {
          await purchase.create();
          Get.back(result: 'INSERT');
        } else {
          await purchase.update();
          Get.back(result: 'UPDATE');
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

        controller.purchases.value =  await Purchase.getPurchases(
        id: widget.widget.company.id!,
        startDate: widget.widget.startDate,
        endDate: widget.widget.endDate);
    
      }
    } catch (e) {
      showAlert(context, title: '!ATENCION!', message: e.toString());
    }
  }

  Future<void> _deletePurchase() async {
    try {
      var controller = Get.find<PurchasesController>();
      await widget.purchase?.delete();
      controller.purchases.value = await getPurchases;
      Get.back(result: 'DELETE');
    } catch (e) {
      showAlert(context, message: e.toString());
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
      ncfDate.value =
          TextEditingValue(text: date.format(payload: 'DD/MM/YYYY'));
    }
  }


  Widget get contentDialog {
    return Padding(
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
                          fontSize: 22, color: Theme.of(context).primaryColor)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 20),
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
                            isCorrectRnc = val;
                            setState(() {});
                          }),
                      const SizedBox(height: 10),
                     DateSelectorWidget(
                      onSelected:(date){
                        startDate = date!;
                        ncfPayDate = date;
                        setState(() {
                        });
                      }, 
                      controller:ncfDate, 
                      labelText: "FECHA DE EMISION DE NCF",
                      hintText: "FECHA DE EMISION DE NCF",
                      startDate: startDate,
                      date: startDate),
                     const SizedBox(height: 10),
                    SelectorConceptWidget(
                     value: currentConcept,
                     concepts: concepts, 
                     onSelected: (current,index){
                      currentConcept = current?.id;
                    }),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          controller: ck,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(fontSize: 18),
                          decoration: const InputDecoration(
                              hintText: 'NUMERO DE CHEQUE',
                              labelText: 'NUMERO DE CHEQUE',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: DropdownButtonFormField<int?>(
                            value: currentBanking,
                            decoration: InputDecoration(
                              labelText: 'BANCO',
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                            ),
                            hint: const Text('BANCO'),
                            dropdownColor: Colors.white,
                            enableFeedback: false,
                            isExpanded: true,
                            focusColor: Colors.white,
                            onChanged: (id) {
                              currentBanking = id;
                            },
                            items: bankings.map((banking) {
                              return DropdownMenuItem(
                                value: banking.id,
                                child: Text(banking.name),
                              );
                            }).toList(),
                          )),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: ckBeneficiary,
                          style: const TextStyle(fontSize: 18),
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'BENEFICIARIO',
                              labelText: 'BENEFICIARIO')),
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
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: DropdownButtonFormField<int?>(
                            value: currentType,
                            validator: (val) =>
                                val == null ? "CAMPO REQUERIDO" : null,
                            decoration: InputDecoration(
                              labelText: 'TIPO DE FACTURA',
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
                                      color:
                                          Theme.of(context).colorScheme.error)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error)),
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
                          )),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: DropdownButtonFormField<int?>(
                            value: currentPaymentMethod,
                            validator: (val) =>
                                val == null ? 'CAMPO REQUERIDO' : null,
                            decoration: InputDecoration(
                              labelText: 'METODO DE PAGO',
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
                                      color:
                                          Theme.of(context).colorScheme.error)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error)),
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
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          controller: total,
                          inputFormatters: [myformatter],
                          validator: _validateTotal,
                          decoration: const InputDecoration(
                              hintText: 'TOTAL FACTURADO',
                              labelText: 'TOTAL FACTURADO',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          controller: tax,
                          validator: _validateTax,
                          inputFormatters: [myformatter],
                          decoration: const InputDecoration(
                              hintText: 'ITBIS FACTURADO',
                              labelText: 'ITBIS FACTURADO',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          controller: taxCon,
                          inputFormatters: [myformatter],
                          decoration: const InputDecoration(
                              hintText: 'ITBIS LLEVADO AL COSTO',
                              labelText: 'ITBIS LLEVADO AL COSTO',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          controller: invoiceTaxInPurchases,
                          inputFormatters: [myformatter],
                          decoration: const InputDecoration(
                              hintText: 'ITBIS EN COMPRAS',
                              labelText: 'ITBIS EN COMPRAS',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          controller: invoiceIsrInPurchases,
                          inputFormatters: [myformatter],
                          decoration: const InputDecoration(
                              hintText: 'ISR EN COMPRAS',
                              labelText: 'ISR EN COMPRAS',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          controller: invoiceSelectiveConsumptionTax,
                          inputFormatters: [myformatter],
                          decoration: const InputDecoration(
                              hintText: 'IMPUESTO SELECTIVO AL CONSUMO',
                              labelText: 'IMPUESTO SELECTIVO AL CONSUMO',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          controller: invoiceOthersTaxes,
                          inputFormatters: [myformatter],
                          decoration: const InputDecoration(
                              hintText: 'OTROS IMPUESTOS O TASAS',
                              labelText: 'OTROS IMPUESTOS O TASAS',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: const TextStyle(fontSize: 18),
                          controller: invoiceLegalTipAmount,
                          inputFormatters: [myformatter],
                          decoration: const InputDecoration(
                              hintText: 'MONTO PROPINA LEGAL',
                              labelText: 'MONTO PROPINA LEGAL',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: DropdownButtonFormField<int?>(
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
                                      color:
                                          Theme.of(context).colorScheme.error)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error)),
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
                          )),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: DropdownButtonFormField<int?>(
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
                                      color:
                                          Theme.of(context).colorScheme.error)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error)),
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
                          )),
                      const SizedBox(height: 10),
                      DateSelectorWidget(
                      onSelected:(date){
                          ncfPayDate = date;
                          retentionDate = date;
                      },  
                      controller: ncfPayDateValue, 
                      isPayNcf:true,
                      hintText:'FECHA DE PAGO DE NCF', 
                      labelText: 'FECHA DE PAGO DE NCF', 
                      startDate: startDate,
                      date: ncfPayDate),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  widget.isEditing
                      ? Expanded(
                          child: ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(18)),
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.error)),
                          onPressed: _deletePurchase,
                          child: const Text('ELIMINAR FACTURA',
                              style: TextStyle(fontSize: 19)),
                        ))
                      : Container(),
                  SizedBox(width: widget.isEditing ? 20 : 0),
                  Expanded(
                      child: ElevatedButton(
                    style: ButtonStyle(
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(18)),
                    ),
                    onPressed: isCorrectRnc ? _onSubmit : null,
                    child:
                        Text(_titleBtn, style: const TextStyle(fontSize: 19)),
                  )),
                ],
              )
            ],
          )),
    );
  }

  Widget get loadingWidget {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [CircularProgressIndicator()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      content: SizedBox(
          width: modalPurchasesWidth, child: isLoading ? loadingWidget : contentDialog),
    );
  }
}
