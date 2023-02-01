import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

void showAlert(BuildContext context, {String message = '', String? title}) {
  showDialog(
      context: context,
      builder: (ctx) => Dialog(
          child: SizedBox(
              width: 450,
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        title ?? 'Alerta',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).errorColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          message,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).errorColor)),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('ENTENDIDO'))
                        ],
                      )
                    ],
                  ),
                ),
              ))));
}

Future<bool?> showConfirm(BuildContext context,
    {String title = 'Confirmacion...', String body = ''}) async {
  var formKey = GlobalKey<FormState>();
  TextEditingController code = TextEditingController();

  var number = math.Random().nextInt(999999);

  void ok() {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context, true);
    }
  }

  var result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
            shape: ShapeBorder.lerp(Border.all(color: Colors.transparent),
                Border.all(color: Colors.transparent), 0),
            child: SizedBox(
                width: 400,
                child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(children: [
                            Text(title,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor)),
                            const Spacer(),
                          ]),
                          const SizedBox(height: 15),
                          Text('Escribe el siguiente codigo $number',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: code,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (val) => int.parse(val!) != number
                                ? 'El numero digitado no es correcto'
                                : null,
                            style: const TextStyle(fontSize: 18),
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '######'),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.grey)),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('CERRAR')),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: ok, child: const Text('CONFIRMAR'))
                            ],
                          )
                        ],
                      ),
                    ))),
          ));

  return result == true;
}
