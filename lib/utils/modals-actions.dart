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
