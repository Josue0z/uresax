import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:uresaxapp/apis/connection.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/utils/extra.dart';

final GlobalKey<ScaffoldState> bookDetailsScaffoldKey =
    GlobalKey<ScaffoldState>();

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

String buildReportTitle(int start, int end, Book book) {
  var a = months[start];
  var b = months[end];
  var c = '${book.companyName}';
  String t = '$c $a ${book.year}';
  if (a == b) return t;
  t = '$a - $b ${book.year}';
  return '$c $t';
}

pw.Page buildReportViewModel(ReportViewModel reportViewModel) {
  dhead() {
    return pw.TableRow(
        children: reportViewModel.body[0]!.keys.map((key) {
      return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  key,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0x0000000),
                  ),
                ),
              ]));
    }).toList());
  }

  drows() {
    return reportViewModel.body.map((item) {
      var index = reportViewModel.body.indexOf(item);

      return pw.TableRow(
         verticalAlignment: pw.TableCellVerticalAlignment.middle,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
                top: pw.BorderSide(
                    color: PdfColor.fromInt(0xA8A8A8), width: 0.3)),
          ),
          children: item!.entries.map((entry) {
            var j = item.values.toList().indexOf(entry.value);

            bool isTotal = j == 0 && index == reportViewModel.body.length - 1;

            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text(entry.value ?? '\$0.00',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: isTotal ? pw.FontWeight.bold : null)),
                  
                ])
            );
          }).toList());
    }).toList();
  }

  return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.only(top: 25, left: 15, right: 15),
      build: (pw.Context context) {
        return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
                reportViewModel.title,
                style: const pw.TextStyle(fontSize: 13)),
            pw.SizedBox(height: 20),
            pw.Table(
              columnWidths: {
              0:const pw.IntrinsicColumnWidth(),
              1:const pw.FixedColumnWidth(110),
              2:const pw.FixedColumnWidth(110),
              3:const pw.FixedColumnWidth(110),
              4:const pw.FixedColumnWidth(110),
              5:const pw.FixedColumnWidth(110),
              6:const pw.FixedColumnWidth(110)
              },
              children: [
                dhead(),
                ...drows(),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.RichText(
                text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9),
                    children: [
                  pw.TextSpan(
                      text: 'ITBIS FACTURADO EN SERVICIOS: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: reportViewModel.taxServices)
                ])),
            pw.SizedBox(height: 10),
            pw.RichText(
                text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9),
                    children: [
                  pw.TextSpan(
                      text: 'ITBIS FACTURADO EN BIENES: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: reportViewModel.taxGood)
                ])),
             pw.SizedBox(height: 10),
             pw.RichText(
                text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9),
                    children: [
                  pw.TextSpan(
                      text: 'TOTAL DE DOCUMENTOS: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: reportViewModel.totalNcfs)
                ])),
          ],
        ); // Center
      });
}
