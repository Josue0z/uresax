// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/companies.controller.dart';
import 'package:uresaxapp/controllers/periods.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/controllers/session.controller.dart';
import 'package:uresaxapp/modals/add-company-modal.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/pages/users_page.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class CompaniesPage extends StatelessWidget {
  TextEditingController rnc = TextEditingController();

  bool isError = false;

  String message = '';

  late CompaniesController companiesController;

  BuildContext get context {
    return Get.context!;
  }

  List<Company> get companies {
    return companiesController.companies;
  }

  _deleteCompany(Company company, int index) async {
    try {
      var isConfirm =
          await showConfirm(context, title: 'Eliminar esta empresa?');

      if (isConfirm!) {
        await Company(id: company.id).delete();
        companiesController.companies.removeAt(index);
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _fetchCompaniesByRnc(String? keyWord) async {
    companiesController.isError.value = false;
    try {
      if (keyWord!.isEmpty) {
        companiesController.companies.value = await Company.all();
      } else {
        companiesController.companies.value = await Company.all(
            where:
                ''' company_rnc like '%${keyWord.trim()}%' or company_name like '%${keyWord.trim().toUpperCase()}%' ''');
      }
    } catch (e) {
      companiesController.isError.value = true;
      companiesController.companies.value = [];
      companiesController.message.value = e.toString();
    }
  }

  _viewUsers() {
    Get.to(() => const UsersPage());
  }

  _logout() async {
    try {
      var c = await showConfirm(context, title: '¿CERRAR SESION?');
      if (c != null && c) {
        await User.loggout(context);
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _addTaxPayer() async {
    var company = await showDialog<Company>(
        context: context, builder: (ctx) => const AddCompanyModal());
    if (company != null) {
      companiesController.companies.add(company);
    }
  }

  preload607CompanyDetails(Company company) async {
    try {
      var now = DateTime.now();
      var startDate = now.startOfMonth();
      var endDate = now.endOfMonth();

      var keyOne = await storage.read(key: "STARTDATE_SALES_${company.id}");
      var keyTwo = await storage.read(key: 'ENDDATE_SALES_${company.id}');

      if (keyOne != null && keyTwo != null) {
        startDate = DateTime.parse(keyOne).startOfMonth();
        endDate = DateTime.parse(keyTwo).endOfMonth();
      }

      showLoader(context);

      var c = Get.find<SalesController>();

      c.sales.value = await Sale.get(
          companyId: company.id!, startDate: startDate, endDate: endDate);


      Navigator.pop(context);

      Get.to(() => CompanyDetailsPage(
          company: company,
          startDate: startDate,
          endDate: endDate,
          formType: FormType.form607));
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  preload606CompanyDetails(Company company) async {
    var now = DateTime.now();
    var startDate = now.startOfMonth();
    var endDate = now.endOfMonth();

    var startDateLargeAsString = startDate.format(payload: 'YYYY-MM-DD');
    var endDateLargeAsString = endDate.format(payload: 'YYYY-MM-DD');

    var keyOne = await storage.read(key: "STARTDATE_${company.id}");
    var keyTwo = await storage.read(key: 'ENDDATE_${company.id}');

    if (keyOne != null && keyTwo != null) {
      startDate = DateTime.parse(keyOne).startOfMonth();
      endDate = DateTime.parse(keyTwo).endOfMonth();
      startDateLargeAsString = keyOne;
      endDateLargeAsString = keyTwo;
    }

    showLoader(context);

    var controller = Get.find<PurchasesController>();

    controller.purchases.value = await Purchase.getPurchases(
        id: company.id!,
        startDate: startDate,
        endDate: endDate);

    Navigator.pop(context);

    Get.to(() => CompanyDetailsPage(
        company: company, startDate: startDate, endDate: endDate));
  }

  Widget get _errorWidget {
    return Expanded(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(message,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center),
          const SizedBox(height: 25),
        ],
      ),
    ));
  }

  Widget get _searchWidget {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        controller: rnc,
        onChanged: (rnc) => _fetchCompaniesByRnc(rnc),
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'BUSCAR CONTRIBUYENTES... (RNC/CEDULA,RAZON SOCIAL)',
            hintText: 'BUSCAR...',
            suffixIcon: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.search, size: 28))),
      ),
    );
  }

  Widget get _emptyContainer {
    return Expanded(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.apartment,
              size: 110, color: Theme.of(context).primaryColor)
        ],
      ),
    ));
  }

  Widget get _viewCompanies {
    if (companiesController.isError.value) return _errorWidget;

    if (companies.isEmpty) return _emptyContainer;

    return Expanded(
        child: ListView.separated(
            itemCount: companies.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, index) {
              Company company = companies[index];
              String title =
                  'RNC/CEDULA ${company.rnc} ${company.createdAt?.format(payload: "DD/MM/YYYY")}';
              return ListTile(
                  minVerticalPadding: 15,
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child:
                        const Icon(Icons.store, size: 25, color: Colors.white),
                  ),
                  title: Text(company.name!,
                      style: Theme.of(context).textTheme.headlineSmall),
                  subtitle: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                          onPressed: () => preload607CompanyDetails(company),
                          icon: const Icon(Icons.receipt_outlined),
                          tooltip: 'VENTAS'),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () => preload606CompanyDetails(company),
                          icon: const Icon(Icons.insert_drive_file_rounded),
                          tooltip: 'COMPRAS Y GASTOS'),
                      const SizedBox(width: 10),
                      User.current!.isAdmin
                          ? IconButton(
                              onPressed: () => _deleteCompany(company, index),
                              icon: const Icon(Icons.delete),
                              color: Theme.of(context).colorScheme.error,
                              tooltip: 'ELIMINAR')
                          : const SizedBox(),
                    ],
                  ));
            }));
  }

  @override
  Widget build(BuildContext context) {
    companiesController = Get.find<CompaniesController>();
    var controller = Get.find<SessionController>();
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Obx(() => AppBar(
                elevation: 0,
                title: Text(
                    'CONTRIBUYENTES / ${controller.currentUser?.value?.name?.toUpperCase()}'),
                actions: [
                  ToolButton(
                      onTap: _viewUsers,
                      toolTip: 'VER USUARIOS',
                      icon: const Icon(Icons.people)),
                  ToolButton(
                      onTap: _addTaxPayer,
                      toolTip: 'AÑADIR CONTRIBUYENTE',
                      icon: const Icon(Icons.add)),
                  ToolButton(
                      onTap: _logout,
                      toolTip: 'CERRAR SESION',
                      icon: const Icon(Icons.power_settings_new_outlined)),
                ],
              ))),
      body: Column(children: [_searchWidget, Obx(() => _viewCompanies)]),
    );
  }
}
