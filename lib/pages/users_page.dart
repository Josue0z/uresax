import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USUARIOS'),
      ),
      body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (ctx, index) {
            var user = users[index];
            return ListTile(
              leading: Icon(Icons.account_circle_outlined,
                  size: 50, color: Theme.of(context).primaryColor),
              minVerticalPadding: 15,
              title: Text(
                user.name!,
                style: const TextStyle(fontSize: 24),
              ),
              subtitle: Text('${user.roleName} - ${user.username}'),
              trailing: Wrap(
                children: [
                  IconButton(
                      onPressed: () {},
                      color: Theme.of(context).errorColor,
                      icon: const Icon(Icons.delete))
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
