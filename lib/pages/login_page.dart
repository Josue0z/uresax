// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/companies_page.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  _onSubmit() async {
    try {
      var user = await User.signIn(username.text, password.text);
      await SessionManager().set('USER', user);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (ctx) => const CompaniesPage()),
          (route) => false);
    } catch (e) {
       showAlert(context,message:e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 450,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text('Acceso',
                      style: TextStyle(
                          fontSize: 20, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: username,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: 'USUARIO'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: password,
                    style: const TextStyle(fontSize: 18),
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'CONTRASEÑA',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: _onSubmit,
                        child: const Text('INCIAR SESION')),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
