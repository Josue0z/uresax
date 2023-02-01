// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uresaxapp/models/banking.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/invoicetype.dart';
import 'package:uresaxapp/models/payment-method.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/retention.dart';
import 'package:uresaxapp/models/sheet.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/ncf-editor-widget.dart';

class AddPurchaseModal extends StatefulWidget {
  final Book book;
  final Sheet sheet;
  Map<String, dynamic>? invoice;
  bool? isEditing;
  AddPurchaseModal({
    super.key,
    this.invoice,
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
  List<Retention> retentions = [Retention(id: null, name: 'RETENCION')];

  int? currentConcept;
  int? currentBanking;
  int? currentType;
  int? currentPaymentMethod;
  int? currentRetention;
  bool isCorrectRnc = false;

  TextEditingController rnc = TextEditingController();
  TextEditingController ck = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController day = TextEditingController();
  TextEditingController totalServ = TextEditingController();
  TextEditingController totalBin = TextEditingController();
  TextEditingController itbis16 = TextEditingController();
  TextEditingController itbis18 = TextEditingController();
  TextEditingController company = TextEditingController();

  String? ncf;
  String? ncfVal;
  String? ncfModifed;
  String? ncfModifedVal;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  bool get isAllCorrect {
    return isCorrectRnc && _formKey.currentState!.validate();
  }

  String get _title {
    return widget.isEditing! ? 'Compra Seleccionada...' : 'Añadiendo Compra...';
  }

  String get _titleBtn {
    return widget.isEditing! ? 'EDITAR COMPRA' : 'AÑADIR COMPRA';
  }

  bool get isBinCode =>
      currentType == 3 ||
      currentType == 8 ||
      currentType == 9 ||
      currentType == 10;

  @override
  void initState() {
    _initElements();
    year.value = TextEditingValue(text: widget.sheet.sheetDate!);
    rnc.addListener(_verifyTaxPayer);
    super.initState();
  }

  Future<void> _initElements() async {
    try {
      setState(() {
        isLoading = true;
      });

      concepts.addAll(await Concept.getConcepts());
      bankings.addAll(await Banking.getBankings());
      invoiceTypes.addAll(await InvoiceType.getInvoiceTypes());
      paymentMethods.addAll(await PaymentMethod.getPaymentMethods());
      retentions.addAll(await Retention.all());

      if (widget.invoice != null) {
        rnc.value = TextEditingValue(text: widget.invoice!['RNC']);
        String c = '';

        if (widget.invoice!['NUMERO DE CHEQUE'] == null) {
          c = '';
        } else {
          c = widget.invoice!['NUMERO DE CHEQUE'].toString();
        }

        ck.value = TextEditingValue(text: c);
        currentBanking = widget.invoice!['ID DE BANCO'];
        currentConcept = widget.invoice!['ID DE CONCEPTO'];
        currentRetention = widget.invoice!['ID RETENCION'];
        var chars = (widget.invoice!['DIA'] as String).split('');
        if (chars[0] == '0') chars[0] = '';
        day.value = TextEditingValue(text: chars.join(''));
        ncf = widget.invoice!['NOMBRE DE NCF'];
        ncfVal = widget.invoice!['NCF'];
        ncfModifed = widget.invoice!['NOMBRE DE NCF MODIFICADO'];
        ncfModifedVal = widget.invoice!['NCF MODIFICADO'];
        currentType = invoiceTypes
            .firstWhere((element) =>
                '${element.id}-${element.name}' == widget.invoice!['TIPO'])
            .id;
        currentPaymentMethod = paymentMethods
            .firstWhere((element) =>
                '${element.id}-${element.name}' ==
                widget.invoice!['FORMA DE PAGO'])
            .id;

        var formatter = ThousandsFormatter(allowFraction: true);

        var nval5 = double.parse(widget.invoice!['TOTAL EN SERVICIOS']);

        var val1 = formatter.formatEditUpdate(
            const TextEditingValue(text: ''),
            TextEditingValue(
                text: nval5 == 0.00
                    ? ''
                    : widget.invoice!['TOTAL EN SERVICIOS']));

        var nval3 = double.parse(widget.invoice!['TOTAL EN BIENES']);

        var val3 = formatter.formatEditUpdate(const TextEditingValue(text: ''),
            TextEditingValue(text: nval3 == 0.00 ? '' : nval3.toString()));

        var nval2 = double.parse(widget.invoice!['ITBIS 18%']);

        var val2 = formatter.formatEditUpdate(const TextEditingValue(text: ''),
            TextEditingValue(text: nval2 == 0.00 ? '' : nval2.toString()));

        var nval4 = double.parse(widget.invoice!['ITBIS 16%']);

        var val4 = formatter.formatEditUpdate(const TextEditingValue(text: ''),
            TextEditingValue(text: nval4 == 0.00 ? '' : nval4.toString()));

        totalServ.value = val1;
        totalBin.value = val3;
        itbis18.value = val2;
        itbis16.value = val4;
      }
    } catch (e) {
      print(e);
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
    } catch (e) {
      company.value = const TextEditingValue(text: '');
      isCorrectRnc = false;
    } finally {
      setState(() {});
    }
  }

  Future<void> _onSubmit() async {
    try {
      if (isAllCorrect) {
        var purchase = Purchase(
          id: widget.invoice?['id'] ?? '',
          invoiceRnc: rnc.text,
          invoiceConceptId: currentConcept,
          invoiceTypeId: currentType,
          invoicePaymentMethodId: currentPaymentMethod,
          invoiceNcf: ncfVal,
          invoiceNcfModifed: ncfModifedVal,
          invoiceNcfDate: year.text,
          invoiceNcfDay: day.text,
          invoiceSheetId: widget.sheet.id,
          invoiceBookId: widget.book.id,
          invoiceCompanyId: widget.book.companyId,
          invoiceBankingId: currentBanking,
          invoiceCk: ck.text.isEmpty ? null : ck.text,
          invoiceRetentionId: currentRetention,
          invoiceItbis18:
              double.tryParse(itbis18.text.replaceAll(',', '')) ?? 0.00,
          invoiceItbis16:
              double.tryParse(itbis16.text.replaceAll(',', '')) ?? 0.00,
          invoiceTotalServ:
              double.tryParse(totalServ.text.replaceAll(',', '')) ?? 0.00,
          invoiceTotalBin:
              double.tryParse(totalBin.text.replaceAll(',', '')) ?? 0.00,
        );

        if (!widget.isEditing!) {
          await purchase.create();
          Navigator.pop(context, {
            'method': 'INSERT',
            'RNC': purchase.invoiceRnc,
            'NCF': purchase.invoiceNcf
          });
        } else {
          var data = await purchase.update();
          Navigator.pop(context,
              {'method': 'UPDATE', 'RNC': data['RNC'], 'NCF': data['NCF']});
        }
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  Future<void> _deletePurchase() async {
    try {
      await Purchase(id: widget.invoice?['id']).delete();
      Navigator.pop(context, {'method': 'DELETE', 'invoice': widget.invoice});
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: TextFormField(
                                      controller: rnc,
                                      maxLength: 11,
                                      style: const TextStyle(fontSize: 18),
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
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            //<-- SEE HERE
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            //<-- SEE HERE
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .errorColor)),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                    val: ncf,
                                    ncfVal: ncfVal,
                                    hintText: 'NCF',
                                    onChanged: (val) => ncfVal = val,
                                    validator: (val) =>
                                        val == null ? 'CAMPO REQUERIDO' : null,
                                  ),
                                  NcfEditorWidget(
                                    val: ncfModifed,
                                    ncfVal: ncfModifedVal,
                                    hintText: 'NCF MODIFICADO',
                                    onChanged: (val) => ncfModifedVal = val,
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
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            //<-- SEE HERE
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            //<-- SEE HERE
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .errorColor)),
                                        ),
                                        hint: const Text('TIPO DE FACTURA'),
                                        dropdownColor: Colors.white,
                                        enableFeedback: false,
                                        isExpanded: true,
                                        focusColor: Colors.white,
                                        onChanged: (val) {
                                          currentType = val;
                                          totalServ.value =
                                              TextEditingValue.empty;
                                          totalBin.value =
                                              TextEditingValue.empty;
                                          setState(() {});
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
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            //<-- SEE HERE
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            //<-- SEE HERE
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .errorColor)),
                                        ),
                                        hint: const Text('METODO DE PAGO'),
                                        dropdownColor: Colors.white,
                                        enableFeedback: false,
                                        isExpanded: true,
                                        focusColor: Colors.white,
                                        onChanged: (val) {
                                          currentPaymentMethod = val;
                                        },
                                        items:
                                            paymentMethods.map((paymentMethod) {
                                          return DropdownMenuItem(
                                            value: paymentMethod.id,
                                            child: Text(paymentMethod.name),
                                          );
                                        }).toList(),
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: DropdownButtonFormField<int?>(
                                        value: currentRetention,
                                        decoration: InputDecoration(
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            //<-- SEE HERE
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            //<-- SEE HERE
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .errorColor)),
                                        ),
                                        hint: const Text('RETENCION'),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: TextFormField(
                                      controller: year,
                                      style: const TextStyle(fontSize: 18),
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                          hintText: 'FECHA',
                                          border: OutlineInputBorder()),
                                    ),
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
                                          hintText: 'DIA',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: TextFormField(
                                      style: const TextStyle(fontSize: 18),
                                      controller: totalServ,
                                      enabled: !isBinCode,
                                      validator: (val) {
                                        if (isBinCode) return null;
                                        if (val != null) {
                                          return val.isEmpty
                                              ? 'CAMPO REQUERIDO'
                                              : null;
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      decoration: const InputDecoration(
                                          hintText: 'TOTAL COMO SERVICIO',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: TextFormField(
                                      style: const TextStyle(fontSize: 18),
                                      controller: totalBin,
                                      enabled: isBinCode,
                                      inputFormatters: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      validator: (val) {
                                        if (val != null) {
                                          if (isBinCode && val.isEmpty) {
                                            return 'CAMPO REQUERIDO';
                                          }
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: 'TOTAL COMO BIEN',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: TextFormField(
                                      style: const TextStyle(fontSize: 18),
                                      controller: itbis18,
                                      validator: (val) {
                                        if (val != null && val.isNotEmpty) {
                                          var n1 = double.parse(
                                              val.replaceAll(',', ''));

                                          var n2 = double.tryParse(totalServ
                                                  .text
                                                  .replaceAll(',', '')) ??
                                              0;
                                          var n3 = double.tryParse(totalBin.text
                                                  .replaceAll(',', '')) ??
                                              0;
                                          var tax1 = n2 * (18 / 100);
                                          var tax2 = n3 * (18 / 100);

                                          if (isBinCode) {
                                            if (n1 > tax2) {
                                              return 'ITBIS ES MAYOR QUE EL 18% DEL TOTAL - EL VALOR DESEADO DEBE SER IGUAL O MENOR QUE: $tax2';
                                            }
                                          } else {
                                            if (n1 > tax1) {
                                              return 'ITBIS ES MAYOR QUE EL 18% DEL TOTAL - EL VALOR DESEADO DEBE SER IGUAL O MENOR QUE: $tax1';
                                            }
                                          }
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      decoration: const InputDecoration(
                                          hintText: 'ITBIS 18%',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: TextFormField(
                                      style: const TextStyle(fontSize: 18),
                                      controller: itbis16,
                                      inputFormatters: [
                                        ThousandsFormatter(allowFraction: true)
                                      ],
                                      validator: (val) {
                                        if (val != null && val.isNotEmpty) {
                                          var n1 = double.parse(
                                              val.replaceAll(',', ''));

                                          var n2 = double.tryParse(totalServ
                                                  .text
                                                  .replaceAll(',', '')) ??
                                              0;
                                          var n3 = double.tryParse(totalBin.text
                                                  .replaceAll(',', '')) ??
                                              0;
                                          var tax1 = n2 * (16 / 100);
                                          var tax2 = n3 * (16 / 100);

                                          if (isBinCode) {
                                            if (n1 > tax2) {
                                              return 'ITBIS ES MAYOR QUE EL 16% DEL TOTAL - EL VALOR DESEADO DEBE SER IGUAL O MENOR QUE: $tax2';
                                            }
                                          } else {
                                            if (n1 > tax1) {
                                              return 'ITBIS ES MAYOR QUE EL 16% DEL TOTAL - EL VALOR DESEADO DEBE SER IGUAL O MENOR QUE: $tax1';
                                            }
                                          }
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                          hintText: 'ITBIS 16%',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  widget.isEditing!
                                      ? Text.rich(TextSpan(children: [
                                          TextSpan(
                                              text: 'AUTOR: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                          TextSpan(
                                              text: widget.invoice?['USUARIO']
                                                  .toUpperCase())
                                        ]))
                                      : Container(),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ],
                          )),
                          Row(
                            children: [
                              widget.isEditing!
                                  ? Expanded(
                                      child: ElevatedButton(
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.all(18)),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .errorColor)),
                                      onPressed: _deletePurchase,
                                      child: const Text('ELIMINAR COMPRA',
                                          style: TextStyle(fontSize: 19)),
                                    ))
                                  : Container(),
                              SizedBox(width: widget.isEditing! ? 20 : 0),
                              Expanded(
                                  child: ElevatedButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(18)),
                                ),
                                onPressed: !isCorrectRnc ? null : _onSubmit,
                                child: Text(_titleBtn,
                                    style: const TextStyle(fontSize: 19)),
                              )),
                            ],
                          )
                        ],
                      )),
                ))
            : null);
  }
}
