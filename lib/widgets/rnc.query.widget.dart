import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/modals/add-provider-modal.dart';
import 'package:uresaxapp/models/provider.dart';
import 'package:uresaxapp/pages/physical.person.page.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

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

  addPhysicalPerson() async {
    try {
      var person = await Get.to<PhysicalPerson?>(
          () => PhysicalPersonPage(id: widget.rnc.text));
      print(person);
      if (person != null) {
        widget.company.value = TextEditingValue(text: person.name);
        widget.rnc.value = TextEditingValue(text: person.id);
        isCorrectRnc = true;
        show = false;
        setState(() {});
        widget.onSelectedCorrectRnc(isCorrectRnc);
      }
    } catch (e) {
      showAlert(context, message: e.toString());
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
        if (widget.rnc.text.length == 11) {
          show = true;
        } else {
          show = false;
        }
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
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextFormField(
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
            decoration: const InputDecoration(
                hintText: 'RNC/CEDULA',
                labelText: 'RNC/CEDULA',
                border: OutlineInputBorder()),
          ),
        ),
      ],
    );
  }
}
