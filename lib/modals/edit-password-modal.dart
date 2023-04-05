import 'package:flutter/material.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/edit-password-widget.dart';

class EditPasswordModal extends StatefulWidget {


  User user;

  EditPasswordModal({super.key, required this.user});

  @override
  State<EditPasswordModal> createState() => _EditPasswordModalState();
}

class _EditPasswordModalState extends State<EditPasswordModal> {

  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();

  _editPassword() async {
    try {
      await widget.user.editPassword(currentPassword.text, newPassword.text);
      Navigator.pop(context);
    } catch (e) {
      showAlert(context, message: e.toString());
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
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        content: SizedBox(
          width: 450,
          child: Form(
            child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(15),
            children: [
              Row(
                children: [
                  Text('CAMBIANDO CONTRASEÑA...',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Theme.of(context).primaryColor)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 20),
              EditPasswordWidget(
                controller:currentPassword,
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
        ));
  }
}
