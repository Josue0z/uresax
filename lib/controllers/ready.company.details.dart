import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyDetailsController extends GetxController {
  

  //late FocusAttachment focusAttachment;

  FocusNode startTableFocus = FocusNode();

  final ScrollController scrollController =  TrackingScrollController();

  final ScrollController verticalScrollController = ScrollController();

  final TextEditingController date = TextEditingController();

  _moveLeft() {
    if (scrollController.offset == 0) return;
    scrollController.jumpTo(scrollController.offset - 50);
  }

  _moveRight() {
    if (scrollController.offset >=
        scrollController.position.maxScrollExtent) {
      return;
    }

    scrollController.jumpTo(scrollController.offset + 50);
  }

  _moveUp() {
    if (verticalScrollController.offset == 0) return;
    verticalScrollController.jumpTo(verticalScrollController.offset - 50);
  }

  _moveDown() {
    if (verticalScrollController.offset ==
        verticalScrollController.position.maxScrollExtent) return;
    verticalScrollController.jumpTo(verticalScrollController.offset + 50);
  }


 /* @override
  void onInit() {
    focusAttachment = startTableFocus.attach(Get.context, onKeyEvent: (_, event) {
      _handlerKeys(event);
      return KeyEventResult.handled;
    });
    startTableFocus.requestFocus();
    super.onInit();
  }*/

  @override
  void dispose() {
    scrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }
}
