import 'package:flutter/widgets.dart';
import 'package:responsive_framework/responsive_framework.dart';

Widget responsiveWrapperBuilder(BuildContext context, Widget widget) {
  return ResponsiveBreakpoints.builder(
    child: widget,
    breakpoints: <Breakpoint>[
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
    ],
  );
}
