import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

ThemeData themeDataBuilder() {
  return ThemeData(
    fontFamily: 'Cantata One',
    textTheme: const TextTheme(
      headline1: TextStyle(fontWeight: FontWeight.bold,
          color: Colors.black),
      headline2: TextStyle(fontWeight: FontWeight.bold,
          color: Colors.black),
      headline3: TextStyle(fontWeight: FontWeight.bold,
          color: Colors.black,
          fontStyle: FontStyle.italic),
      headline4: TextStyle(fontWeight: FontWeight.bold,
          color: Colors.black),
      headline5: TextStyle(fontWeight: FontWeight.bold,
        color: Colors.black,),
      headline6: TextStyle(fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(fontWeight: FontWeight.bold),
      subtitle2: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,fontSize: 14),
      button: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          shape: MaterialStateProperty.all<
              RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              )
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(fontFamily: 'Cantata One',
              fontWeight: FontWeight.bold,),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
              Colors.black
          )
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.grey),
          ),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(fontFamily: 'Cantata One',
            fontWeight: FontWeight.bold,),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(fontFamily: 'Cantata One',
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.black),),
    primaryIconTheme: IconThemeData(
        size: SizerUtil.deviceType == DeviceType.tablet ? 36 : 24,
        color: Colors.black
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Color(0xFF121212)
    ),
    canvasColor: const Color(0xFFFAFAFA),
    brightness: Brightness.light,
    primaryColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: Colors.black),
      fillColor: Colors.grey[300],
      focusedBorder: const UnderlineInputBorder(
        
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
      size: SizerUtil.deviceType == DeviceType.tablet ? 36 : 24,
    ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
    pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder()
    }),
  );
}
