import 'package:flutter/material.dart';
import 'package:uresaxapp/apis/http-client.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class AddCompanyModal extends StatefulWidget {
  const AddCompanyModal({Key? key}) : super(key: key);

  @override
  State<AddCompanyModal> createState() => AddCompanyModalState();
}

class AddCompanyModalState extends State<AddCompanyModal> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? rnc;
  TextEditingController? name;
  bool disabled = true;

  Future<void> _verifyTaxPayer() async {
    try {
      if (rnc?.value.text != null) {
        String value = rnc!.value.text;
        var data = await verifyTaxPayer(value);
        disabled = false;
        name?.value = TextEditingValue(text: data['tax_payer_company_name']);
      }
    } catch (e) {
      disabled = true;
      name?.value = const TextEditingValue(text: '');
    } finally {
      setState(() {});
    }
  }

  _onSubmit() async {
    Company? company;
    try {
      if (!disabled) {
        company = await Company.fromJson({'company_rnc': rnc!.text}).create();
        Navigator.pop(context, company);
      }
    } catch (e) {
      if (e is CompanyExists)
        showAlert(context, message: 'YA EXISTE UNA EMPRESA CON ESTE RNC');
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
    return GestureDetector(
      onTap: () {
        if (FocusManager.instance.primaryFocus!.hasFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Dialog(
          child: Form(
              key: _formKey,
              child: SizedBox(
                width: 450,
                child: Material(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(
                            children: [
                              Text('Añadiendo Compañia...',
                                  style: Theme.of(context).textTheme.headline5),
                              const Spacer(),
                              IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                          const SizedBox(height: 25),
                          TextFormField(
                            controller: name,
                            decoration: const InputDecoration(
                                hintText: 'EMPRESA',
                                border: OutlineInputBorder()),
                            style: const TextStyle(fontSize: 20),
                            keyboardType: TextInputType.phone,
                            enabled: false,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: rnc,
                            onSubmitted: (_) => _onSubmit(),
                            decoration: const InputDecoration(
                                hintText: 'RNC', border: OutlineInputBorder()),
                            style: const TextStyle(fontSize: 20),
                            keyboardType: TextInputType.phone,
                            maxLength: 11,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                              width: double.maxFinite,
                              height: 50,
                              child: ElevatedButton(
                                  onPressed: disabled ? null : _onSubmit,
                                  child: const Text(
                                    'AÑADIR COMPAÑIA',
                                    style: TextStyle(fontSize: 19),
                                  )))
                        ],
                      ),
                    )),
              ))),
    );
  }
}
