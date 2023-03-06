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
      return pw.Column(
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
          ]);
    }).toList());
  }

  drows() {
    return reportViewModel.body.map((item) {
      return pw.TableRow(
          children: item!.entries.map((entry) {
        return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10),
                child: pw.Text(entry.value ?? '\$0.00',
                    style: const pw.TextStyle(fontSize: 8)),
              )
            ]);
      }).toList());
    }).toList();
  }

  return pw.Page(build: (pw.Context context) {
    return pw.Center(
        child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
            buildReportTitle(reportViewModel.start!, reportViewModel.end!,
                reportViewModel.book!),
            style: const pw.TextStyle(fontSize: 13)),
        pw.SizedBox(height: 20),
        pw.Table(
          columnWidths: {
            0: const pw.IntrinsicColumnWidth(),
            1: const pw.FixedColumnWidth(100),
            2: const pw.FixedColumnWidth(100),
            3: const pw.FixedColumnWidth(100),
            4: const pw.FixedColumnWidth(100),
            5: const pw.FixedColumnWidth(100)
          },
          children: [
            dhead(),
            ...drows(),
            pw.TableRow(
                children: reportViewModel.values
                    .map((e) => pw.Container(
                        padding: const pw.EdgeInsets.only(top: 10),
                        child: pw.Text(e ?? '\$0.00',
                            style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight:
                                    reportViewModel.values.indexOf(e) == 0
                                        ? pw.FontWeight.bold
                                        : null))))
                    .toList())
          ],
        ),
        pw.SizedBox(height: 20),
        pw.RichText(
            text:
                pw.TextSpan(style: const pw.TextStyle(fontSize: 9), children: [
          pw.TextSpan(
              text: 'ITBIS FACTURADO EN SERVICIOS: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: reportViewModel.taxServices)
        ])),
        pw.SizedBox(height: 10),
        pw.RichText(
            text:
                pw.TextSpan(style: const pw.TextStyle(fontSize: 9), children: [
          pw.TextSpan(
              text: 'ITBIS FACTURADO EN BIENES: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: reportViewModel.taxGood)
        ])),
        pw.SizedBox(height: 10),
        pw.RichText(
            text:
                pw.TextSpan(style: const pw.TextStyle(fontSize: 9), children: [
          pw.TextSpan(
              text: 'TOTAL ITBIS FACTURADO: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: reportViewModel.totalTax)
        ])),
        pw.SizedBox(height: 10),
        pw.RichText(
            text:
                pw.TextSpan(style: const pw.TextStyle(fontSize: 9), children: [
          pw.TextSpan(
              text: 'TOTAL FACTURADO: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.TextSpan(text: reportViewModel.totalGeneral)
        ])),
      ],
    )); // Center
  });
}
