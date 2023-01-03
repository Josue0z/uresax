import 'dart:io';

import 'package:uresaxapp/apis/http-client.dart';

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

  Future<void> launchFile(String path) async {
 
      ProcessResult result = await 
        Process.run('cmd', ['/c', 'start', '', path]);
      if (result.exitCode == 0) {
        // good
      } 
      else {
        // bad
      }
   
 }