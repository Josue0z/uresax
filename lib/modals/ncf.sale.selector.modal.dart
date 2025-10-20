import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/controllers/ncfs.override.controller.dart';
import 'package:uresaxapp/models/ncf.override.model.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:uresaxapp/models/user.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/formatters.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/layout.with.bar.widget.dart';
import 'package:uuid/uuid.dart';

class NcfSaleSelectorModal extends StatefulWidget {
  final CompanyDetailsPage companyDetailsPage;

  const NcfSaleSelectorModal({super.key, required this.companyDetailsPage});

  @override
  State<NcfSaleSelectorModal> createState() => _NcfSaleSelectorModalState();
}

class _NcfSaleSelectorModalState extends State<NcfSaleSelectorModal> {
  List<Sale> ncfs = [];

  int currentSelectedIndex = -1;

  Sale? selectedSale;

  bool selectedItem = false;

  onChanged(String words) async {
    try {
      var res = await Sale.get(
          companyId: widget.companyDetailsPage.company.id!,
          startDate: widget.companyDetailsPage.startDate,
          searchMode: true,
          searchWord: words,
          endDate: widget.companyDetailsPage.endDate);

      ncfs = res;

      if (ncfs.isNotEmpty) {
        selectedSale =
            ncfs.firstWhere((element) => element.invoiceNcf.contains(words));
      }

      if (selectedSale != null) {
        var index = ncfs.indexOf(selectedSale!);
        currentSelectedIndex = index;
        selectedItem = true;
      }
      if (words.isEmpty) {
        ncfs = [];
        currentSelectedIndex = -1;
        selectedItem = false;
        selectedSale = null;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  onSelected(int index, Sale sale) {
    if (selectedSale == sale) {
      setState(() {
        selectedSale = null;
        currentSelectedIndex = -1;
      });
    } else {
      selectedSale = sale;
      currentSelectedIndex = index;
      setState(() {});
    }
    selectedItem = currentSelectedIndex == index;
  }

  onConfirm() async {
    try {
      if (selectedItem && selectedSale != null) {
        var ncfOverride = NcfOverrideModel(
            id: const Uuid().v4(),
            companyId: widget.companyDetailsPage.company.id!,
            authorId: User.current!.id!,
            ncf: selectedSale!.invoiceNcf,
            typeOfOverride: '04',
            ncfTypeId: selectedSale!.invoiceNcfTypeId,
            ncfDate: selectedSale!.invoiceNcfDate);

        bool exists = await ncfOverride.checkIfExists(
            companyId: widget.companyDetailsPage.company.id!,
            startDate: widget.companyDetailsPage.startDate,
            endDate: widget.companyDetailsPage.endDate);

        if (!exists) {
          await ncfOverride.create();
        } else {
          throw 'YA EXISTE ESTE COMPROBANTE ANULADO';
        }

        var c = Get.find<NcfsOverrideController>();
        c.ncfsOverrides.value = await NcfOverrideModel.get(
            companyId: widget.companyDetailsPage.company.id!,
            startDate: widget.companyDetailsPage.startDate,
            endDate: widget.companyDetailsPage.endDate);
        Get.back();
      }
    } catch (e) {
      showAlert(context, message: e.toString());
    }
  }

  Widget get content {
    if (ncfs.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            ...ncfs.map((e) {
              var index = ncfs.indexOf(e);
              var selected = currentSelectedIndex == index;

              return Column(
                children: [
                  ListTile(
                      selected: selected,
                      contentPadding: EdgeInsets.zero,
                      onTap: () => onSelected(index, e),
                      title: Text(e.invoiceNcf,
                          style: TextStyle(
                              color: selected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                              fontWeight: FontWeight.w400))),
                  const Divider()
                ],
              );
            }),
          ],
        ),
      );
    }
    return Center(
        child: Icon(Icons.list_alt_outlined,
            size: 50, color: Theme.of(context).primaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
        width: 1,
        color: kWindowBorderColor,
        child: LayoutWithBar(
            child: Dialog(
                child: SizedBox(
                    width: 450,
                    child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: ListView(
                          padding: EdgeInsets.all(kDefaultPadding),
                          shrinkWrap: true,
                          children: [
                            Row(
                              children: [
                                Text('BUSCAR COMPROBANTES...',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20)),
                                const Spacer(),
                                IconButton(
                                    onPressed: () => Get.back(),
                                    icon: const Icon(Icons.close))
                              ],
                            ),
                            SizedBox(height: kDefaultPadding),
                            TextFormField(
                              onChanged: onChanged,
                              onFieldSubmitted: (v) => onConfirm(),
                              autofocus: true,
                              inputFormatters: [UpperCaseTextFormatter()],
                              decoration: const InputDecoration(
                                  hintText: 'BUSCAR...',
                                  labelText: 'BUSCAR',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Wrap(
                                    runAlignment: WrapAlignment.center,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      Icon(Icons.search),
                                      SizedBox(width: 10)
                                    ],
                                  )),
                            ),
                            SizedBox(height: kDefaultPadding),
                            SizedBox(
                                width: double.infinity,
                                height: 225,
                                child: content),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                  onPressed: selectedItem ? onConfirm : null,
                                  child: const Text('SELECCIONAR')),
                            )
                          ],
                        ))))));
  }
}
