import 'dart:math' as math;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

Future<T> showAlert<T>(BuildContext context,
    {String message = '', String title = '¡ATENCION!'}) async {
  return await showDialog(
      context: context,
      builder: (ctx) => WindowBorder(
          width: 1,
          color: kWindowBorderColor,
          child: LayoutWithBar(
              child: SelectableRegion(
                  selectionControls: materialTextSelectionControls,
                  child: Dialog(
                      child: SizedBox(
                          width: 450,
                          child: Material(
                            borderRadius:
                                BorderRadius.circular(kDefaultPadding),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
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
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .error)),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('ENTENDIDO'))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )))))));
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
      builder: (ctx) => WindowBorder(
          width: 1,
          color: kWindowBorderColor,
          child: LayoutWithBar(
              child: AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            content: SizedBox(
                width: 400,
                child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(title.toUpperCase(),
                                    style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500)
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColor))),
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
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Theme.of(context).colorScheme.error)),
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
          ))));

  return result == true;
}
