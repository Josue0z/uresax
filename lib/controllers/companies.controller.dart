import 'package:get/get.dart';
import 'package:uresaxapp/models/company.dart';
import 'package:uresaxapp/models/user.dart';

class CompaniesController extends GetxController {
  RxList<Company> companies = <Company>[].obs;

  RxBool isError = false.obs;

  RxBool isLoading = true.obs;

  RxString message = ''.obs;

  Future<void> onInitCustom({bool? runContact = false}) async{
    companies.value = [];
    isLoading.value = true;
    isError.value = false;
    try {
      if (runContact == true || User.current != null) {
        companies.value = await Company.get();
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      companies.value = [];
      message.value = e.toString();
    }
  }

  @override
  Future<void> onInit() async {
    onInitCustom();
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
