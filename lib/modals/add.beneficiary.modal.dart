// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/controllers/beneficiaries.controller.dart';
import 'package:uresaxapp/models/beneficiary.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class BeneficiaryModal extends StatefulWidget {
  Beneficiary? beneficiary;

  bool isEditing;

  BeneficiaryModal({super.key, this.beneficiary, this.isEditing = false});

  @override
  State<BeneficiaryModal> createState() => _BeneficiaryModalState();
}

class _BeneficiaryModalState extends State<BeneficiaryModal> {
  TextEditingController name = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String get title {
    return !widget.isEditing
        ? 'AÑADIENDO BENEFICIARIO'
        : 'EDITANDO BENEFICIARIO';
  }

  String get btnTitle {
    return !widget.isEditing ? 'AÑADIR BENEFICIARIO' : 'EDITAR BENEFICIARIO';
  }

  onSubmit() async {
    if (formKey.currentState!.validate()) {
      try {
        var beneficiary =
            Beneficiary(id: widget.beneficiary?.id, name: name.text.trim());

        if (!widget.isEditing) {
          await beneficiary.create();
        } else {
          await beneficiary.update();
        }
        var c = Get.find<BeneficiariesController>();
        c.beneficiaries.value = [
          Beneficiary(name: 'BENEFICIARIO'),
          ...(await Beneficiary.get())
        ];
        Get.back();
        if (widget.isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE ACTUALIZO EL BENEFICIARIO')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE INSERTO EL BENEFICIARIO')));
        }
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    name.value = TextEditingValue(text: widget.beneficiary?.name ?? '');
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Dialog(
                child: Form(
                    key: formKey,
                    child: SizedBox(
                      width: 350,
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10),
                        children: [
                          Row(
                            children: [
                              Text(title,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20)),
                              const Spacer(),
                              IconButton(
                                  onPressed: () => Get.back(),
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                              child: Column(
                            children: [
                              TextFormField(
                                controller: name,
                                validator: (val) =>
                                    val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                                inputFormatters: [UpperCaseTextFormatter()],
                                decoration: const InputDecoration(
                                    labelText: 'NOMBRE',
                                    hintText: 'NOMBRE',
                                    border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.maxFinite,
                                height: 50,
                                child: ElevatedButton(
                                    onPressed: onSubmit, child: Text(btnTitle)),
                              )
                            ],
                          ))
                        ],
                      ),
                    )))));
  }
}
