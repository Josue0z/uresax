// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/controllers/companies.controller.dart';
import 'package:uresaxapp/controllers/session.controller.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/companies_page.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/edit-password-widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

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
        var com = Get.find<CompaniesController>();
        await com.onInitCustom(runContact: true);
        Get.offAll(() => const CompaniesPage(),
            transition: Transition.downToUp);
      } catch (e) {
        showAlert(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Scaffold(
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
                            padding: EdgeInsets.all(kDefaultPadding),
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
                                        fontSize: kxDefaultFontSize,
                                        color: Theme.of(context).primaryColor)),
                                SizedBox(height: kDefaultPadding),
                                TextFormField(
                                  controller: username,
                                  style: TextStyle(fontSize: kxDefaultFontSize),
                                  validator: (val) => val!.isEmpty
                                      ? 'EL USUARIO ES REQUERIDO'
                                      : null,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'USUARIO'),
                                ),
                                SizedBox(height: kxDefaultFontSize),
                                EditPasswordWidget(
                                  controller: password,
                                  onFieldSubmitted: (_) => _onSubmit(),
                                ),
                                SizedBox(height: kDefaultPadding),
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
                    )))));
  }
}
