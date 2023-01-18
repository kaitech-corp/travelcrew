import 'package:flutter/widgets.dart';
import 'package:responsive_framework/responsive_framework.dart';

Widget responsiveWrapperBuilder(BuildContext context, Widget widget){
  return ResponsiveWrapper.builder(
    widget,
    maxWidth: 1200,
    minWidth: 400,
    defaultScale: true,
    breakpoints: <ResponsiveBreakpoint>[
      const ResponsiveBreakpoint.resize(400, name: MOBILE),
      const ResponsiveBreakpoint.autoScale(800, name: TABLET),
      const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
    ],
  );
}
