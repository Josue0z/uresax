// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/taxpayer.dart';
import 'package:uresaxapp/pages/taxpayers.page.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/widgets/add.taxpayer.widget.dart';

class RncQueryWidget extends StatefulWidget {
  TextEditingController rnc = TextEditingController();

  TextEditingController company = TextEditingController();

  int maxLength;

  String hintText;

  Function(bool) onSelectedCorrectRnc;

  RncQueryWidget(
      {super.key,
      this.maxLength = 11,
      required this.rnc,
      this.hintText = 'PROVEEDOR',
      required this.company,
      required this.onSelectedCorrectRnc});

  @override
  State<RncQueryWidget> createState() => _RncQueryWidgetState();
}

class _RncQueryWidgetState extends State<RncQueryWidget> {
  bool show = false;

  bool isCorrectRnc = false;

  bool foundStatus = false;

  addPhysicalPerson() async {
    try {
      var res = await showDialog<TaxPayer?>(
          context: context,
          builder: (ctx) => AddTaxPayerWidget(
                rncOrId: widget.rnc.text,
              ));

      if (res != null) {
        widget.company.value = TextEditingValue(text: res.taxPayerCompanyName!);
        widget.rnc.value = TextEditingValue(text: widget.rnc.text);
      }
    } catch (e) {
      print(e);
    }
  }

  _verifyTaxPayer() async {
    try {
      if (widget.rnc.text.isEmpty) throw 'EMPTY';

      if (widget.rnc.text.length == 9 || widget.rnc.text.length == 11) {
        var data = await verifyTaxPayer(widget.rnc.value.text);
        widget.company.value =
            TextEditingValue(text: data['tax_payer_company_name']);
        isCorrectRnc = true;
        foundStatus = true;
        widget.onSelectedCorrectRnc(isCorrectRnc);
      } else {
        throw 'LENGTH NOT CORRECT';
      }
    } catch (e) {
      isCorrectRnc = false;
      if (e == 'EMPTY') {
        widget.company.value = TextEditingValue.empty;
        show = false;
      } else {
        if (widget.rnc.text.length == 11 || widget.rnc.text.length == 9) {
          show = true;
        } else {
          show = false;
        }
        foundStatus = false;
        widget.company.value = const TextEditingValue(text: 'NO ENCONTRADO');
      }
      widget.onSelectedCorrectRnc(isCorrectRnc);
    }
  }

  @override
  void initState() {
    if (!mounted) return;
    widget.rnc.addListener(_verifyTaxPayer);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          style: const TextStyle(fontSize: 18),
          controller: widget.company,
          readOnly: true,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            suffixIcon: Wrap(
              children: [
                IconButton(
                    onPressed: () async {
                      var res = await Get.to<TaxPayer?>(
                          () => const TaxPayersPage(),
                          preventDuplicates: false);
                      if (res != null) {
                        widget.company.value =
                            TextEditingValue(text: res.taxPayerCompanyName!);
                        widget.rnc.value =
                            TextEditingValue(text: res.taxPayerId!);
                      }
                    },
                    icon: const Icon(Icons.search)),
                const SizedBox(width: 15)
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: widget.rnc,
          autofocus: true,
          maxLength: widget.maxLength,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 18),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (val) => val == null
              ? 'CAMPO REQUERIDO'
              : !(val.length == 9 ||
                      val.length == 11 ||
                      val.length == widget.maxLength)
                  ? 'LA CANTIDAD DE CARACTERES NO ES VALIDA'
                  : null,
          decoration: InputDecoration(
            hintText: 'RNC/CEDULA',
            labelText: 'RNC/CEDULA',
            border: const OutlineInputBorder(),
            suffixIcon: show
                ? Wrap(
                    children: [
                      IconButton(
                          onPressed: addPhysicalPerson,
                          color: Theme.of(context).primaryColor,
                          icon: const Icon(Icons.add)),
                      const SizedBox(width: 15)
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
