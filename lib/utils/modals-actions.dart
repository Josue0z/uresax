import 'package:flutter/material.dart';

void showAlert(BuildContext context, {String message = '', String? title}) {
  showDialog(
      context: context,
      builder: (ctx) => Dialog(
          child: SizedBox(
              width: 150,
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        title ?? 'Notificacion',
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
    {String title = 'CONFIRMAR ACCION', String body = ''}) async {
  return await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
            child: SizedBox(
                width: 350,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Row(children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor)),
                        const Spacer(),
                      ]),
                      const SizedBox(height: 15),
                      Text(body, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Spacer(),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.grey)),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('CERRAR')),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('CONFIRMAR'))
                        ],
                      )
                    ],
                  ),
                )),
          ));
}
