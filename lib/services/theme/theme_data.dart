import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

ThemeData ThemeDataBuilder() {
  return ThemeData(
    fontFamily: 'Cantata One',
    textTheme: TextTheme(
      headline1: const TextStyle(fontWeight: FontWeight.bold,
          color: Colors.black),
      headline2: const TextStyle(fontWeight: FontWeight.bold,
          color: Colors.black),
      headline3: const TextStyle(fontWeight: FontWeight.bold,
          color: Colors.black,
          fontStyle: FontStyle.italic),
      headline4: const TextStyle(fontWeight: FontWeight.bold,
          color: Colors.black),
      headline5: const TextStyle(fontWeight: FontWeight.bold,
        color: Colors.black,),
      headline6: const TextStyle(fontWeight: FontWeight.bold,
      ),
      subtitle1: const TextStyle(fontWeight: FontWeight.bold),
      subtitle2: const TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic,),
      button: const TextStyle(
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
            TextStyle(fontFamily: 'Cantata One',
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
          TextStyle(fontFamily: 'Cantata One',
            fontWeight: FontWeight.bold,),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all<TextStyle>(
          TextStyle(fontFamily: 'Cantata One',
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(color: Colors.black),),
    primaryIconTheme: IconThemeData(
        size: SizerUtil.deviceType == DeviceType.tablet ? 36 : 24,
        color: Colors.black
    ),
    buttonColor: Colors.blue,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Color(0xFF121212)
    ),
    canvasColor: Color(0xFFFAFAFA),
    accentIconTheme: IconThemeData(
        color: Colors.black
    ),
    brightness: Brightness.light,
    primaryColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      fillColor: Colors.grey[300],
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
      size: SizerUtil.deviceType == DeviceType.tablet ? 36 : 24,
    ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder()
    }),
  );
}
