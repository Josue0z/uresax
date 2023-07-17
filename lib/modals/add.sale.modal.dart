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
import 'package:uresaxapp/widgets/ncf-editor-widget.dart';
import 'package:uresaxapp/widgets/rnc.query.widget.dart';
import 'package:uresaxapp/widgets/widget.concept.selector.dart';

class AddSaleModal extends StatefulWidget {
  bool isEditing;

  Sale? sale;

  CompanyDetailsPage companyDetailsPage;

  AddSaleModal(
      {super.key,
      this.isEditing = false,
      this.sale,
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

  TextEditingController ncfDate = TextEditingController();

  TextEditingController total = TextEditingController();

  TextEditingController tax = TextEditingController();

  TextEditingController retentionTaxByOthers = TextEditingController();

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

  List<NcfType> ncfs = [];

  List<TypeOfIncome> typeOfIncomes = [];

  List<Concept> concepts = [];

  int? currentConceptId;

  bool isLoading = false;

  TextEditingController ncfPayDateValue = TextEditingController();

  DateTime? ncfPayDate;

  DateTime? ncfRetentionDate;

  late DateTime startDate;

  final formKey = GlobalKey<FormState>();

  String get title {
    return widget.isEditing ? 'EDITANDO VENTA...' : 'AÑADIENDO VENTA...';
  }

  String get btnTitle {
    return widget.isEditing ? 'EDITAR VENTA' : 'AÑADIR VENTA';
  }

  onSubmit() async {
    if (formKey.currentState!.validate()) {
      try {
        var sale = Sale(
          id: widget.sale != null ? widget.sale!.id : '',
          companyId: widget.companyDetailsPage.company.id!,
          authorId: User.current!.id!,
          rncOrId: rnc.text,
          idType: currentIdValue!,
          conceptId: currentConceptId ?? -1,
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

        if (currentConceptId == null) {
          throw 'SELECCIONA UN CONCEPTO';
        }

        var c = Get.find<SalesController>();

        if (!widget.isEditing) {
          await sale.create();
          Get.back(result: 'INSERT');
        } else {
          await sale.update();
          Get.back(result: 'UPDATE');
        }

        var start = sale.invoiceNcfDate.startOfMonth();

        var end = sale.invoiceNcfDate.endOfMonth();

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

  Future<void> preloadDialogMetaData() async {
    isLoading = true;
    ncfs = [NcfType(name: 'TIPO DE COMPROBANTE'), ...(await NcfType.getNcfs())];
    typeOfIncomes = [
      TypeOfIncome(name: 'TIPO DE INGRESO'),
      ...(await TypeOfIncome.get())
    ];
    concepts = [Concept(name: 'CONCEPTO'), ...(await Concept.getConcepts())];
    isLoading = false;
  }

  setupEditContent() {
    if (widget.sale != null) {
      rnc.value = TextEditingValue(text: widget.sale!.rncOrId);
      startDate = widget.sale!.invoiceNcfDate;
      if (widget.sale?.retentionDate != null) {
        ncfPayDate = widget.sale!.retentionDate;
        ncfRetentionDate = ncfPayDate;
        ncfPayDateValue.value = TextEditingValue(
            text: '${ncfPayDate?.format(payload: 'DD/MM/YYYY')}');
      }
      currentIdValue = widget.sale?.idType;

      currentConceptId = widget.sale?.conceptId;
      currentNcfTypeId = widget.sale?.invoiceNcfTypeId;
      currentNcfType =
          ncfs.firstWhere((element) => element.id == currentNcfTypeId);
      ncf.value = TextEditingValue(text: widget.sale!.invoiceNcf.substring(3));

      if (widget.sale?.invoiceNcfModifedTypeId != null) {
        currentNcfModifedId = widget.sale?.invoiceNcfModifedTypeId;
        currentNcfModifedType =
            ncfs.firstWhere((element) => element.id == currentNcfModifedId);
        ncfModifed.value = TextEditingValue(
            text: widget.sale!.invoiceNcfModifed!.substring(3));
      }

      currentTypeOfIncome = widget.sale?.typeOfIncome;
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
    }
  }

  init() async {
    if (!mounted) return;
    await preloadDialogMetaData();
    startDate = widget.companyDetailsPage.startDate;
    setupEditContent();
    setState(() {});
    ncfDate.value =
        TextEditingValue(text: startDate.format(payload: 'DD/MM/YYYY'));
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
                    controller: ncfDate,
                    labelText: "FECHA DE EMISION DE NCF",
                    hintText: "FECHA DE EMISION DE NCF",
                    startDate: startDate,
                    date: startDate),
                const SizedBox(height: 20),
                SelectorConceptWidget(
                    value: currentConceptId,
                    concepts: concepts,
                    onSelected: (current, index) {
                      currentConceptId = current?.id;
                    }),
                const SizedBox(height: 20),
                NcfEditorWidget(
                    currentNcfTypeId: currentNcfTypeId,
                    controller: ncf,
                    ncfs: ncfs,
                    hintText: 'NCF',
                    onChanged: (item) {
                      currentNcfType = item;
                      currentNcfTypeId = item?.id;
                    }),
                NcfEditorWidget(
                    currentNcfTypeId: currentNcfModifedId,
                    controller: ncfModifed,
                    ncfs: ncfs,
                    hintText: 'NCF MODIFICADO',
                    onChanged: (item) {
                      currentNcfModifedType = item;
                      currentNcfModifedId = item?.id;
                    }),
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
                  items: typeOfIncomes
                      .map((e) => DropdownMenuItem(
                          value: e.id, child: Text(e.name.toString())))
                      .toList(),
                ),
                const SizedBox(height: 20),
                DateSelectorWidget(
                    onSelected: (date) {
                      ncfPayDate = date;
                      ncfRetentionDate = date;
                    },
                    controller: ncfPayDateValue,
                    isPayNcf: true,
                    labelText: "FECHA DE RETENCION DE NCF",
                    hintText: "FECHA DE RETENCION DE NCF",
                    startDate: startDate,
                    date: ncfPayDate),
                const SizedBox(height: 20),
                TextFormField(
                  controller: total,
                  validator: (val) =>
                      val == null || val == '' ? 'CAMPO REQUERIDO' : null,
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
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'ITBIS FACTURADO',
                      labelText: 'ITBIS FACTURADO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: retentionTaxByOthers,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'ITBIS RETENIDO POR TERCEROS',
                      labelText: 'ITBIS RETENIDO POR TERCEROS',
                      border: OutlineInputBorder()),
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
                  decoration: const InputDecoration(
                      hintText: 'RETENCION DE RENTA POR TERCEROS',
                      labelText: 'RETENCION DE RENTA POR TERCEROS',
                      border: OutlineInputBorder()),
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
                  decoration: const InputDecoration(
                      hintText: 'EFECTIVO',
                      labelText: 'EEFCTIVO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: checkTransferDeposit,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'CHEQUE / TRANSFERENCIA / DEPOSITO',
                      labelText: 'CHEQUE / TRANSFERENCIA / DEPOSITO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: debitCreditCard,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'TARJETA DE DEBITO / CREDITO',
                      labelText: 'TARJETA DE DEBITO / CREDITO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: saleOnCredit,
                  inputFormatters: [myformatter],
                  style: const TextStyle(fontSize: 19),
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
                widget.isEditing
                    ? Expanded(
                        child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).colorScheme.error)),
                            onPressed: deleteSale,
                            child: const Text('ELIMINAR VENTA',
                                style: TextStyle(fontSize: 17))),
                      ))
                    : Container(),
                widget.isEditing ? const SizedBox(width: 10) : Container(),
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

  Widget get loadingWidget {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [CircularProgressIndicator()],
    );
  }

  @override
  dispose() {
    rnc.dispose();
    total.dispose();
    tax.dispose();
    ncfs = [];
    typeOfIncomes = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        contentPadding: const EdgeInsets.all(15),
        content: SizedBox(
            width: modalSalesWidth,
            child: isLoading ? loadingWidget : content));
  }
}
