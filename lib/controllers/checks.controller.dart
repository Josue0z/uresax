import 'package:get/get.dart';
import 'package:uresaxapp/models/check.dart';
import 'package:uresaxapp/models/company.dart';

class ChecksController extends GetxController {
  Company company;

  DateTime? startDate;
  DateTime? endDate;

  RxList<Check> checks = <Check>[].obs;
  Rx<bool> error = false.obs;
  Rx<bool> loading = false.obs;

  bool isEditionMode;

  ChecksController({required this.company, required this.isEditionMode, required this.startDate, required this.endDate});

  @override
  void onInit() async {
    try {
      error.value = false;
      loading.value = true;
      if (!isEditionMode) {
        checks.insert(0, Check());
      }
      checks.addAll([...(await Check.get(company: company))]);
      loading.value = false;
    } catch (e) {
      error.value = true;
      loading.value = false;
    }
    super.onInit();
  }
}
