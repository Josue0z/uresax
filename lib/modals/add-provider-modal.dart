// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:uresaxapp/models/provider.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class AddProviderModal extends StatefulWidget {
  String rncOrId;

  AddProviderModal({super.key, this.rncOrId = ''});

  @override
  State<AddProviderModal> createState() => _AddProviderModalState();
}

class _AddProviderModalState extends State<AddProviderModal> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController rncOrId = TextEditingController();

  TextEditingController name = TextEditingController();

  @override
  initState() {
    rncOrId.value = TextEditingValue(text: widget.rncOrId);
    super.initState();
  }

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        var provider = PhysicalPerson(id: rncOrId.text, name: name.text);
        await provider.create();
        Navigator.pop(context, name.text);
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        content: SizedBox(
          width: 450,
          child: Form(
              key: _formKey,
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Row(
                        children: [
                          Text('AÑADIR PERSONA FISICA',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Theme.of(context).primaryColor)),
                          const Spacer(),
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close))
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: rncOrId,
                        validator: (val) => val!.isEmpty
                            ? 'CAMPO REQUERIDO'
                            : val.length < 11
                                ? 'LA CANTIDAD DE CARACTERES NO ES CORRECTA'
                                : null,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'RNC/CEDULA'),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: name,
                        validator: (val) =>
                            val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                        inputFormatters: [UpperCaseTextFormatter()],
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: 'NOMBRE'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.maxFinite,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: _onSubmit,
                            child: const Text('AÑADIR PROVEDOR')),
                      )
                    ],
                  ))),
        ));
  }
}
