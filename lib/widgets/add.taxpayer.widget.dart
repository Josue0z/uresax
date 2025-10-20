import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/taxpayer.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';

class AddTaxPayerWidget extends StatefulWidget {
  final String rncOrId;

  const AddTaxPayerWidget({super.key, required this.rncOrId});

  @override
  State<AddTaxPayerWidget> createState() => _AddTaxPayerWidgetState();
}

class _AddTaxPayerWidgetState extends State<AddTaxPayerWidget> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController rnc = TextEditingController();
  bool loading = false;

  _onSubmit() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      try {
        var taxPayer = TaxPayer(
            taxPayerId: rnc.text,
            taxPayerCompanyName: name.text,
            taxPayerTradeName: '',
            createdAt: DateTime.now());
        taxPayer = await taxPayer.create();
        setState(() {
          loading = false;
        });
        Get.back(result: taxPayer);
      } catch (e) {
        setState(() {
          loading = false;
        });
        rethrow;
      }
    }
  }

  @override
  void initState() {
    rnc.value = TextEditingValue(text: widget.rncOrId);
    super.initState();
  }

  @override
  void dispose() {
    rnc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      width: 1,
      color: kWindowBorderColor,
      child: Column(
        children: [
          const CustomFrameWidgetDesktop(),
          Expanded(
              child: Dialog(
                  child: SizedBox(
            width: 350,
            child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  children: [
                    Row(
                      children: [
                        Text('AÑADIR CONTRIBUYENTE',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor)),
                        const Spacer(),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close))
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        TextFormField(
                          controller: name,
                          inputFormatters: [UpperCaseTextFormatter()],
                          validator: (val) =>
                              val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                          decoration: const InputDecoration(
                              hintText: 'RAZON SOCIAL',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: rnc,
                          validator: (val) => val!.isEmpty
                              ? 'CAMPO REQUERIDO'
                              : !(val.length == 11 || val.length == 9)
                                  ? 'CANTIDAD DE CARACTERES NO VALIDA'
                                  : null,
                          decoration: const InputDecoration(
                              hintText: 'RNC', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: _onSubmit,
                              child: loading
                                  ? const CircularProgressIndicator()
                                  : const Text('CREAR')),
                        )
                      ],
                    ),
                  ],
                )),
          )))
        ],
      ),
    );
  }
}
