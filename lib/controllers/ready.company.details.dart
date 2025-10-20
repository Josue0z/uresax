import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyDetailsController extends GetxController {
  final ScrollController scrollController = TrackingScrollController();

  final ScrollController verticalScrollController = ScrollController();

  final TextEditingController date = TextEditingController();

  @override
  void dispose() {
    scrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }
}
