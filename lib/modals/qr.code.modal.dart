import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class QrCodeModal extends StatefulWidget {
  const QrCodeModal({super.key});

  @override
  State<QrCodeModal> createState() => _QrCodeModalState();
}

class _QrCodeModalState extends State<QrCodeModal> {
  @override
  Widget build(BuildContext context) {
    return LayoutWithBar(
        child: Dialog(
      child: SizedBox(
          width: 350,
          height: 400,
          child: Padding(
              padding: EdgeInsets.all(kDefaultPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('QR CODE',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500))),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                      child: PrettyQrView.data(
                    data: User.current!.id!,
                  ))
                ],
              ))),
    ));
  }
}
