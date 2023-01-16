import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uresaxapp/apis/http-client.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sheet.dart';

Future<Map<String, dynamic>> verifyTaxPayer(String rnc) async {
  try {
    var response = await httpClient.get('/verify-taxpayer?tax_payer_rnc=$rnc');
    return response.data;
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> calcData({String? sheetId, String? bookId}) async {
  try {
    var where = '';
    if (sheetId != null && bookId != null) {
      where = '?sheetId=$sheetId&bookId=$bookId';
    } else {
      if (sheetId != null) {
        where = '?sheetId=$sheetId';
      }
      if (bookId != null) {
        where = '?bookId=$bookId';
      }
    }
    var response = await httpClient.get('/calcdata$where');
    return response.data;
  } catch (e) {
    rethrow;
  }
}

Future<List> fecthPurchases(String sheetId) async {
  try {
    return await Purchase.getPurchases(sheetId: sheetId);
  } catch (e) {
    rethrow;
  }
}

Future fetchDataBook({String? bookId, String? sheetId}) async {
  try {
    var data = await Future.wait([
      fetchSheets(bookId??''),
      fecthPurchases(sheetId??''),
      calcData(sheetId: sheetId)
    ]);
    return {'sheets': data[0], 'invoices': data[1], 'invoicesLogs': data[2]};
  } catch (e) {
    return {'sheets': [], 'invoices': [], 'invoicesLogs': {}};
  }
}

Future<List<Sheet>> fetchSheets(String bookId) async {
  try {
    return await Sheet.getSheetsByBookId(bookId: bookId);
  } catch (e) {
    return [];
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

showLoader(BuildContext context) async {
  showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
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
        ));
      });
 
}
