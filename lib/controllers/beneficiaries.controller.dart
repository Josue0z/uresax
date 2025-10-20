import 'package:get/get.dart';
import 'package:uresaxapp/models/beneficiary.dart';

class BeneficiariesController extends GetxController {
  RxList<Beneficiary> beneficiaries = <Beneficiary>[].obs;
  Rx<bool> loading = false.obs;
  Rx<bool> error = false.obs;

  @override
  void onInit() async {
    try {
      error.value = false;
      loading.value = true;
      beneficiaries.value = [
        Beneficiary(name: 'BENEFICIARIO'),
        ...(await Beneficiary.get())
      ];
      loading.value = false;
    } catch (e) {
      loading.value = false;
      error.value = true;
    }
    super.onInit();
  }
}
