// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/controllers/ncfs.override.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/ncf.override.model.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';

class CompanySelectorWidget extends StatefulWidget {
  final dynamic item;

  final Company company;

  final DateTime startDate;

  final DateTime endDate;

  const CompanySelectorWidget(
      {super.key,
      required this.item,
      required this.company,
      required this.startDate,
      required this.endDate});

  @override
  State<CompanySelectorWidget> createState() => _CompanySelectorWidgetState();
}

class _CompanySelectorWidgetState extends State<CompanySelectorWidget> {
  List<Company> oldCompanies = [];
  List<Company> companies = [];

  Company? currentCompany;

  int currentIndex = -1;

  bool confirm = false;

  TextEditingController words = TextEditingController();

  _onSelected(Company company, int index) {
    try {
      setState(() {
        currentIndex = index;
        confirm = true;
        currentCompany = company;
      });
    } catch (e) {
      print(e);
    }
  }

  _onSearch(String words) async {
    try {
      var results = await Company.get(
          where:
              ''' "company_name" like '%$words%' or "company_rnc" like '%$words%' ''');
      companies = results;

      if (words == '') {
        setState(() {
          currentIndex = -1;
          currentCompany = null;
          confirm = false;
        });
        return;
      }

      currentIndex = companies
          .indexWhere((e) => e.name!.contains(words) || e.rnc!.contains(words));
      currentCompany = companies[currentIndex];
      confirm = true;
      setState(() {});
    } catch (e) {
      setState(() {
        currentIndex = -1;
        currentCompany = null;
        confirm = false;
      });
    }
  }

  _restore() {
    setState(() {
      confirm = false;
      currentIndex = -1;
      currentCompany = null;
      words.clear();
      companies = oldCompanies;
    });
  }

  _confirm() async {
    try {
      if (currentCompany != null) {
        await widget.item.move(currentCompany!.id!);

        if (widget.item is Purchase) {
          var cont = Get.find<PurchasesController>();
          var elements = await Purchase.get(
              companyId: widget.company.id!,
              startDate: widget.startDate,
              endDate: widget.endDate);
          cont.purchases.value = elements;
        }
        if (widget.item is Sale) {
          var cont = Get.find<SalesController>();
          var elements = await Sale.get(
              companyId: widget.company.id!,
              startDate: widget.startDate,
              endDate: widget.endDate);
          cont.sales.value = elements;
        }

        if (widget.item is NcfOverrideModel) {
          var cont = Get.find<NcfsOverrideController>();
          var elements = await NcfOverrideModel.get(
              companyId: widget.company.id!,
              startDate: widget.startDate,
              endDate: widget.endDate);
          cont.ncfsOverrides.value = elements;
        }

        Get.back(result: true);
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  @override
  void initState() {
    Company.get().then((value) {
      setState(() {
        companies = value;
        oldCompanies = value;
      });
    }).catchError(print);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      width: 1,
      color: kWindowBorderColor,
      child: Column(
        children: [
          const CustomFrameWidgetDesktop(),
          Expanded(
              child: Dialog(
            child: SizedBox(
                width: 370,
                height: 500,
                child: Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: kDefaultPadding / 2,
                            horizontal: kDefaultPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('SELECCIONA TU COMPAÑIA',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: kxDefaultFontSize * 0.9,
                                    fontWeight: FontWeight.w500)),
                            IconButton(
                                onPressed: _restore,
                                icon: const Icon(Icons.restore),
                                color: Theme.of(context).primaryColor),
                            IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.close))
                          ],
                        )),
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: kDefaultPadding),
                        child: TextFormField(
                          controller: words,
                          onChanged: _onSearch,
                          onFieldSubmitted: (_) => _confirm(),
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: const InputDecoration(
                              hintText: 'BUSCANDO...', labelText: 'BUSCAR...'),
                        )),
                    Expanded(
                        child: ListView.separated(
                            separatorBuilder: (ctx, index) => const Divider(),
                            itemCount: companies.length,
                            itemBuilder: (ctx, index) {
                              var company = companies[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: kDefaultPadding),
                                onTap: () => _onSelected(company, index),
                                selected: currentIndex == index,
                                title: Text(company.name!),
                              );
                            })),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                            vertical: kDefaultPadding / 2),
                        decoration: const BoxDecoration(
                            border:
                                Border(top: BorderSide(color: Colors.black26))),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: confirm ? _confirm : null,
                              child: const Text('OK')),
                        ))
                  ],
                )),
          ))
        ],
      ),
    );
  }
}
