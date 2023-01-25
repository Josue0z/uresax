import 'package:flutter/material.dart';
import 'package:uresaxapp/modals/add-user-modal.dart';
import 'package:uresaxapp/models/user.dart';

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

  _showModal() async {
    var result = await showDialog(
        context: context, builder: (ctx) => const AddUserModal());

    if (result is User) {
      setState(() {
        users.add(result);
      });
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
                      onPressed: () {},
                      color: Theme.of(context).errorColor,
                      icon: const Icon(Icons.delete)),
                  IconButton(
                      onPressed: () {},
                      color: Colors.green,
                      icon: const Icon(Icons.edit))
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
