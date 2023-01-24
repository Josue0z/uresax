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

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  List<Company> companies = [];

  _fetchCompanies() async {
    companies = await Company.getCompanies();
    setState(() {});
  }

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

  _viewUsers() {
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => const UsersPage()));
  }

  _loggout() async {
    try {
      await User.loggout(context);
    } catch (e) {
     showAlert(context,message:e.toString());
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMPRESAS'),
        actions: [
          PopupMenuButton(
            onSelected: (option){
               switch(option){
                case PageOptionType.users:
                   _viewUsers();
                  break;
                case PageOptionType.loggout:
                   _loggout();
                   break;
                  default:
               }
            },
            itemBuilder: (ctx){
            return options.map((e) {
              return PopupMenuItem(
                value: e.type,
                child: Text(e.name));
            }).toList();
          }),
       
        ],
      ),
      body: ListView.separated(
          separatorBuilder: (ctx, index) => const Divider(),
          itemCount: companies.length,
          itemBuilder: (ctx, index) {
            Company company = companies[index];
            return ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.apartment,
                      size: 25, color: Colors.white),
                ),
                title: Text(company.name!,
                    style: Theme.of(context).textTheme.headline5),
                minVerticalPadding: 15,
                subtitle: Text(
                  'RNC ${company.rnc} ${company.createdAt?.format("DD/MM/y")}',
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
                    IconButton(
                        onPressed: () => _deleteCompany(company, index),
                        icon: const Icon(Icons.delete),
                        color: Theme.of(context).errorColor,
                        tooltip: 'ELIMINAR'),
                  ],
                ));
          }),
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
