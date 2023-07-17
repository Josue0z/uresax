import 'package:get/get.dart';
import 'package:uresaxapp/models/company.dart';

class CompaniesController extends GetxController {

  RxList<Company> companies = <Company>[].obs;

  RxBool isError = false.obs;

  RxString message = ''.obs;

  @override
  void onInit() async {
    isError.value = false;
    try {
      companies.value = await Company.all();
    } catch (e) {
      isError.value = true;
      companies.value = [];
      message.value = e.toString();
    }
    super.onInit();
  }

  @override
  void onClose() {
    companies.value = [];
    isError.value = false;
    message.value = '';
    super.onClose();
  }
}
