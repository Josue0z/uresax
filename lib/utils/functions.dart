import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uresaxapp/apis/connection.dart';

final  GlobalKey<ScaffoldState> bookDetailsScaffoldKey = GlobalKey<ScaffoldState>();

Future<dynamic> verifyTaxPayer(String rnc) async {
  var results = await connection.mappedResultsQuery(
      '''select * from public."TaxPayer" where "tax_payerId" = '$rnc';''');

  if (results.isEmpty) {
    return 'not exists';
  }
  var taxPayer = results.first['TaxPayer'] ?? {};
  if (taxPayer['tax_payerId'] == rnc) {
    return {
      'exists': true,
      'tax_payer_company_name': taxPayer['tax_payer_company_name']
    };
  }
  return {};
}



Future<void> launchFile(String path) async {
  ProcessResult result = await Process.run('cmd', ['/c', 'start', '', path]);
  if (result.exitCode == 0) {
    // good
  } else {
    // bad
  }
}

showLoader(BuildContext context) async {
  showDialog(
      context: context,
      builder: (ctx) {
        return WillPopScope(
            child: Dialog(
                insetAnimationDuration: const Duration(milliseconds: 5),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [CircularProgressIndicator()],
                    ),
                  ),
                )),
            onWillPop: () async {
              return false;
            });
      });
}
