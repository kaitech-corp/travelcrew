import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomShowcaseWidget extends StatelessWidget {

  const CustomShowcaseWidget({Key? key,
    required this.description,
    required this.child,
    required this.globalKey,
  }) : super(key: key);
  final Widget child;
  final String description;
  final GlobalKey globalKey;

  @override
  Widget build(BuildContext context) => Showcase(
    key: globalKey,
    showcaseBackgroundColor: Colors.grey.shade400,
    contentPadding: const EdgeInsets.all(12),
    disableAnimation: false,
    // title: 'Hello',
    // titleTextStyle: TextStyle(color: Colors.white, fontSize: 32),
    description: description,
    descTextStyle: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16,

    ),
    // overlayColor: Colors.white,
    // overlayOpacity: 0.7,
    child: child,
  );
}
