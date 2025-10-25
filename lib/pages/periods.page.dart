import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresaxapp/controllers/ncfs.override.controller.dart';
import 'package:uresaxapp/controllers/periods.controller.dart';
import 'package:uresaxapp/controllers/purchases.controller.dart';
import 'package:uresaxapp/controllers/sales.controller.dart';
import 'package:uresaxapp/models/ncf.override.model.dart';
import 'package:uresaxapp/models/purchase.dart';
import 'package:uresaxapp/models/sale.dart';
import 'package:uresaxapp/pages/company_details.dart';
import 'package:uresaxapp/utils/consts.dart';
import 'package:uresaxapp/utils/extra.dart';
import 'package:uresaxapp/utils/functions.dart';
import 'package:uresaxapp/utils/modals-actions.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';
import 'package:uresaxapp/widgets/toolbutton.widget.dart';

class PeriodsPage extends StatelessWidget {
  CompanyDetailsPage companyDetailsPage;

  FormType formType;

  late PeriodsController controller;

  PeriodsPage(
      {super.key, required this.formType, required this.companyDetailsPage});

  loadPurchases(String dateLabel) async {
    showLoader(Get.context!);
    try {
      var startDate = DateTime.parse(dateLabel).startOfMonth();
      var endDate = DateTime.parse(dateLabel).endOfMonth();

      if (formType == FormType.form606) {
        var controller = Get.find<PurchasesController>();
        controller.purchases.value = await Purchase.get(
            companyId: companyDetailsPage.company.id!,
            startDate: startDate,
            endDate: endDate);
      }

      if (formType == FormType.form607) {
        var c = Get.find<SalesController>();
        c.sales.value = await Sale.get(
            companyId: companyDetailsPage.company.id!,
            startDate: startDate,
            endDate: endDate);
      }

      if (formType == FormType.form608) {
        var c = Get.find<NcfsOverrideController>();
        c.ncfsOverrides.value = await NcfOverrideModel.get(
            companyId: companyDetailsPage.company.id!,
            startDate: startDate,
            endDate: endDate);
      }

      var start = startDate.format(payload: 'DD/MM/YYYY');
      var end = endDate.format(payload: 'DD/MM/YYYY');

      companyDetailsPage.startDate = startDate;
      companyDetailsPage.endDate = endDate;

      companyDetailsPage.date.value = TextEditingValue(text: '$start - $end');

      if (companyDetailsPage.controller2.scrollController.hasClients) {
        companyDetailsPage.controller2.scrollController.jumpTo(0);
        companyDetailsPage.controller2.verticalScrollController.jumpTo(0);
      }

      if (formType == FormType.form606) {
        await storage.write(
            key: "STARTDATE_${companyDetailsPage.company.id}",
            value: companyDetailsPage.startDateLargeAsString);
        await storage.write(
            key: "ENDDATE_${companyDetailsPage.company.id}",
            value: companyDetailsPage.endDateLargeAsString);
      }

      if (formType == FormType.form607) {
        await storage.write(
            key: "STARTDATE_SALES_${companyDetailsPage.company.id}",
            value: companyDetailsPage.startDateLargeAsString);
        await storage.write(
            key: "ENDDATE_SALES_${companyDetailsPage.company.id}",
            value: companyDetailsPage.endDateLargeAsString);
      }

      if (formType == FormType.form608) {
        await storage.write(
            key: "STARTDATE_ANULADOS_${companyDetailsPage.company.id}",
            value: companyDetailsPage.startDateLargeAsString);
        await storage.write(
            key: "ENDDATE_ANULADOS_${companyDetailsPage.company.id}",
            value: companyDetailsPage.endDateLargeAsString);
      }
      Get.back();
      Get.back();
    } catch (e) {
      Get.back();
      showAlert(Get.context!, message: e.toString());
    }
  }

  searchPeriods(String words) async {
    try {
      if (formType == FormType.form606) {
        controller.periods.value = await Purchase.getListPeriods(
            id: companyDetailsPage.company.id!, search: words);
      }
      if (formType == FormType.form607) {
        controller.periods.value = await Sale.getListPeriods(
            id: companyDetailsPage.company.id!, search: words);
      }

      if (formType == FormType.form608) {
        controller.periods.value = await NcfOverrideModel.getListPeriods(
            id: companyDetailsPage.company.id!, search: words);
      }
    } catch (_) {}
  }

  Widget get content {
    return ListView.separated(
        itemCount: controller.periods.length,
        separatorBuilder: (ctx, index) => const Divider(),
        itemBuilder: (ctx, index) {
          var item = controller.periods[index];
          return SizedBox(
              height: 60,
              child: ListTile(
                onTap: () => loadPurchases('${item['date_label']}-01'),
                trailing: const Icon(Icons.arrow_right_rounded, size: 60),
                contentPadding: EdgeInsets.zero,
                title: Text(item['date_label'],
                    style: TextStyle(
                        color: Theme.of(Get.context!).primaryColor,
                        fontSize: kxDefaultFontSize,
                        fontWeight: FontWeight.w400)),
              ));
        });
  }

  Widget get emptyContent {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.date_range,
            size: 100, color: Theme.of(Get.context!).primaryColor)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    controller = Get.find<PeriodsController>();
    return WindowBorder(
      width: 1,
      color: kWindowBorderColor,
      child: Scaffold(
        body: Column(
          children: [
            const CustomFrameWidgetDesktop(),
            Expanded(
                child: Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      title: Text(
                          'LISTA DE PERIODOS FISCALES / ${companyDetailsPage.company.name!}'),
                      actions: [
                        Row(
                          children: [
                            ToolButton(
                                onTap: () => Get.back(),
                                toolTip: 'CERRAR LISTA DE PERIODOS FISCALES',
                                icon: const Icon(Icons.close)),
                          ],
                        )
                      ],
                    ),
                    body: Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(height: kDefaultPadding),
                            TextFormField(
                              onChanged: searchPeriods,
                              style: TextStyle(fontSize: kDefaultPadding),
                              decoration: InputDecoration(
                                  hintText: 'BUSCAR',
                                  labelText: 'BUSCAR PERIODOS...',
                                  suffixIcon: Padding(
                                      padding: EdgeInsets.only(
                                          right: kDefaultPadding),
                                      child: const Icon(Icons.search)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          kDefaultPadding * 2))),
                            ),
                            SizedBox(height: kDefaultPadding),
                            Expanded(
                                child: controller.periods.isEmpty
                                    ? emptyContent
                                    : content)
                          ],
                        )))))
          ],
        ),
      ),
    );
  }
}
