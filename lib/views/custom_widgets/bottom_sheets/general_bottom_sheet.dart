import 'package:flutter/material.dart';
class GeneralBottomSheet extends StatelessWidget {
  const GeneralBottomSheet({
    super.key,
    required this.child,
    this.color,
    this.isCrossIcon = false,
  });
  final Widget child;
  final Color? color;
  final bool isCrossIcon;
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
