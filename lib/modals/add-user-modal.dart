// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/controllers/permissions.controller.dart';
import 'package:uresaxapp/controllers/session.controller.dart';
import 'package:uresaxapp/models/role.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class AddUserModal extends StatefulWidget {
  User? user;
  List<Role> roles;
  bool? isEditing;

  AddUserModal(
      {super.key,
      this.isEditing = false,
      required this.user,
      required this.roles});

  @override
  State<AddUserModal> createState() => _AddUserModalState();
}

class _AddUserModalState extends State<AddUserModal> {
  TextEditingController fullname = TextEditingController();

  TextEditingController username = TextEditingController();

  TextEditingController password = TextEditingController();

  int? roleId;

  bool showPassword = false;

  final _formKey = GlobalKey<FormState>();

  late PermissionsController permissionsController;

  late SessionController sessionController;

  bool get isOtherSuperUser {
    if (sessionController.currentUser!.value!.isSuperUser &&
        sessionController.currentUser!.value!.id != widget.user?.id) {
      return false;
    }
    return sessionController.currentUser!.value!.id != widget.user?.id &&
        (widget.user!.isSuperUser || widget.user!.isAdmin);
  }

  String get title {
    return widget.isEditing! ? 'Editando Usuario...' : 'Añadiendo Usuario...';
  }

  @override
  void initState() {
    username.value = TextEditingValue(text: widget.user?.username ?? '');
    fullname.value = TextEditingValue(text: widget.user?.name ?? '');
    roleId = widget.user?.roleId;
    super.initState();
  }

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      showLoader(context);
      try {
        var newUser = User(
            id: widget.user?.id ?? '',
            name: fullname.text,
            username: username.text,
            password: password.text,
            permissions: widget.user?.permissions,
            roleId: roleId);

        if (!widget.isEditing!) {
          newUser = await newUser.create();
        } else {
          newUser = await newUser.update();
        }

        if (sessionController.currentUser!.value!.id == widget.user!.id) {
          sessionController.currentUser = Rx(newUser);
          sessionController.update();
        }
        Get.back();

        Get.back(result: newUser);

        if (widget.isEditing != null && widget.isEditing!) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE ACTUALIZO EL USUARIO')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SE INSERTO EL USUARIO')));
        }
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    permissionsController = Get.find<PermissionsController>();
    sessionController = Get.find<SessionController>();
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: AlertDialog(
                contentPadding: const EdgeInsets.all(20),
                content: Form(
                    key: _formKey,
                    child: SizedBox(
                        width: 450,
                        height: 500,
                        child: Column(
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
                            SizedBox(
                              height: kDefaultPadding / 2,
                            ),
                            Expanded(
                                child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                  top: kDefaultPadding * 0.3,
                                  bottom: kDefaultPadding * 0.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: fullname,
                                    inputFormatters: [UpperCaseTextFormatter()],
                                    style: const TextStyle(fontSize: 18),
                                    validator: (val) =>
                                        val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'NOMBRE COMPLETO',
                                        hintText: 'NOMBRE COMPLETO'),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: username,
                                    style: const TextStyle(fontSize: 18),
                                    validator: (val) =>
                                        val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                                    inputFormatters: [UpperCaseTextFormatter()],
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'NOMBRE DE USUARIO',
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
                                          validator: (val) => val!.isEmpty
                                              ? 'CAMPO REQUERIDO'
                                              : null,
                                          decoration: InputDecoration(
                                              suffixIcon: Wrap(
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          showPassword =
                                                              !showPassword;
                                                        });
                                                      },
                                                      icon: Icon(showPassword
                                                          ? Icons
                                                              .visibility_outlined
                                                          : Icons
                                                              .visibility_off_outlined)),
                                                  SizedBox(
                                                      width:
                                                          kDefaultPadding / 2)
                                                ],
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              labelText: 'CONTRASEÑA',
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
                                        labelText: 'ROLES',
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ))),
                                    dropdownColor: Colors.white,
                                    enableFeedback: false,
                                    isExpanded: true,
                                    focusColor: Colors.white,
                                    onChanged: isOtherSuperUser
                                        ? null
                                        : (int? val) {
                                            roleId = val;

                                            if (roleId == 1 || roleId == 3) {
                                              widget.user?.permissions =
                                                  adminPermissions;
                                            } else if (roleId == 2) {
                                              widget.user?.permissions =
                                                  editorPermissions;
                                            }
                                            setState(() {});
                                          },
                                    items: widget.roles.map((role) {
                                      return DropdownMenuItem(
                                          value: role.id,
                                          child: Text(role.name ?? ''));
                                    }).toList(),
                                  ),
                                  SizedBox(
                                    height: kDefaultPadding,
                                  ),
                                  Text('PERMISOS',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  SizedBox(
                                    height: kDefaultPadding,
                                  ),
                                  Opacity(
                                    opacity: isOtherSuperUser ? 0.5 : 1,
                                    child: Column(
                                      children: [
                                        ...permissionsController.permissions
                                            .map((e) {
                                          var val = widget.user?.permissions
                                              ?.contains(e.name);
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Checkbox(
                                                value: val,
                                                onChanged: (value) {
                                                  if (isOtherSuperUser) {
                                                    return;
                                                  }

                                                  if (val == true) {
                                                    widget.user?.permissions
                                                        ?.remove(e.name);
                                                  } else {
                                                    widget.user?.permissions
                                                        ?.add(e.name);
                                                  }
                                                  val = widget.user?.permissions
                                                      ?.contains(e.name);

                                                  setState(() {});
                                                }),
                                            title: Text(e.displayName),
                                          );
                                        }),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )),
                            SizedBox(
                              height: 50,
                              width: double.maxFinite,
                              child: ElevatedButton(
                                onPressed: isOtherSuperUser ? null : _onSubmit,
                                child: Text(widget.isEditing!
                                    ? 'EDITAR USUARIO'
                                    : 'AÑADIR USUARIO'),
                              ),
                            )
                          ],
                        ))))));
  }
}
