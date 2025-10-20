import 'package:get/get.dart';
import 'package:uresaxapp/controllers/companies.controller.dart';
import 'package:uresaxapp/models/user.dart';

class SessionController extends GetxController {
  Rx<User?>? currentUser = User(permissions: []).obs;
  RxBool loading = true.obs;

  @override
  void onReady() async {
    var com = Get.find<CompaniesController>();
    currentUser = Rx(User.current);

    await Future.delayed(const Duration(seconds: 1));


    if (!com.isLoading.value || currentUser?.value == null) {
      loading.value = false;
    }

    super.onReady();
  }
}
