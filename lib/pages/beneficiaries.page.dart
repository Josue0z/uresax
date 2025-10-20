import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uresaxapp/controllers/beneficiaries.controller.dart';
import 'package:uresaxapp/modals/add.beneficiary.modal.dart';
import 'package:uresaxapp/models/beneficiary.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class BeneficiariesPage extends StatelessWidget {
  late BeneficiariesController beneficiariesController;

  bool isEditionMode;

  BeneficiariesPage({super.key, this.isEditionMode = true});

  onSearch(String words) async {
    try {
      var result = await Beneficiary.get(searchMode: true, words: words);
      beneficiariesController.beneficiaries.value = [
        Beneficiary(name: 'BENEFICIARIO'),
        ...result
      ];
    } catch (_) {}
  }

  showEditMode(Beneficiary beneficiary) async {
    showDialog(
        context: Get.context!,
        builder: (ctx) =>
            BeneficiaryModal(isEditing: true, beneficiary: beneficiary));
  }

  delete(Beneficiary beneficiary) async {
    try {
      var isConfirm = await showConfirm(Get.context!,
          title: '¿DESEAS ELIMINAR EL BENEFICIARIO?');
      if (isConfirm != null && isConfirm) {
        await beneficiary.delete();
        Get.back();
      }
    } catch (e) {
      showAlert(Get.context!, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    beneficiariesController = Get.put(BeneficiariesController());

    return Scaffold(
      body: Column(
        children: [
          const CustomFrameWidgetDesktop(),
          Expanded(
              child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('BENEFICIARIOS'),
              actions: [
                ToolButton(
                    onTap: () => Get.back(result: 'closed'),
                    toolTip: 'CERRAR LISTA DE BENEFICIARIOS',
                    icon: const Icon(Icons.close)),
              ],
            ),
            body: Obx(
              () => Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        onChanged: onSearch,
                        style: const TextStyle(fontSize: 20),
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: const InputDecoration(
                            suffixIcon: Wrap(
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              children: [
                                Icon(Icons.search),
                                SizedBox(width: 20)
                              ],
                            ),
                            hintText: 'BUSCAR...',
                            labelText: 'BUSCAR BENEFICIARIO',
                            border: OutlineInputBorder()),
                      )),
                  const SizedBox(height: 20),
                  Expanded(
                      child: ListView.separated(
                    separatorBuilder: (c, i) => const Divider(),
                    itemCount: beneficiariesController.beneficiaries.length,
                    itemBuilder: (ctx, index) {
                      var beneficiary =
                          beneficiariesController.beneficiaries[index];
                      return ListTile(
                        title: Text(
                          beneficiary.name ?? '',
                          style: const TextStyle(fontSize: 20),
                        ),
                        trailing: Wrap(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Get.back(result: beneficiary);
                                },
                                icon: const Icon(Icons.arrow_right_rounded)),
                            index == 0
                                ? const SizedBox()
                                : Wrap(
                                    children: [
                                      IconButton(
                                          onPressed: () =>
                                              showEditMode(beneficiary),
                                          icon: const Icon(Icons.edit)),
                                      IconButton(
                                          onPressed: () => delete(beneficiary),
                                          icon: const Icon(Icons.delete))
                                    ],
                                  )
                          ],
                        ),
                      );
                    },
                  ))
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await showDialog(
                      context: context, builder: (ctx) => BeneficiaryModal());
                }),
          ))
        ],
      ),
    );
  }
}
