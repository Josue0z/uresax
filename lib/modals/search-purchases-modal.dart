// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';

class SearchPurchases extends StatefulWidget {
  CompanyDetailsPage widget;

  SearchPurchases({super.key, required this.widget});

  @override
  State<SearchPurchases> createState() => _SearchPurchasesState();
}

class _SearchPurchasesState extends State<SearchPurchases> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController rnc = TextEditingController();

  TextEditingController ncf = TextEditingController();

  TextEditingController total = TextEditingController();

  TextEditingController tax = TextEditingController();

  onSubmit() async {
    if (_formKey.currentState!.validate()) {
      showLoader(context);
      try {
        var purchases = await Purchase.getPurchases(
          searchMode: true,
          id: widget.widget.company.id!,
          startDate: widget.widget.startDate,
          endDate: widget.widget.endDate,
        );
        Navigator.pop(context);
        Navigator.pop(context, purchases);
      } catch (e) {
        Navigator.pop(context);
        Navigator.pop(context, []);
        showAlert(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: SizedBox(
            width: 350,
            child: ListView(
              padding: const EdgeInsets.all(15),
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    Text('BUSCADOR...',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Theme.of(context).primaryColor)),
                    const Spacer(),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: rnc,
                  validator: (val) => val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                  decoration: const InputDecoration(
                      labelText: 'RNC/CEDULA',
                      hintText: 'RNC/CEDULA',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: ncf,
                  validator: (val) => val!.isEmpty ? 'CAMPO REQUERIDO' : null,
                  decoration: const InputDecoration(
                      labelText: 'NCF',
                      hintText: 'NCF',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: total,
                  inputFormatters: [myformatter],
                  decoration: const InputDecoration(
                      labelText: 'TOTAL NETO O GENERAL',
                      hintText: 'TOTAL NETO O GENERAL',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: tax,
                  inputFormatters: [myformatter],
                  decoration: const InputDecoration(
                      labelText: 'ITBIS FACTURADO',
                      hintText: 'ITBIS FACTURADO',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: onSubmit,
                      child: const Text('BUSCAR FACTURAS')),
                )
              ],
            ),
          )),
    );
  }
}
