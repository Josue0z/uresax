import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uresaxapp/controllers/ux.controller.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomFrameWidgetDesktop extends StatefulWidget {
  const CustomFrameWidgetDesktop({super.key});

  @override
  State<CustomFrameWidgetDesktop> createState() =>
      _CustomFrameWidgetDesktopState();
}

class _CustomFrameWidgetDesktopState extends State<CustomFrameWidgetDesktop> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) return Container();
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: const BoxDecoration(
        color: Color(0xFF1E77C1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: MoveWindow(
            child: Row(
              children: [
                const SizedBox(width: 10),
                SvgPicture.asset('assets/svgs/URESAXLOGO.SVG',
                    width: 20, height: 20)
              ],
            ),
          )),
          const WindowButtons()
        ],
      ),
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> with WindowListener {
  late UxController uxController;
  void maximizeOrRestore() {
    setState(() {});
  }

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    uxController.isMaximized.value = true;
    super.onWindowMaximize();
  }

  @override
  void onWindowUnmaximize() {
    uxController.isMaximized.value = false;
    super.onWindowUnmaximize();
  }

  @override
  Widget build(BuildContext context) {
    uxController = Get.find<UxController>();
    return Obx(() => Row(
          children: [
            MinimizeWindowButton(colors: buttonColors),
            uxController.isMaximized.value
                ? RestoreWindowButton(
                    colors: buttonColors,
                    onPressed: () {
                      windowManager.restore();
                    },
                  )
                : MaximizeWindowButton(
                    colors: buttonColors,
                    onPressed: () {
                      windowManager.maximize();
                    },
                  ),
            CloseWindowButton(colors: closeButtonColors),
          ],
        ));
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFFFFFFFF),
    mouseOver: const Color(0xFF628DEA),
    mouseDown: const Color(0xFF628DEA),
    iconMouseOver: const Color(0xFFFFFFFF),
    iconMouseDown: const Color(0xFFFFFFFF));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFFFFFFFF),
    iconMouseOver: Colors.white);
