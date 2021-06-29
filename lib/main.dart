import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/services/auth/auth.dart';
import 'package:travelcrew/services/firebase_messaging.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/navigation/navigation_service.dart';
import 'package:travelcrew/services/navigation/router.dart';
import 'models/custom_objects.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  runApp(TravelCrew());

}

class TravelCrew extends StatefulWidget{

  @override
  _TravelCrewState createState() => _TravelCrewState();
}

class _TravelCrewState extends State<TravelCrew> {
  FirebaseAnalytics analytics = FirebaseAnalytics();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    setupLocator();
    if (Platform.isIOS) {
      FBMessaging().requestPermissions();
    } else {
      FBMessaging().androidFCMSetting();
      FirebaseMessaging.onBackgroundMessage((message) async {
        print("onMessage: $message");
        FBMessaging().firebaseMessagingBackgroundHandler(message);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log('App Started');

    return Sizer(
      builder: (context,orientation, deviceType) {
        return StreamProvider<User>.value(
          value: AuthService().user,
          child: ThemeProvider(
            saveThemesOnChange: true,
            themes: [
              AppTheme(
                id: 'light_theme',
                description: 'sky theme',
                data: ThemeData(
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
                  accentColor: Colors.blueAccent,
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
                  ),
                ),
              ),
              AppTheme(
                id: 'dark_theme',
                description: 'space theme',
                data: ThemeData(
                  fontFamily: 'Cantata One',
                  textTheme: TextTheme(
                    headline1: const TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.white),
                    headline2: const TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.white),
                    headline3: const TextStyle(fontWeight: FontWeight.w700,
                        color: Colors.greenAccent,
                        fontStyle: FontStyle.italic),
                    headline4: const TextStyle(fontWeight: FontWeight.bold,
                        color: Colors.white),
                    headline5: const TextStyle(fontWeight: FontWeight.w600,
                      color: Colors.white,),
                    headline6: const TextStyle(fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                        color: Colors.white),
                    subtitle1: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    subtitle2: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                    button: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.greenAccent
                      ),
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
                            color: Colors.greenAccent),
                      ),
                    ),
                  ),
                  primaryIconTheme: IconThemeData(
                      size: SizerUtil.deviceType == DeviceType.tablet ? 36 : 24,
                      color: Colors.greenAccent
                  ),
                  buttonColor: Colors.greenAccent,
                  dialogBackgroundColor: Colors.grey[600],
                  floatingActionButtonTheme: FloatingActionButtonThemeData(
                      foregroundColor: Colors.white
                  ),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                      backgroundColor: Color(0xFF121212),
                      selectedItemColor: Colors.greenAccent,
                      unselectedItemColor: Colors.white
                  ),
                  tabBarTheme: TabBarTheme(
                      labelColor: Colors.greenAccent,
                      unselectedLabelColor: Colors.white
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.black,
                      hintStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      )
                  ),
                  cardColor: Colors.black12,
                  unselectedWidgetColor: Colors.white,
                  canvasColor: Color(0xFF121212),
                  accentIconTheme: IconThemeData(
                      color: Colors.white
                  ),
                  brightness: Brightness.light,
                  primaryColor: Color(0xFF121212),
                  accentColor: Colors.blueAccent,
                  iconTheme: IconThemeData(
                      color: Colors.white
                  ),
                  popupMenuTheme: PopupMenuThemeData(
                    color: Color(0xFF121212),
                  ),
                  dialogTheme: DialogTheme(
                    titleTextStyle: TextStyle(fontFamily: 'Cantata One',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,),
                    contentTextStyle: TextStyle(
                        fontFamily: 'Cantata One', color: Colors.white),
                  ),

                ),
              ),
            ],
            child: ThemeConsumer(
              child: Builder(
                builder: (themeContext) =>
                    MaterialApp(
                      home: Wrapper(),
                      debugShowCheckedModeBanner: false,
                      theme: ThemeProvider
                          .themeOf(themeContext)
                          .data,
                      navigatorKey: locator<NavigationService>().navigationKey,
                      onGenerateRoute: generateRoute,
                      navigatorObservers: [
                        FirebaseAnalyticsObserver(analytics: analytics)
                      ],
                    ),
              ),
            ),
          ),
        );
      }
    );
  }
}
