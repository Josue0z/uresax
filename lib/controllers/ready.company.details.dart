import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CompanyDetailsController extends GetxController {
  

  late FocusAttachment focusAttachment;

  FocusNode startTableFocus = FocusNode();

  final ScrollController scrollController = ScrollController();

  final ScrollController verticalScrollController = ScrollController();

  final ScrollController horizontalScrollController = ScrollController();

  final TextEditingController date = TextEditingController();


  void _handlerKeys(KeyEvent value) {
    try {
      if (startTableFocus.hasFocus) {
        if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _moveLeft();
        }
        if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
          _moveRight();
        }

        if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
          _moveUp();
        }
        if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
          _moveDown();
        }
      }
    } catch (e) {
      print(e);
    }
  }

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
  setupScrollViews() {
    horizontalScrollController.jumpTo(scrollController.offset);
  }

  @override
  void onInit() {
    focusAttachment = startTableFocus.attach(Get.context, onKeyEvent: (_, event) {
      _handlerKeys(event);
      return KeyEventResult.handled;
    });
    startTableFocus.requestFocus();
    scrollController.addListener(setupScrollViews);
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }
}
