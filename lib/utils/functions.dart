// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';

const storage = FlutterSecureStorage(
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.unlocked));

var getstorage = GetStorage();

final GlobalKey<ScaffoldState> bookDetailsScaffoldKey =
    GlobalKey<ScaffoldState>();

Future<dynamic> verifyTaxPayer(String rnc) async {
  try {
    var results = await connection.mappedResultsQuery(
        '''select * from public."TaxPayer" where "tax_payerId" = '$rnc';''');

    if (results.isNotEmpty) {
      var taxPayer = results.first['TaxPayer'] ?? {};
      if (taxPayer['tax_payerId'] == rnc) {
        return {
          'exists': true,
          'tax_payer_company_name': taxPayer['tax_payer_company_name']
        };
      }
    }
    throw 'NOT EXISTS';
  } catch (e) {
    rethrow;
  }
}

Future<void> launchFile(String path) async {
  ProcessResult? result;


  if (Platform.isMacOS) {
    result = await Process.run('open', [path]);
  }

  if (Platform.isWindows) {
    result = await Process.run('cmd', ['/c', 'start', '', path]);
  }
  if (result?.exitCode == 0) {
  } else {}
}

Future<void> showLoader(BuildContext context) async {
  showDialog(
      context: context,
      builder: (ctx) {
        return WindowBorder(
          width: 1,
          color: kWindowBorderColor,
          child: Column(
            children: [
              const CustomFrameWidgetDesktop(),
              Expanded(
                  child: WillPopScope(
                      child: const Dialog(
                          insetAnimationDuration: Duration(milliseconds: 0),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [CircularProgressIndicator()],
                              ),
                            ),
                          )),
                      onWillPop: () async {
                        return false;
                      }))
            ],
          ),
        );
      });
}
