import 'package:flutter/material.dart';
class GeneralBottomSheet extends StatelessWidget {
  final Widget child;
  final Color? color;
  final bool isCrossIcon;
  const GeneralBottomSheet({
    super.key,
    required this.child,
    this.color,
    this.isCrossIcon = false,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isCrossIcon)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );
  }
}
