import 'package:flutter/material.dart';
import 'package:uresaxapp/utils/consts.dart';

class ToolButton extends StatelessWidget {
  void Function()? onTap;

  Icon icon;

  String toolTip;

  ToolButton(
      {super.key, this.onTap, required this.toolTip, required this.icon});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
          width: 60,
          decoration: const BoxDecoration(
              border:
                  Border(left: BorderSide(width: 1, color: Colors.white30))),
          height: kToolbarHeight,
          child: Tooltip(
            message: toolTip,
            child: Ink(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                    padding: EdgeInsets.all(kDefaultPadding / 2), child: icon),
              ),
            ),
          )),
    );
  }
}
