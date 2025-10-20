// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/modals/add-user-modal.dart';
import 'package:uresaxapp/modals/edit-password-modal.dart';
import 'package:uresaxapp/models/role.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class UsersPage extends StatefulWidget {
  List<User> users = [];

  UsersPage({super.key, required this.users});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  _showModalOfUser(User user, {bool isEditing = false}) async {
    showLoader(context);
    try {
      var roles = [Role(id: null, name: 'ROL'), ...(await Role.all())];

      var xuser =
          (await User.findUserById(user.id ?? 'x')) ?? User(permissions: []);

      Get.back();

      var result = await showDialog(
        context: context,
        builder: (ctx) =>
            AddUserModal(user: xuser, roles: roles, isEditing: isEditing),
      );

      if (result is User) {
        showLoader(context);
        widget.users = await User.all();
        Get.back();
        setState(() {});
      }
    } catch (e) {
      Get.back();
      showAlert(context, message: e.toString());
    }
  }

  _deleteUser(User user, int index) async {
    var isConfirm = await showConfirm(context, title: '¿Eliminar Usuario?');
    try {
      if (isConfirm!) {
        await user.delete();
        widget.users.removeAt(index);
        setState(() {});
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _showModalForEditPassword(User user) {
    showDialog(
        context: context, builder: (ctx) => EditPasswordModal(user: user));
  }

  Widget get contentEmpty {
    return Center(
      child: Icon(Icons.list_alt_outlined,
          size: 125, color: Theme.of(context).primaryColor),
    );
  }

  Widget get contentFilled {
    return ListView.separated(
        itemCount: widget.users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (ctx, index) {
          var user = widget.users[index];
          return ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100)),
              child: Icon(Icons.person_outlined,
                  color: Theme.of(context).primaryColor),
            ),
            minVerticalPadding: 15,
            title: Text(
              user.name!.toUpperCase(),
              style: TextStyle(
                fontSize: kxDefaultFontSize,
                color: const Color(0xFF074A80),
              ),
            ),
            subtitle: Column(
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20)),
                        child: SizedBox(
                            child: Center(
                          child: Text(user.roleName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)),
                        ))),
                    SizedBox(width: kDefaultPadding),
                    Text(user.username!, style: const TextStyle(fontSize: 18))
                  ],
                ),
              ],
            ),
            trailing: Wrap(
              children: [
                index > 0
                    ? IconButton(
                        onPressed: () => _deleteUser(user, index),
                        icon: const Icon(Icons.delete))
                    : const SizedBox(),
                IconButton(
                    onPressed: () => _showModalForEditPassword(user),
                    icon: const Icon(
                      Icons.lock,
                    )),
                IconButton(
                    onPressed: () => _showModalOfUser(user, isEditing: true),
                    icon: const Icon(Icons.edit))
              ],
            ),
          );
        });
  }

  Widget get content {
    if (widget.users.isEmpty) return contentEmpty;
    return contentFilled;
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      width: 1,
      color: kWindowBorderColor,
      child: Scaffold(
        body: Column(
          children: [
            const CustomFrameWidgetDesktop(),
            Expanded(
                child: Scaffold(
                    appBar: AppBar(
                      title: Text('USUARIOS (${widget.users.length})'),
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      actions: [
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 250,
                                height: 60,
                                child: TextFormField(
                                  inputFormatters: [UpperCaseTextFormatter()],
                                  onChanged: (words) async {
                                    try {
                                      var xusers = await User.all(
                                          words: words, searchMode: true);
                                      setState(() {
                                        widget.users = xusers;
                                      });
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  decoration: const InputDecoration(
                                      suffixIcon: Wrap(
                                        runAlignment: WrapAlignment.center,
                                        children: [
                                          Icon(Icons.search),
                                          SizedBox(width: 10)
                                        ],
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      hintText: 'BUSCAR...'),
                                ),
                              ),
                            ),
                            SizedBox(width: kDefaultPadding / 2),
                            ToolButton(
                                onTap: () =>
                                    _showModalOfUser(User(permissions: [])),
                                toolTip: 'ABRIR VENTANA PARA AÑADIR USUARIO',
                                icon: const Icon(Icons.add)),
                            ToolButton(
                                onTap: () => Get.back(),
                                toolTip: 'CERRAR VISTA DE USUARIOS',
                                icon: const Icon(Icons.close)),
                          ],
                        )
                      ],
                    ),
                    body: content))
          ],
        ),
      ),
    );
  }
}
