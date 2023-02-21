import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;

  List<Widget> actions;
  CustomAppBar({super.key, required this.title, this.actions = const []});

  Widget  _buildBackBtn(BuildContext context) {
 
    if (Navigator.canPop(context)) {
      return Row(
        children: [
          IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          icon: const Icon(Icons.arrow_back)),
          const SizedBox(width: 20)
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: kToolbarHeight,
      child: Material(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              children: [
                _buildBackBtn(context),
                Text(title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w400)),
                const Spacer(),
                ...actions
              ],
            ),
          )),
    );
  }
}
