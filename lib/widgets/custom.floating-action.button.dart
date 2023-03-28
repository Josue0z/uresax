import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  
  Function()? onTap;

  String title;

  IconData icon;

  CustomFloatingActionButton(
      {super.key,
      required this.onTap,
      required this.title,
      required this.icon});

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
                child: Icon(icon, color: Colors.white),
              ),
            )));
  }
}
