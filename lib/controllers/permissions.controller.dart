import 'package:get/get.dart';
import 'package:uresaxapp/models/permissionc.dart';

class PermissionsController extends GetxController {
  RxList<PermissionC> permissions = <PermissionC>[].obs;

  @override
  void onInit() async {
    try {
      permissions.value = await PermissionC.get();
    } catch (e) {
      print(e);
    }
    super.onInit();
  }
}
