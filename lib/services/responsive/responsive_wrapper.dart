import 'package:responsive_framework/responsive_framework.dart';

ResponsiveWrapper ResponsiveWrapperBuilder(context, ResponsiveWrapper){
  return ResponsiveWrapper.builder(
    BouncingScrollWrapper.builder(context, ResponsiveWrapper),
    maxWidth: 1200,
    minWidth: 400,
    defaultScale: true,
    breakpoints: [
      ResponsiveBreakpoint.resize(400, name: MOBILE),
      ResponsiveBreakpoint.autoScale(800, name: TABLET),
      ResponsiveBreakpoint.resize(1000, name: DESKTOP),
    ],
  );
}