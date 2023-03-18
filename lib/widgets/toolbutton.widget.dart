import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {

  void Function()? onTap;

  Icon icon;

  String toolTip;

  ToolButton({super.key, this.onTap,required this.toolTip, required this.icon});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
          width: 60,
          decoration: const BoxDecoration(
              border:
                  Border(left: BorderSide(width: 1, color: Colors.white30))),
          height: kToolbarHeight,
          child: Tooltip(
            message: toolTip,
            child: icon,
          )),
    ),
    );
  }
}
