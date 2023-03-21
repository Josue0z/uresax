import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/modals/add-company-modal.dart';
import 'package:uresaxapp/models/book.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/page-option.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/books_page.dart';
import 'package:uresaxapp/pages/users_page.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom-appbar.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  TextEditingController rnc = TextEditingController();

  List<Company> companies = [];

  bool isError = false;

  String message = '';

  _deleteCompany(Company company, int index) async {
    try {
      var isConfirm =
          await showConfirm(context, title: 'Eliminar esta empresa?');

      if (isConfirm!) {
        await Company(id: company.id).delete();
        companies.removeAt(index);
        setState(() {});
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  _fetchCompanies() async {
    isError = false;
    try {
      companies = await Company.all();
    } catch (e) {
      isError = true;
      companies = [];
      message = e.toString();
    }
    setState(() {});
  }

  _fetchCompaniesByRnc(String? rnc) async {
    isError = false;
    try {
      if (rnc!.isEmpty) {
        companies = await Company.all();
      } else {
        companies = await Company.all(
            where: ''' company_rnc like '%${rnc.trim()}%' ''');
      }
    } catch (e) {
      isError = true;
      companies = [];
      message = e.toString();
    }
    setState(() {});
  }

  _viewUsers() {
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => const UsersPage()));
  }

  _logout() async {
    try {
      await User.loggout(context);
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  List<PopupMenuEntry<dynamic>> _createOptions() {
    List<PopupMenuEntry<dynamic>> ops = [];

    for (var op in options) {
      if (!(op.type == PageOptionType.users && !User.current!.isAdmin)) {
        ops.add(PopupMenuItem(value: op.type, child: Text(op.name)));
      }
    }

    return ops;
  }

  @override
  void initState() {
    _fetchCompanies();
    super.initState();
  }

  @override
  void dispose() {
    companies = [];
    super.dispose();
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
      padding: const EdgeInsets.symmetric(horizontal: 80),
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        controller: rnc,
        onChanged: (rnc) => _fetchCompaniesByRnc(rnc),
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'BUSCAR CONTRIBUYENTES... (RNC).',
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
          Icon(Icons.payment_sharp,
              size: 110, color: Theme.of(context).primaryColor)
        ],
      ),
    ));
  }

  Widget get _viewCompanies {

    if (isError) return _errorWidget;

    if (companies.isEmpty) return _emptyContainer;

    return Expanded(
        child: ListView.builder(
            itemCount: companies.length,
            itemBuilder: (ctx, index) {
              Company company = companies[index];
              String title =
                  'RNC ${company.rnc} ${company.createdAt?.format("DD/MM/y")}';

              return ListTile(
                  minVerticalPadding: 15,
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.apartment,
                        size: 25, color: Colors.white),
                  ),
                  title: Text(company.name!,
                      style: Theme.of(context).textTheme.headlineSmall),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 80),
                  subtitle: Text(
                    title,
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => BooksPage(
                                      company: company,
                                      bookType: BookType.purchases))),
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'EMPRESAS',
          actions: [
            PopupMenuButton(
                color: Colors.white,
                onSelected: (option) async {
                  switch (option) {
                    case PageOptionType.users:
                      _viewUsers();
                      break;
                    case PageOptionType.loggout:
                      var isConfirm =
                          await showConfirm(context, title: 'Cerrar Sesion?');
                      if (isConfirm!) {
                        _logout();
                      }
                      break;
                    default:
                  }
                },
                itemBuilder: (ctx) {
                  return _createOptions();
                }),
          ],
        ),
      ),
      body: Column(children: [_searchWidget, _viewCompanies]),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            var company = await showDialog<Company>(
                context: context, builder: (ctx) => const AddCompanyModal());
            if (company != null) {
              companies.add(company);
              setState(() {});
            }
          }),
    );
  }
}
