// ignore_for_file: use_build_context_synchronously

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';

class FilterModalWidget extends StatefulWidget {
  CompanyDetailsPage companyDetailsPage;
  TextEditingController searchWord;
  FilterModalWidget(
      {super.key, required this.companyDetailsPage, required this.searchWord});

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  List<Map<String, dynamic>> ids = [
    {'id': 0, 'name': 'TODAS'},
    {'id': 1, 'name': 'PERSONAS JURIDICAS'},
    {'id': 2, 'name': 'PERSONAS FISICAS'}
  ];

  List<Map<String, dynamic>> visiblesIds = [
    {'id': 0, 'name': 'TODAS'},
    {'id': 1, 'name': 'AUTORIZADAS'},
    {'id': 2, 'name': 'NO AUTORIZADAS'}
  ];

  bool get is606 {
    return widget.companyDetailsPage.formType == FormType.form606;
  }

  bool get is607 {
    return widget.companyDetailsPage.formType == FormType.form607;
  }

  String get filterStatus {
    String filterStrings = '';

    String st = '';

    if (widget.companyDetailsPage.currentIdValue == 0) {
      if (is606) {
        filterStrings = ''' length("invoice_rnc") > 0 ''';
      }
      if (is607) {
        filterStrings = ''' "idType" > 0 ''';
      }
    }

    if (widget.companyDetailsPage.currentIdValue == 1) {
      if (is606) {
        filterStrings = ''' length("invoice_rnc") = '9' ''';
      }
      if (is607) {
        filterStrings = ''' "idType" = 1 ''';
      }
    }
    if (widget.companyDetailsPage.currentIdValue == 2) {
      if (is606) {
        filterStrings = ''' length("invoice_rnc") = '11' ''';
      }
      if (is607) {
        filterStrings = ''' "idType" = 2 ''';
      }
    }
    if (widget.companyDetailsPage.currentVisibleId == 0) {
      if (is606) {
        st = 'and';
      }
      if (is607) {
        st = 'and';
      }
    }

    if (widget.companyDetailsPage.currentVisibleId == 1) {
      if (is606) {
        st = '''and authorized = true and''';
      }
    }

    if (widget.companyDetailsPage.currentVisibleId == 2) {
      if (is606) {
        st = '''and authorized = false and''';
      }
    }

    return '$filterStrings $st';
  }

  filterPurchases() async {
    try {
      var res = await Purchase.get(
          companyId: widget.companyDetailsPage.company.id!,
          startDate: widget.companyDetailsPage.startDate,
          endDate: widget.companyDetailsPage.endDate,
          searchMode: true,
          searchWord: widget.searchWord.text,
          filterParams: filterStatus);
      var c = Get.find<PurchasesController>();
      c.purchases.value = res;
      Get.back();
      Get.back(result: {'filterStatus': filterStatus});
    } catch (e) {
      rethrow;
    }
  }

  filterSales() async {
    try {
      var res = await Sale.get(
          companyId: widget.companyDetailsPage.company.id!,
          startDate: widget.companyDetailsPage.startDate,
          endDate: widget.companyDetailsPage.endDate,
          searchMode: true,
          searchWord: widget.searchWord.text,
          filterParams: filterStatus);
      var c = Get.find<SalesController>();
      c.sales.value = res;
      Get.back();
      Get.back(result: {'filterStatus': filterStatus});
    } catch (e) {
      rethrow;
    }
  }

  filterNow() async {
    showLoader(context);
    try {
      if (is606) {
        await filterPurchases();
      }
      if (is607) {
        await filterSales();
      }
    } catch (e) {
      Get.back();
      showAlert(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Dialog(
                child: SizedBox(
          width: 350,
          child: Form(
              child: ListView(
            padding: EdgeInsets.all(kDefaultPadding),
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  Text(
                    'Filtros',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              SizedBox(height: kDefaultPadding / 2),
              DropdownButtonFormField(
                  value: widget.companyDetailsPage.currentIdValue,
                  decoration: const InputDecoration(
                      labelText: 'TIPO DE IDENTIDAD FISCAL'),
                  items: ids
                      .map((e) => DropdownMenuItem(
                          value: e['id'] as int, child: Text(e['name'])))
                      .toList(),
                  onChanged: (value) {
                    widget.companyDetailsPage.currentIdValue = value!;
                  }),
              SizedBox(height: kDefaultPadding),
              widget.companyDetailsPage.formType == FormType.form606
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField(
                            value: widget.companyDetailsPage.currentVisibleId,
                            decoration: const InputDecoration(
                                labelText: 'ESTATUS DE FACTURA'),
                            items: visiblesIds
                                .map((e) => DropdownMenuItem(
                                    value: e['id'] as int,
                                    child: Text(e['name'])))
                                .toList(),
                            onChanged: (value) {
                              widget.companyDetailsPage.currentVisibleId =
                                  value!;
                            }),
                        SizedBox(height: kDefaultPadding),
                      ],
                    )
                  : const SizedBox(),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                    onPressed: filterNow, child: const Text('FILTRAR')),
              )
            ],
          )),
        ))));
  }
}
