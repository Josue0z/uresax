// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class AddNotesModal extends StatefulWidget {
  Company company;

  AddNotesModal({
    super.key,
    required this.company,
  });

  @override
  State<AddNotesModal> createState() => _AddNotesModalState();
}

class _AddNotesModalState extends State<AddNotesModal> {
  TextEditingController notes = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();

  @override
  void initState() {
    phone.value = TextEditingValue(text: widget.company.phone ?? '');
    email.value = TextEditingValue(text: widget.company.email ?? '');
    address.value = TextEditingValue(text: widget.company.address ?? '');
    notes.value = TextEditingValue(text: widget.company.notes ?? '');
    super.initState();
  }

  @override
  void dispose() {
    notes.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    super.dispose();
  }

  onSubmit() async {
    showLoader(context);
    try {
      widget.company.notes = notes.text;
      widget.company.phone = phone.text;
      widget.company.email = email.text;
      widget.company.address = address.text;
      await widget.company.update();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('LA NOTA DE ${widget.company.name} FUE ACTUALIZADA')));
      Get.back();
      Get.back();
    } catch (e) {
      Get.back();
      showAlert(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Dialog(
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 350,
            height: 450,
            child: Form(
                child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.all(kDefaultPadding * 0.5),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '${widget.company.name} (NOTAS)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20),
                        )),
                        IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.close))
                      ],
                    )),
                Expanded(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.all(kDefaultPadding * 0.5),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [PhoneTextFormatter()],
                        decoration: const InputDecoration(
                            labelText: 'TELEFONO',
                            hintText: 'TELEFONO',
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(height: kDefaultPadding),
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            labelText: 'CORREO',
                            hintText: 'CORREO',
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(height: kDefaultPadding),
                      TextFormField(
                        controller: address,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            labelText: 'DIRECCION',
                            hintText: 'DIRECCION',
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(height: kDefaultPadding),
                      TextFormField(
                        controller: notes,
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        decoration: const InputDecoration(
                            labelText: 'NOTAS',
                            hintText: 'NOTAS',
                            border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                )),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: kDefaultPadding * 0.5,
                        vertical: kDefaultPadding * 0.3),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: onSubmit,
                          child: const Text('EDITAR DATOS')),
                    ))
              ],
            )),
          ),
        )));
  }
}
