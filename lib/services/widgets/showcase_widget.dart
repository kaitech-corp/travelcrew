import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomShowcaseWidget extends StatelessWidget {
  final Widget child;
  final String description;
  final GlobalKey globalKey;

  const CustomShowcaseWidget({
    required this.description,
    required this.child,
    required this.globalKey,
  });

  @override
  Widget build(BuildContext context) => Showcase(
    key: globalKey,
    showcaseBackgroundColor: Colors.grey.shade400,
    contentPadding: EdgeInsets.all(12),
    showArrow: true,
    disableAnimation: false,
    // title: 'Hello',
    // titleTextStyle: TextStyle(color: Colors.white, fontSize: 32),
    description: description,
    descTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16,

    ),
    // overlayColor: Colors.white,
    // overlayOpacity: 0.7,
    child: child,
  );
}