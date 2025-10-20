// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/companies.controller.dart';
import 'package:uresaxapp/controllers/ncfs.override.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/controllers/session.controller.dart';
import 'package:uresaxapp/modals/add-company-modal.dart';
import 'package:uresaxapp/modals/add.note.modal.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/concept.dart';
import 'package:uresaxapp/models/invoicetype.dart';
import 'package:uresaxapp/models/ncf.override.model.dart';
import 'package:uresaxapp/models/ncftype.dart';
import 'package:uresaxapp/models/payment-method.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/retention.dart';
import 'package:uresaxapp/models/retention.tax.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/pages/users_page.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  TextEditingController rnc = TextEditingController();

  late CompaniesController companiesController;

  @override
  BuildContext get context {
    return Get.context!;
  }

  late SessionController sessionController;

  final ScrollController _scrollController = ScrollController();

  double _offsetY = 0;
  final double _maxOffsetY = 20;
  double _percent = 0;

  @override
  initState() {
    _scrollController.addListener(() {
      setState(() {
        _offsetY = _scrollController.offset;
        _percent = (_offsetY / _maxOffsetY);
      });
    });
    super.initState();
  }

  List<Company> get companies {
    return companiesController.companies;
  }

  List<Map<String, dynamic>> forms = [
    {'id': 1, 'name': 'FORMULARIO 606 (COMPRAS Y GASTOS)'},
    {'id': 2, 'name': 'FORMULARIO 607 (VENTAS)'},
    {'id': 3, 'name': 'FORMULARIO 608 (NCFS ANULADOS)'},
    {'id': 4, 'name': 'VER DATOS'}
  ];

  _deleteCompany(Company company, int index) async {
    try {
      var isConfirm =
          await showConfirm(context, title: '¿Eliminar esta empresa?');

      if (isConfirm!) {
        await Company(id: company.id).delete();
        companiesController.companies.value = await Company.get();
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _fetchCompaniesByRnc(String? keyWord) async {
    companiesController.isLoading.value = true;
    companiesController.isError.value = false;
    try {
      if (keyWord!.isEmpty) {
        companiesController.companies.value = await Company.get();
      } else {
        companiesController.companies.value = await Company.get(
            where:
                ''' company_rnc like '%${keyWord.trim()}%' or company_name like '%${keyWord.trim().toUpperCase()}%' ''');
      }
      companiesController.isLoading.value = false;
    } catch (e) {
      companiesController.isLoading.value = false;
      companiesController.isError.value = true;
      companiesController.companies.value = [];
      companiesController.message.value = e.toString();
    } finally {
      setState(() {
        _percent = 0;
      });
    }
  }

  _viewUsers() async {
    showLoader(context);
    try {
      var users = await User.all();
      await Get.to(() => UsersPage(users: users),
          transition: Transition.fadeIn);
      setState(() {});
      Get.back();
    } catch (e) {
      Get.back();
      showLoader(context);
    }
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
    showLoader(context);

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

      var c = Get.find<SalesController>();

      c.sales.value = await Sale.get(
          companyId: company.id!, startDate: startDate, endDate: endDate);

      Navigator.pop(context);

      Get.to(
          () => CompanyDetailsPage(
              company: company,
              startDate: startDate,
              endDate: endDate,
              formType: FormType.form607),
          transition: Transition.fadeIn);
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  preload606CompanyDetails(Company company) async {
    showLoader(context);
    try {
      var now = DateTime.now();
      var startDate = now.startOfMonth();
      var endDate = now.endOfMonth();
      var keyOne = await storage.read(key: "STARTDATE_${company.id}");
      var keyTwo = await storage.read(key: 'ENDDATE_${company.id}');

      if (keyOne != null && keyTwo != null) {
        startDate = DateTime.parse(keyOne).startOfMonth();
        endDate = DateTime.parse(keyTwo).endOfMonth();
      }

      var controller = Get.find<PurchasesController>();

      controller.purchases.value = await Purchase.get(
          companyId: company.id!, startDate: startDate, endDate: endDate);

      var results = await Future.wait([
        Concept.getConcepts(),
        InvoiceType.getInvoiceTypes(),
        PaymentMethod.getPaymentMethods(),
        Retention.all(),
        NcfType.getNcfs(),
        RetentionTax.all()
      ]);

      var concepts = [Concept(name: 'CONCEPTO'), ...results[0]].cast<Concept>();

      var invoiceTypes = [InvoiceType(name: 'TIPO DE FACTURA'), ...results[1]]
          .cast<InvoiceType>();

      var paymentMethods = [
        PaymentMethod(name: 'METODO DE PAGO'),
        ...results[2]
      ].cast<PaymentMethod>();

      var retentions =
          [Retention(name: 'RETENCION ISR'), ...results[3]].cast<Retention>();

      var ncfs =
          [NcfType(name: 'TIPO DE COMPROBANTE'), ...results[4]].cast<NcfType>();

      var retentionTaxes = [
        RetentionTax(name: 'RETENCION DE ITBIS'),
        ...results[5]
      ].cast<RetentionTax>();

      var metadata = {
        'concepts': concepts,
        'invoiceTypes': invoiceTypes,
        'paymentMethods': paymentMethods,
        'retentions': retentions,
        'retentionTaxes': retentionTaxes,
        'ncfs': ncfs
      };

      Navigator.pop(context);

      Get.to(
          () => CompanyDetailsPage(
              company: company,
              startDate: startDate,
              endDate: endDate,
              metadata: metadata),
          transition: Transition.fadeIn);
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  preload608CompanyDetails(Company company) async {
    showLoader(context);
    try {
      var now = DateTime.now();
      var startDate = now.startOfMonth();
      var endDate = now.endOfMonth();
      var keyOne = await storage.read(key: "STARTDATE_ANULADOS_${company.id}");
      var keyTwo = await storage.read(key: 'ENDDATE_ANULADOS_${company.id}');

      if (keyOne != null && keyTwo != null) {
        startDate = DateTime.parse(keyOne).startOfMonth();
        endDate = DateTime.parse(keyTwo).endOfMonth();
      }

      var controller = Get.find<NcfsOverrideController>();

      controller.ncfsOverrides.value = await NcfOverrideModel.get(
          companyId: company.id!, startDate: startDate, endDate: endDate);

      Navigator.pop(context);

      Get.to(
          () => CompanyDetailsPage(
                company: company,
                startDate: startDate,
                endDate: endDate,
                formType: FormType.form608,
              ),
          transition: Transition.fadeIn);
    } catch (e) {
      Navigator.pop(context);
      showAlert(context, message: e.toString());
    }
  }

  Widget get _errorWidget {
    return Expanded(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.warning,
              size: 125, color: Theme.of(context).colorScheme.error),
          Text(companiesController.message.value,
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center),
          const SizedBox(height: 25),
        ],
      ),
    ));
  }

  Widget get _searchWidget {
    return Container(
        height: 75,
        padding: EdgeInsets.only(top: kDefaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Expanded(
                flex: 2,
                child: Text(countTaxPayers,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor)))),
            Expanded(
                child: TextFormField(
              controller: rnc,
              inputFormatters: [UpperCaseTextFormatter()],
              onChanged: (rnc) => _fetchCompaniesByRnc(rnc),
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText:
                      'BUSCAR CONTRIBUYENTES... (RNC/CEDULA,RAZON SOCIAL)',
                  hintText: 'BUSCAR...',
                  hintStyle: TextStyle(fontSize: 15),
                  labelStyle: TextStyle(fontSize: 17),
                  suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.search, size: 28))),
            ))
          ],
        ));
  }

  Widget get _emptyContainer {
    return Expanded(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svgs/undraw_books_wxzz.svg', width: 250)
        ],
      ),
    ));
  }

  Widget get loadingView {
    return const Expanded(
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator()])));
  }

  Widget get _viewCompanies {
    if (companiesController.isLoading.value) {
      return loadingView;
    }

    if (companiesController.isError.value) return _errorWidget;

    if (companies.isEmpty) return _emptyContainer;

    return Expanded(
        child: ListView.separated(
            shrinkWrap: true,
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            itemCount: companies.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (ctx, index) {
              Company company = companies[index];

              return ListTile(
                  minVerticalPadding: 10,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                        company.rnc?.length == 9
                            ? Icons.store
                            : Icons.person_2_outlined,
                        size: 25,
                        color: Theme.of(context).primaryColor),
                  ),
                  title: Text(company.name!,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: const Color(0xFF074A80),
                          fontWeight: FontWeight.w400)),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(kDefaultPadding / 2),
                        margin:
                            EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.1)),
                        child: Text(
                          company.rnc ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      Spacer()
                    ],
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: company.rnc!));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    '¡RNC / CEDULA DE ${company.name} COPIADO!')));
                          },
                          icon: const Icon(
                            Icons.copy_all_outlined,
                          )),
                      PopupMenuButton(itemBuilder: (context) {
                        return forms
                            .map((e) => PopupMenuItem(
                                value: e['id'],
                                child: Text(e['id'] == 4
                                    ? '${e['name']} DE ${company.name}'
                                    : e['name'])))
                            .toList();
                      }, onSelected: (id) {
                        if (id == 1) {
                          preload606CompanyDetails(company);
                        }

                        if (id == 2) {
                          preload607CompanyDetails(company);
                        }

                        if (id == 3) {
                          preload608CompanyDetails(company);
                        }

                        if (id == 4) {
                          showDialog(
                              context: context,
                              useRootNavigator: false,
                              builder: (ctx) =>
                                  AddNotesModal(company: company));
                        }
                      }),
                      const SizedBox(width: 10),
                      sessionController.currentUser!.value!.permissions!
                              .contains('ALLOW_DELETE_COMPANY_PLATFORM')
                          ? IconButton(
                              onPressed: () => _deleteCompany(company, index),
                              icon: const Icon(Icons.delete),
                              tooltip: 'ELIMINAR')
                          : const SizedBox()
                    ],
                  ));
            }));
  }

  String get countTaxPayers {
    return '(${double.tryParse(myformatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: companies.length.toString())).text)?.toInt()}) CONTRIBUYENTES';
  }

  @override
  Widget build(BuildContext context) {
    sessionController = Get.find<SessionController>();
    companiesController = Get.find<CompaniesController>();

    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  title: Obx(() => Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white),
                            child: Icon(Icons.account_circle_outlined,
                                size: 30,
                                color: Theme.of(context).primaryColor),
                          ),
                          SizedBox(width: kDefaultPadding / 2),
                          Text(
                            '${sessionController.currentUser?.value?.name?.toUpperCase()}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: kDefaultPadding / 2),
                          Text(
                            '~ ${sessionController.currentUser?.value?.username?.toUpperCase()}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: kDefaultPadding / 2),
                          IconButton(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(
                                    text: sessionController
                                        .currentUser!.value!.username!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('¡USUARIO COPIADO!')));
                              },
                              icon: const Icon(Icons.copy_all_outlined)),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: kDefaultPadding / 2),
                            padding: EdgeInsets.all(kDefaultPadding / 2),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              sessionController.currentUser?.value?.roleName
                                      ?.toUpperCase() ??
                                  '',
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )),
                  actions: [
                    Row(
                      children: [
                        SizedBox(
                          height: kToolbarHeight,
                          width: 60,
                        ),
                        Row(
                          children: [
                            Icon(Icons.memory_outlined, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                                packageInfo != null
                                    ? 'VERSION ${packageInfo!.version}+${packageInfo!.buildNumber}'
                                    : '',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(
                          width: kDefaultPadding,
                        ),
                        sessionController.currentUser!.value!.permissions!
                                .contains('ALLOW_VIEW_USERS_SCREEN')
                            ? ToolButton(
                                onTap: _viewUsers,
                                toolTip: 'VER USUARIOS',
                                icon: const Icon(Icons.people))
                            : Container(),
                        Obx(() => sessionController
                                .currentUser!.value!.permissions!
                                .contains('ALLOW_ADD_COMPANY_PLATFORM')
                            ? ToolButton(
                                onTap: _addTaxPayer,
                                toolTip: 'AÑADIR CONTRIBUYENTE',
                                icon: const Icon(Icons.add))
                            : Container()),
                        ToolButton(
                            onTap: _logout,
                            toolTip: 'CERRAR SESION',
                            icon:
                                const Icon(Icons.power_settings_new_outlined)),
                      ],
                    )
                  ],
                ),
                body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: Column(children: [
                      _searchWidget,
                      const Divider(),
                      Obx(() => _viewCompanies)
                    ])),
                floatingActionButton: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                      bottom: _percent > 0.2 ? 0 : -100,
                      right: kDefaultPadding,
                      child: FloatingActionButton(
                        onPressed: () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut);
                          }
                        },
                        child: Icon(Icons.arrow_upward),
                      ),
                    )
                  ],
                ))));
  }
}
