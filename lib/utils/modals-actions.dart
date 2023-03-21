import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

Future<T> showAlert<T>(BuildContext context,
    {String message = '', String? title}) async {
  return await showDialog(
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
    {String title = 'Confirmacion...'}) async {
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
      builder: (ctx) => AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            content: SizedBox(
                width: 450,
                child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(children: [
                            Text(title.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Theme.of(context).primaryColor)),
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
                            validator: (val) => int.tryParse(val!) != number
                                ? 'El numero digitado no es correcto'
                                : null,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: number
                                    .toString()
                                    .characters
                                    .map((e) => '#')
                                    .toList()
                                    .join()),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                  style:
                                      ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .error)),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text('CERRAR'))),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: ok,
                                  child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text('CONFIRMAR')))
                            ],
                          )
                        ],
                      ),
                    ))),
          ));

  return result == true;
}
