


import 'package:get/get.dart';
import 'package:uresaxapp/models/purchase.dart';

class PurchasesController extends GetxController {
  RxList<Purchase> purchases = <Purchase>[].obs;
  @override
  void onClose() {
    purchases.clear();
    super.onClose();
  }
 }