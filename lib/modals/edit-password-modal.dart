// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/edit-password-widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class EditPasswordModal extends StatefulWidget {
  User user;

  EditPasswordModal({super.key, required this.user});

  @override
  State<EditPasswordModal> createState() => _EditPasswordModalState();
}

class _EditPasswordModalState extends State<EditPasswordModal> {
  TextEditingController currentPassword = TextEditingController();

  TextEditingController newPassword = TextEditingController();

  final formKey = GlobalKey<FormState>();

  _editPassword() async {
    if (formKey.currentState!.validate()) {
      try {
        await widget.user.editPassword(currentPassword.text, newPassword.text);
        Get.back();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SE ACTUALIZO LA CONTRASEÑA')));
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  @override
  void dispose() {
    currentPassword.dispose();
    newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: AlertDialog(
                contentPadding: const EdgeInsets.all(20),
                content: SizedBox(
                  width: 450,
                  child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(
                            children: [
                              Text('CAMBIANDO CONTRASEÑA...',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor)),
                              const Spacer(),
                              IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close))
                            ],
                          ),
                          const SizedBox(height: 15),
                          EditPasswordWidget(
                            controller: currentPassword,
                            hintText: 'CONTRASEÑA ACTUAL',
                          ),
                          const SizedBox(height: 20),
                          EditPasswordWidget(
                            controller: newPassword,
                            hintText: 'CONTRASEÑA NUEVA',
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                                onPressed: _editPassword,
                                child: const Text('CAMBIAR AHORA')),
                          )
                        ],
                      )),
                ))));
  }
}
