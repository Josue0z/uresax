import 'package:flutter/material.dart';
import 'package:uresaxapp/widgets/custom.frame.widget.dart';

class LayoutWithBar extends StatelessWidget {
  Widget child;
  LayoutWithBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [CustomFrameWidgetDesktop(), Expanded(child: child)],
      );
  }
}
