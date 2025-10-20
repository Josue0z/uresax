// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/taxpayer.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/add.taxpayer.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class AddCompanyModal extends StatefulWidget {
  const AddCompanyModal({super.key});

  @override
  State<AddCompanyModal> createState() => AddCompanyModalState();
}

class AddCompanyModalState extends State<AddCompanyModal> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? rnc;
  TextEditingController? name;
  bool disabled = true;
  bool show = false;

  Future<void> _verifyTaxPayer() async {
    try {
      if (rnc?.value.text != null) {
        String value = rnc!.value.text;

        var data = await verifyTaxPayer(value);

        disabled = false;

        name?.value = TextEditingValue(text: data['tax_payer_company_name']);
        setState(() {});
      }
    } catch (e) {
      disabled = true;
      name?.value = const TextEditingValue(text: '');

      show = false;
      if (e == 'NOT EXISTS' &&
          (rnc?.text.length == 9 || rnc?.text.length == 11)) {
        show = true;
      }
      setState(() {});
    }
  }

  _onSubmit() async {
    Company? company;
    try {
      if (!disabled) {
        company = await Company(rnc: rnc!.text).create();
        Navigator.pop(context, company);
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  @override
  void initState() {
    rnc = TextEditingController();
    name = TextEditingController();
    rnc?.addListener(_verifyTaxPayer);
    super.initState();
  }

  @override
  void dispose() {
    rnc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: GestureDetector(
          onTap: () {
            if (FocusManager.instance.primaryFocus!.hasFocus) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: AlertDialog(
            content: SizedBox(
              width: 380,
              child: Form(
                  key: _formKey,
                  child: Material(
                    color: Colors.white,
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(kDefaultPadding * 0.3),
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text('AÑADIENDO CONTRIBUYENTE...',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .primaryColor))),
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close))
                          ],
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: name,
                          decoration: const InputDecoration(
                              hintText: 'CONTRIBUYENTE',
                              border: OutlineInputBorder()),
                          style: const TextStyle(fontSize: 20),
                          keyboardType: TextInputType.phone,
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                            controller: rnc,
                            onSubmitted: (_) => _onSubmit(),
                            decoration: InputDecoration(
                                suffixIcon: show
                                    ? Wrap(
                                        children: [
                                          IconButton(
                                              onPressed: () async {
                                                try {
                                                  var res = await showDialog<
                                                          TaxPayer?>(
                                                      context: context,
                                                      builder: (ctx) =>
                                                          AddTaxPayerWidget(
                                                            rncOrId: rnc!.text,
                                                          ));
                                                  if (res != null) {
                                                    name?.value = TextEditingValue(
                                                        text:
                                                            res.taxPayerCompanyName ??
                                                                '');
                                                  }
                                                } catch (e) {
                                                  showAlert(context,
                                                      message: e.toString());
                                                }
                                              },
                                              icon: const Icon(Icons.add)),
                                          const SizedBox(width: 10)
                                        ],
                                      )
                                    : null,
                                hintText: 'RNC/CEDULA',
                                border: const OutlineInputBorder()),
                            style: const TextStyle(fontSize: 20),
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                            autofocus: true),
                        const SizedBox(height: 8),
                        SizedBox(
                            width: double.maxFinite,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: disabled ? null : _onSubmit,
                                child: const Text(
                                  'AÑADIR CONTRIBUYENTE',
                                  style: TextStyle(fontSize: 19),
                                )))
                      ],
                    ),
                  )),
            ),
          ),
        )));
  }
}
