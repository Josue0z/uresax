// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:uresaxapp/models/role.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class AddUserModal extends StatefulWidget {
  User? user;
  bool? isEditing;

  AddUserModal({super.key, this.isEditing = false, this.user});

  @override
  State<AddUserModal> createState() => _AddUserModalState();
}

class _AddUserModalState extends State<AddUserModal> {
  TextEditingController fullname = TextEditingController();

  TextEditingController username = TextEditingController();

  TextEditingController password = TextEditingController();

  List<Role> roles = [Role(id: null, name: 'ROLE')];

  int? roleId;

  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();

  String get title {
    return widget.isEditing! ? 'Editando Usuario...' : 'Añadiendo Usuario...';
  }

  @override
  void initState() {
    if (mounted) {
      Role.all()
          .then((value) => setState(() {
                roles.addAll(value);
                if (widget.user != null) {
                  username.value =
                      TextEditingValue(text: widget.user!.username!);
                  fullname.value = TextEditingValue(text: widget.user!.name!);
                  roleId = widget.user!.roleId;
                }
              }))
          .catchError(print);
    }
    super.initState();
  }

  _onSubmit() async {
    try {
      if (_formKey.currentState!.validate()) {
        var newUser = User(
            id: widget.user?.id ?? '',
            name: fullname.text,
            username: username.text,
            password: password.text,
            roleId: roleId);

        if (!widget.isEditing!) {
          newUser = await newUser.create();
        } else {
          newUser = await newUser.update();
        }
        Navigator.pop(context, newUser);
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        content: Form(
            key: _formKey,
            child: SizedBox(
                width: 500,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Row(
                        children: [
                          Text(title.toUpperCase(),
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 24)),
                          const Spacer(),
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close))
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: fullname,
                        style: const TextStyle(fontSize: 18),
                        validator: (val) =>
                            val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'NOMBRE DE COMPLETO'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: username,
                        style: const TextStyle(fontSize: 18),
                        validator: (val) =>
                            val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                        inputFormatters: [LowerCaseTextFormatter()],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'NOMBRE DE USUARIO'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      !widget.isEditing!
                          ? TextFormField(
                              controller: password,
                              style: const TextStyle(fontSize: 18),
                              obscureText: !showPassword,
                              validator: (val) =>
                                  val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          showPassword = !showPassword;
                                        });
                                      },
                                      icon: Icon(showPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined)),
                                  border: const OutlineInputBorder(),
                                  hintText: 'CONTRASEÑA'),
                            )
                          : Container(),
                      !widget.isEditing!
                          ? const SizedBox(
                              height: 20,
                            )
                          : Container(),
                      DropdownButtonFormField(
                        value: roleId,
                        validator: (val) =>
                            val == null ? 'CAMPO REQUERIDO' : null,
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ))),
                        dropdownColor: Colors.white,
                        enableFeedback: false,
                        isExpanded: true,
                        focusColor: Colors.white,
                        onChanged: (val) {
                          roleId = val;
                        },
                        items: roles.map((role) {
                          return DropdownMenuItem(
                              value: role.id, child: Text(role.name!));
                        }).toList(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50,
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: _onSubmit,
                          child: Text(widget.isEditing!
                              ? 'EDITAR USUARIO'
                              : 'AÑADIR USUARIO'),
                        ),
                      )
                    ],
                  ),
                ))));
  }
}
