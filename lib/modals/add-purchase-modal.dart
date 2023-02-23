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
import 'package:uresaxapp/utils/functions.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/ncf-editor-widget.dart';

class AddPurchaseModal extends StatefulWidget {
  final Purchase? purchase;
  final Book book;
  final Sheet sheet;
  bool isEditing;
  AddPurchaseModal({
    super.key,
    this.purchase,
    this.isEditing = false,
    required this.book,
    required this.sheet,
  });

  @override
  State<AddPurchaseModal> createState() => _AddPurchaseModalState();
}

class _AddPurchaseModalState extends State<AddPurchaseModal> {
  List<Concept> concepts = [Concept(name: 'CONCEPTO')];
  List<Banking> bankings = [Banking(name: 'BANCO')];
  List<InvoiceType> invoiceTypes = [InvoiceType(name: 'TIPO DE FACTURA')];
  List<PaymentMethod> paymentMethods = [PaymentMethod(name: 'METODO DE PAGO')];
  List<Retention> retentions = [Retention(id: null, name: 'RETENCION ISR')];
  List<NcfType> ncfs = [NcfType(name: 'TIPO DE COMPROBANTE')];
  List<RetentionTax> retentionTaxes = [
    RetentionTax(name: 'RETENCION DE ITBIS')
  ];

  int? currentConcept;
  int? currentBanking;
  int? currentType;
  int? currentPaymentMethod;
  int? currentRetention;
  int? currentNcfTypeId;
  int? currentNcfModifedTypeId;
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

  bool isLoading = true;

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
    _initElements();
    rnc.addListener(_verifyTaxPayer);
    super.initState();
  }

  Future<void> _initElements() async {
    try {
      var formatter = ThousandsFormatter(allowFraction: true);
      concepts.addAll(await Concept.getConcepts());
      bankings.addAll(await Banking.getBankings());
      invoiceTypes.addAll(await InvoiceType.getInvoiceTypes());
      paymentMethods.addAll(await PaymentMethod.getPaymentMethods());
      retentions.addAll(await Retention.all());
      ncfs.addAll(await NcfType.getNcfs());
      retentionTaxes.addAll(await RetentionTax.all());

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
        total.value = formatter.formatEditUpdate(TextEditingValue.empty,
            TextEditingValue(text: widget.purchase!.invoiceTotal.toString()));
        tax.value = formatter.formatEditUpdate(
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
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _verifyTaxPayer() async {
    try {
      var data = await verifyTaxPayer(rnc.value.text);
      company.value = TextEditingValue(text: data['tax_payer_company_name']);
      isCorrectRnc = true;
      setState(() {});
      return;
    } catch (e) {
      company.value = const TextEditingValue(text: '');
      isCorrectRnc = false;
      setState(() {});
      return;
    }
  }

  String? _validateTax(val) {
    if (val != null && val.isNotEmpty) {
      var n1 = double.parse(val.replaceAll(',', ''));

      var n2 = double.tryParse(total.text.replaceAll(',', '')) ?? 0;
      var tax1 = n2 * (18 / 100);
      var tax2 = n2 * (16 / 100);

      if (n1 > tax1 || n1 > tax2) {
        return 'ITBIS ES MAYOR QUE LA TASA APLICADA POR LEY';
      }
    }
    return null;
  }

  Future<void> _onSubmit() async {
    try {
      if (isAllCorrect) {
        var purchase = Purchase(
          id: widget.purchase?.id,
          invoiceRnc: rnc.text,
          invoiceConceptId: currentConcept,
          invoiceTypeId: currentType,
          invoicePaymentMethodId: currentPaymentMethod,
          invoiceNcf: ncf.text,
          invoiceNcfTypeId: currentNcfTypeId,
          invoiceNcfModifed: ncfModifed.text,
          invoiceNcfModifedTypeId: currentNcfModifedTypeId,
          invoiceYear: widget.book.year,
          invoiceMonth: widget.sheet.sheetMonth,
          invoiceNcfDay: day.text.trim(),
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
          invoiceTax: double.tryParse(tax.text.trim().replaceAll(',', '')) ?? 0,
          invoiceTotalAsService: !isGoodCode
              ? double.tryParse(total.text.trim().replaceAll(',', ''))
              : 0,
          invoiceTotalAsGood: isGoodCode
              ? double.tryParse(total.text.trim().replaceAll(',', ''))
              : 0,
        );

        if (!widget.isEditing) {
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
    return Dialog(
      child: !isLoading
          ? SizedBox(
              width: 600,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
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
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                    style: const TextStyle(fontSize: 18),
                                    controller: company,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                        hintText: 'EMPRESA',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                    controller: rnc,
                                    maxLength: 11,
                                    style: const TextStyle(fontSize: 18),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: DropdownButtonFormField<int?>(
                                      value: currentConcept,
                                      validator: (val) => val == null
                                          ? 'CAMPO REQUERIDO'
                                          : null,
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
                                      items: concepts.map((concept) {
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: DropdownButtonFormField<int?>(
                                      value: currentBanking,
                                      decoration: const InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                      ),
                                      hint: const Text('BANCO'),
                                      dropdownColor: Colors.white,
                                      enableFeedback: false,
                                      isExpanded: true,
                                      focusColor: Colors.white,
                                      onChanged: (val) {
                                        currentBanking = val;
                                      },
                                      items: bankings.map((banking) {
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
                                  onChanged: (id) {
                                    currentNcfTypeId = id;
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
                                  onChanged: (id) {
                                    currentNcfModifedTypeId = id;
                                  },
                                  ncfs: ncfs,
                                  validator: (val) =>
                                      val == null ? 'CAMPO REQUERIDO' : null,
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: DropdownButtonFormField<int?>(
                                      value: currentType,
                                      validator: (val) => val == null
                                          ? "CAMPO REQUERIDO"
                                          : null,
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
                                      items: invoiceTypes.map((invoiceType) {
                                        return DropdownMenuItem(
                                          value: invoiceType.id,
                                          child: Text(invoiceType.name),
                                        );
                                      }).toList(),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: DropdownButtonFormField<int?>(
                                      value: currentPaymentMethod,
                                      validator: (val) => val == null
                                          ? 'CAMPO REQUERIDO'
                                          : null,
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
                                      items: paymentMethods.map((item) {
                                        return DropdownMenuItem(
                                          value: item.id,
                                          child: Text(item.name),
                                        );
                                      }).toList(),
                                    )),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                      items: retentionTaxes.map((retention) {
                                        return DropdownMenuItem(
                                          value: retention.id,
                                          child: Text(retention.name!),
                                        );
                                      }).toList(),
                                    )),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                      items: retentions.map((retention) {
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
                                        ? (val) => val == null
                                            ? "CAMPO REQUERIDO"
                                            : null
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
                                        ? (val) => val == null
                                            ? "CAMPO REQUERIDO"
                                            : null
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
                                        ? (val) => val == null
                                            ? "CAMPO REQUERIDO"
                                            : null
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
                                    inputFormatters: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
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
                                    inputFormatters: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    decoration: const InputDecoration(
                                        hintText: 'ITBIS FACTURADO',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                widget.isEditing
                                    ? Text.rich(TextSpan(children: [
                                        TextSpan(
                                            text: 'AUTOR: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        TextSpan(text: widget.purchase?.author)
                                      ]))
                                    : Container(),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ],
                        )),
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
              ))
          : Container(
              color: Colors.transparent,
              width: 200,
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [CircularProgressIndicator()],
                ),
              ),
            ),
    );
  }
}
