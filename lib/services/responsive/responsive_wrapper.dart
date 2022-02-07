import 'package:responsive_framework/responsive_framework.dart';

/// Makes the size of a widget adaptable to the size it can use.
ResponsiveWrapper ResponsiveWrapperBuilder(context, widget){
  return ResponsiveWrapper.builder(
    BouncingScrollWrapper.builder(context, widget),
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