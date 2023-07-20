import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/modals/add.import.modal.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class ImportsPage extends StatefulWidget {
  final CompanyDetailsPage companyDetailsPage;

  const ImportsPage({super.key, required this.companyDetailsPage});

  @override
  State<ImportsPage> createState() => _ImportsPageState();
}

class _ImportsPageState extends State<ImportsPage> {
  ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> list = [
    {
      'NUMERO DE DECLARACION': '10030-IC01-2304-002C2F',
      'FECHA DE PAGO': '4/28/2023 12:00:00 AM',
      'NUMERO DE RECIBO': '20230428-0980',
      'NUMERO DE FACTURA': '10030-CL11-2304-00291D',
      'FECHA DE FACTURA': '4/20/2023 12:00:00 AM',
      'CIF': '559627.63',
      'ITBIS': '59627.63',
      'GRAVAMEN': '30114.97',
      'IMPUESTOS SELECTIVOS': '0.00',
      'MULTAS': '0.00',
      'RECARGOS': '0.00',
      'TASA DE SERVICIO DGA': '5473.06',
      'OTROS CONCEPTO': '200',
      'TOTAL': '95415.66'
    }
  ];

  double colWidth = 255;

  double colHeight = 85;

  List<String> get cols {
    return list.first.keys.toList();
  }

  showModalOfImports() async {
    await showDialog(
        context: context,
        builder: (ctx) =>
            AddImportModal(companyDetailsPage: widget.companyDetailsPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
            'IMPORTACIONES DE ${widget.companyDetailsPage.company.name?.toUpperCase()}'),
        actions: [
          ToolButton(
              toolTip: 'CARGAR ARCHIVO DE IMPORTACIONES (XLSX)',
              icon: const Icon(Icons.download)),
          ToolButton(
              onTap: () => Get.back(),
              toolTip:
                  'CERRAR LISTA DE IMPORTACIONES DE ${widget.companyDetailsPage.company.name?.toUpperCase()}',
              icon: const Icon(Icons.close)),
        ],
      ),
      body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Container(
                          height: colHeight,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black12))),
                          alignment: Alignment.center,
                          child: Row(
                            children: List.generate(cols.length, (index) {
                              var item = cols[index];
                              return Container(
                                width: colWidth,
                                padding: const EdgeInsets.all(10),
                                child: Text(item,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 18)),
                              );
                            }),
                          )),
                      Container(
                          color: const Color(0x1FC2C1C1),
                          height: MediaQuery.of(context).size.height -
                              kToolbarHeight -
                              colHeight,
                          child: SingleChildScrollView(
                              child: Column(
                            children: List.generate(list.length, (index) {
                              var item = list[index];
                              var values = item.values.toList();
                              return Container(
                                height: 70,
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.black12))),
                                child: Row(
                                    children:
                                        List.generate(values.length, (index) {
                                  return Container(
                                    width: colWidth,
                                    padding: const EdgeInsets.all(10),
                                    child: Text(values[index],
                                        style: const TextStyle(fontSize: 18)),
                                  );
                                })),
                              );
                            }),
                          )))
                    ],
                  )))),
      floatingActionButton: FloatingActionButton(
        onPressed: showModalOfImports,
        child: const Icon(Icons.add),
      ),
    );
  }
}
