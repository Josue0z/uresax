import 'package:flutter/material.dart';
import 'package:uresaxapp/modals/add-user-modal.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users = [];

  @override
  void initState() {
    User.all()
        .then((value) => setState(() {
              users = value;
            }))
        .catchError(print);
    super.initState();
  }

  _showModalForAddUser() async {
    var result =
        await showDialog(context: context, builder: (ctx) => AddUserModal());
    if (result is User) {
      setState(() {
        users.add(result);
      });
    }
  }

  _showModalForEdit(User user, int index) async {
    var result = await showDialog(
        context: context,
        builder: (ctx) => AddUserModal(isEditing: true, user: user));
    if (result is User) {
      setState(() {
        users[index] = result;
      });
    }
  }

  _deleteUser(User user, int index) async {
    var isConfirm = await showConfirm(context, title: 'Eliminar Usuario?');
    try {
      if (isConfirm!) {
        await user.delete();
        users.removeAt(index);
        setState(() {
          
        });
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USUARIOS'),
      ),
      body: ListView.separated(
          separatorBuilder: (ctx, i) => const Divider(),
          itemCount: users.length,
          itemBuilder: (ctx, index) {
            var user = users[index];
            return ListTile(
              leading: Icon(Icons.account_circle_outlined,
                  size: 50, color: Theme.of(context).primaryColor),
              minVerticalPadding: 15,
              title: Text(
                user.name!,
                style: const TextStyle(fontSize: 26),
              ),
              subtitle: Column(
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(2)),
                        child: Text(
                          user.roleName!,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(user.username!, style: const TextStyle(fontSize: 18))
                    ],
                  ),
                ],
              ),
              trailing: Wrap(
                children: [
                  IconButton(
                      onPressed: () => _deleteUser(user, index),
                      color: Theme.of(context).errorColor,
                      icon: const Icon(Icons.delete)),
                  IconButton(
                      onPressed: () => _showModalForEdit(user, index),
                      color: Colors.green,
                      icon: const Icon(Icons.edit))
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showModalForAddUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
