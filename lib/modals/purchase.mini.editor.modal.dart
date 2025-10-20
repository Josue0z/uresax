import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/invoicetype.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:uresaxapp/models/payment-method.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uresaxapp/widgets/ncf-editor-widget.dart';
import 'package:uresaxapp/widgets/widget.concept.selector.dart';

class PurchaseMinEditorModal extends StatefulWidget {
  List<Concept> concepts = [];
  List<NcfType> ncfs = [];
  List<InvoiceType> invoiceTypes = [];
  List<PaymentMethod> paymentsMethods = [];
  int? currentNcfModifedTypeId = 0;
  NcfType? currentNcfModifedType;
  TextEditingController ncfModifed;
  bool isNcfModifed;
  PurchaseMinEditorModal(
      {super.key,
      this.paymentsMethods = const [],
      this.invoiceTypes = const [],
      this.concepts = const [],
      this.ncfs = const [],
      this.currentNcfModifedTypeId,
      this.currentNcfModifedType,
      required this.ncfModifed,
      this.isNcfModifed = true});

  @override
  State<PurchaseMinEditorModal> createState() => _PurchaseMinEditorModalState();
}

class _PurchaseMinEditorModalState extends State<PurchaseMinEditorModal> {
  Concept? concept;
  int? invoiceTypeId;
  InvoiceType? invoiceType;
  int? paymentMethodId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget get content {
    return Column(
      children: [
        Column(
          children: [
            SelectorConceptWidget(
                value: concept,
                onSelected: (xconcept, id) {
                  concept = xconcept;
                }),
            const SizedBox(height: 20),
            DropdownButtonFormField(
                value: invoiceTypeId,
                isExpanded: true,
                validator: (val) =>
                    val == null ? 'TIPO DE FACTURA REQUERIDO' : null,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'TIPO DE FACTURA',
                    hintText: 'TIPO DE FACTURA'),
                items: List.generate(widget.invoiceTypes.length, (index) {
                  var xinvoiceType = widget.invoiceTypes[index];
                  return DropdownMenuItem(
                      value: xinvoiceType.id,
                      child: Text(xinvoiceType.fullName));
                }),
                onChanged: (id) {
                  invoiceTypeId = id;
                }),
            const SizedBox(height: 20),
            DropdownButtonFormField(
                value: paymentMethodId,
                isExpanded: true,
                validator: (val) =>
                    val == null ? 'METODO DE PAGO REQUERIDO' : null,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'METODO DE PAGO',
                    hintText: 'METODO DE PAGO'),
                items: List.generate(widget.paymentsMethods.length, (index) {
                  var xpaymentMethod = widget.paymentsMethods[index];
                  return DropdownMenuItem(
                      value: xpaymentMethod.id,
                      child: Text(xpaymentMethod.fullName));
                }),
                onChanged: (id) {
                  paymentMethodId = id;
                })
          ],
        ),
        const SizedBox(height: 20),
        widget.isNcfModifed
            ? NcfEditorWidget(
                currentNcfTypeId: widget.currentNcfModifedTypeId,
                isNcfModifed: true,
                controller: widget.ncfModifed,
                hintText: 'NCF MODIFICADO',
                isSelectorEnabled: false,
                onChanged: (type) {
                  widget.currentNcfModifedType = type;
                  widget.currentNcfModifedTypeId = type?.id;
                },
                ncfs: widget.ncfs,
                validator: (val) => val == null ? 'CAMPO REQUERIDO' : null,
              )
            : const SizedBox(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWithBar(
        child: Dialog(
      child: Form(
          key: _formKey,
          child: Container(
              width: 350,
              padding: EdgeInsets.all(20),
              child: ListView(
              shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('AÑADIENDO COMPRA O GASTO...',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor))),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  const SizedBox(height: 20),
                  content,
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: () {
                          try {
                            if (concept == null) {
                              throw 'EL CONCEPTO ESTA VACIO';
                            }
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(context, [
                                concept?.id,
                                invoiceTypeId,
                                paymentMethodId,
                                '${widget.currentNcfModifedType?.ncfTag}${widget.ncfModifed.text}'
                              ]);
                            }
                          } catch (e) {
                            showAlert(context, message: e.toString());
                          }
                        },
                        child: Text('CREAR')),
                  )
                ],
              ))),
    ));
  }
}
