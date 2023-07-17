// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/controllers/session.controller.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/companies_page.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/edit-password-widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        var controller = Get.find<SessionController>();
        var user = await User.signIn(username.text, password.text);
        controller.currentUser = Rx(user);
        await SessionManager().set('USER', user?.toJson());
        Get.offAll(() => CompaniesPage());
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                          )
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text('ACCEDER',
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor)),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: username,
                          style: const TextStyle(fontSize: 18),
                          validator: (val) =>
                              val!.isEmpty ? 'EL USUARIO ES REQUERIDO' : null,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'USUARIO'),
                        ),
                        const SizedBox(height: 20),
                        EditPasswordWidget(
                          controller: password,
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
            )));
  }
}
