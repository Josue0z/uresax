// ignore_for_file: use_build_context_synchronously
/*
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
*/
/*class PdfViewerForPrinters extends StatefulWidget {
  Uint8List bytes;

  PdfViewerForPrinters({super.key, required this.bytes});

  @override
  State<PdfViewerForPrinters> createState() => _PdfViewerForPrintersState();
}

class _PdfViewerForPrintersState extends State<PdfViewerForPrinters> {
  PdfViewerController pdfViewerController = PdfViewerController();

  Future<void> printPdf() async {
    try {
      var result = await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) => widget.bytes);

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('COMENZO LA IMPRESION')));
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('IMPRIMIENDO...'),
          actions: [
            IconButton(onPressed: printPdf, icon: const Icon(Icons.print))
          ],
        ),
        body: SfPdfViewer.memory(
          widget.bytes,
          controller: pdfViewerController,
          onDocumentLoadFailed: (err) {
            print(err);
          },
        ));
  }
}
*/