import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/widgets/date.selector.widget.dart';

class AddImportModal extends StatefulWidget {
  final CompanyDetailsPage companyDetailsPage;

  const AddImportModal({super.key, required this.companyDetailsPage});

  @override
  State<AddImportModal> createState() => _AddImportModalState();
}

class _AddImportModalState extends State<AddImportModal> {
  TextEditingController controller = TextEditingController();

  TextEditingController controller2 = TextEditingController();

  DateTime? paymentDate;

  DateTime? invoiceDate;

  onSelected(DateTime? date) {
    paymentDate = date;
  }

  onSelectedInvoiceDate(DateTime? date) {
    invoiceDate = date;
  }

  @override
  initState() {
    controller.value = TextEditingValue(
        text:
            widget.companyDetailsPage.startDate.format(payload: 'DD/MM/YYYY'));
    controller2.value = TextEditingValue(
        text:
            widget.companyDetailsPage.startDate.format(payload: 'DD/MM/YYYY'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
          child: SizedBox(
        width: 450,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          children: [
            Row(
              children: [
                Text('AÑADIR IMPORTACION',
                    style: TextStyle(
                        fontSize: 20, color: Theme.of(context).primaryColor)),
                const Spacer(),
                IconButton(
                    onPressed: () => Get.back(), icon: const Icon(Icons.close))
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                  hintText: 'NUMERO DE DECLARACION',
                  labelText: 'NUMERO DE DECLARACION',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            DateSelectorWidget(
                controller: controller,
                onSelected: onSelected,
                hintText: 'FECHA DE PAGO',
                labelText: 'FECHA DE PAGO',
                startDate: widget.companyDetailsPage.startDate,
                date: widget.companyDetailsPage.startDate),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                  hintText: 'NUMERO DE RECIBO',
                  labelText: 'NUMERO DE RECIBO',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                  hintText: 'NUMERO DE FACTURA',
                  labelText: 'NUMERO DE FACTURA',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            DateSelectorWidget(
                controller: controller2,
                onSelected: onSelectedInvoiceDate,
                hintText: 'FECHA DE FACTURA',
                labelText: 'FECHA DE FACTURA',
                startDate: widget.companyDetailsPage.startDate,
                date: widget.companyDetailsPage.startDate),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              inputFormatters: [myformatter],
              decoration: const InputDecoration(
                  hintText: 'ITBIS',
                  labelText: 'ITBIS',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              inputFormatters: [myformatter],
              decoration: const InputDecoration(
                  hintText: 'GRAVAMEN',
                  labelText: 'GRAVAMEN',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              inputFormatters: [myformatter],
              decoration: const InputDecoration(
                  hintText: 'IMPUESTO SELECTIVOS',
                  labelText: 'IMPUESTO SELECTIVOS',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              inputFormatters: [myformatter],
              decoration: const InputDecoration(
                  hintText: 'MULTAS',
                  labelText: 'MULTAS',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              inputFormatters: [myformatter],
              decoration: const InputDecoration(
                  hintText: 'RECARGOS',
                  labelText: 'RECARGOS',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              inputFormatters: [myformatter],
              decoration: const InputDecoration(
                  hintText: 'TASA DE SERVICIO DGA',
                  labelText: 'TASA DE SERVICIO DGA',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              inputFormatters: [myformatter],
              decoration: const InputDecoration(
                  hintText: 'OTROS CONCEPTOS',
                  labelText: 'OTROS CONCEPTOS',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontSize: 18),
              inputFormatters: [myformatter],
              decoration: const InputDecoration(
                  hintText: 'TOTAL',
                  labelText: 'TOTAL',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            SizedBox(
                width: double.maxFinite,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {}, child: Text('AÑADIR IMPORTACION')))
          ],
        ),
      )),
    );
  }
}
