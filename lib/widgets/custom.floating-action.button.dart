import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  Function()? onTap;

  String title;

  Widget child;

  CustomFloatingActionButton(
      {super.key, this.onTap, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Tooltip(
              message: title,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(50)),
                child: child,
              ),
            )));
  }
}
