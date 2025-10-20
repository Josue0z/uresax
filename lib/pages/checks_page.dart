import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/checks.controller.dart';
import 'package:uresaxapp/modals/add.check.modal.dart';
import 'package:uresaxapp/models/check.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class ChecksPage extends StatelessWidget {
  final CompanyDetailsPage companyDetailsPage;
  late ChecksController checksController;
  bool isEditionMode;

  ChecksPage(
      {super.key, required this.companyDetailsPage, this.isEditionMode = true});

  String get total {
    if (checksController.checks.isEmpty) return '0.00';

    double total = 0;

    for (int i = 0; i < checksController.checks.length; i++) {
      var check = checksController.checks[i];
      total += check.total ?? 0;
    }

    return myformatter
        .formatEditUpdate(TextEditingValue.empty,
            TextEditingValue(text: total.toStringAsFixed(2)))
        .text;
  }

  Widget get container {
    if (checksController.loading.value) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ));
    }

    if (checksController.checks.isNotEmpty) {
      return ListView.separated(
          itemCount: checksController.checks.length,
          separatorBuilder: (_, i) => const Divider(),
          itemBuilder: (ctx, index) {
            var check = checksController.checks[index];
            return ListTile(
              minVerticalPadding: 20,
              contentPadding: EdgeInsets.zero,
              title: Text(
                  check.id == null
                      ? 'BANCO'
                      : '${check.bankingName} / ${check.bankingEntityName} ${check.checkNumber}',
                  style: const TextStyle(fontSize: 20)),
              subtitle: check.id == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                          'MONTO DE CHEQUE = ${myformatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: check.total?.toStringAsFixed(2) ?? '')).text} / ${check.beneficiaryName} - ${check.checkDate!.format(payload: 'DD/MM/YYYY')}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black54))),
              trailing: isEditionMode
                  ? Wrap(
                      children: [
                        check.id == null
                            ? const SizedBox()
                            : IconButton(
                                onPressed: () => showEditMode(check),
                                icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => delete(check),
                            icon: const Icon(Icons.delete))
                      ],
                    )
                  : IconButton(
                      onPressed: () {
                        Get.back(result: check);
                      },
                      icon: const Icon(Icons.arrow_right_rounded)),
            );
          });
    }
    return emptyContainer;
  }

  Widget get emptyContainer {
    return Center(
      child: Icon(Icons.clear_all_outlined,
          size: 120, color: Theme.of(Get.context!).primaryColor),
    );
  }

  showEditMode(Check check) {
    try {
      showDialog(
          context: Get.context!,
          builder: (ctx) => AddCheckModal(
              companyDetailsPage: companyDetailsPage,
              isEditing: true,
              isEditionMode: isEditionMode,
              check: check));
    } catch (e) {
      rethrow;
    }
  }

  delete(Check check) async {
    try {
      var confirm = await showConfirm(Get.context!,
          title: '¿DESEAS ELIMINAR LA ENTIDAD BANCARIA?');
      if (confirm != null && confirm) {
        await check.delete();
        checksController.checks.value =
            await Check.get(company: companyDetailsPage.company);
      }
    } catch (e) {
      showAlert(Get.context!, message: e.toString());
    }
  }

  onSearch(String words) async {
    try {
      checksController.checks.clear();

      if (!isEditionMode) {
        checksController.checks.insert(0, Check());
      }

      checksController.checks.addAll([
        ...(await Check.get(
            company: companyDetailsPage.company,
            searchMode: true,
            words: words))
      ]);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    checksController = Get.put(ChecksController(
        company: companyDetailsPage.company,
        isEditionMode: isEditionMode,
        startDate: companyDetailsPage.startDate,
        endDate: companyDetailsPage.endDate));
    return WindowBorder(
        color: kWindowBorderColor,
        child: Scaffold(
          body: Column(
            children: [
              const CustomFrameWidgetDesktop(),
              Expanded(
                  child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(
                      'REGISTRO DE CHEQUES/TRANSFERENCIA DE ${companyDetailsPage.company.name?.toUpperCase()}'),
                  actions: [
                    Obx(() => Wrap(
                          children: [
                            SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                  total,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: Text(
                                    checksController.checks.length.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ),
                            ),
                          ],
                        )),
                    ToolButton(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (ctx) => AddCheckModal(
                                  companyDetailsPage: companyDetailsPage,
                                  isEditionMode: isEditionMode));
                        },
                        toolTip: 'AÑADIR CHEQUE/TRANSFERENCIA',
                        icon: const Icon(Icons.add)),
                    ToolButton(
                        onTap: () => Get.back(result: 'closed'),
                        toolTip: 'CERRAR CATALOGO DE QUEQUES/TRANSFERENCIAS',
                        icon: const Icon(Icons.close)),
                  ],
                ),
                body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          style: const TextStyle(fontSize: 20),
                          onChanged: onSearch,
                          inputFormatters: [UpperCaseTextFormatter()],
                          decoration: const InputDecoration(
                              hintText:
                                  'BUSCAR... (NUMERO, BENEFICIARIO, BANCO, MONTO, FECHA)',
                              labelText: 'BUSCAR CHEQUES/TRANSFERENCIA',
                              suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.search)),
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 20),
                        Expanded(child: Obx(() => container)),
                      ],
                    )),
              ))
            ],
          ),
        ));
  }
}
