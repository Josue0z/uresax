// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

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
    } else {
      results = await connection.mappedResultsQuery(
          '''select * from public."Providers" where id = '$rnc';''');

      var taxPayer = results.first['Providers'] ?? {};
      if (taxPayer['id'] == rnc) {
        return {'exists': true, 'tax_payer_company_name': taxPayer['name']};
      }
    }
    throw 'NOT EXISTS';
  } catch (e) {
    rethrow;
  }
}

Future<void> launchFile(String path) async {
  ProcessResult result = await Process.run('cmd', ['/c', 'start', '', path]);
  if (result.exitCode == 0) {
    // good
  } else {
    // bad
  }
}

Future<void> showLoader(BuildContext context) async {
  showDialog(
      context: context,
      builder: (ctx) {
        return WillPopScope(
            child: const Dialog(
                insetAnimationDuration:  Duration(milliseconds: 0),
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
            });
      });
}

