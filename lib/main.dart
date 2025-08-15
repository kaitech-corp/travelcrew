import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/services/firebase_options.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/views/main_view/controller/main_view_controller.dart';

import 'l10n/app_localizations.dart';
import 'services/notifications/notfication_services.dart';
import 'utils/app_strings.dart';
import 'utils/route_generator.dart';
import 'utils/screen_bindings.dart';


late FirebaseFirestore firestore;
MainViewController? mainViewController;
String userDeviceToken = "";
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  // initAppsflyer();
  userDeviceToken = await FirebasePushNotificationApi().initNotifications();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  FirebaseApp app;
  if (Firebase.apps.isEmpty) {
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    app = Firebase.app(); // Get the default app if already initialized
  }

  firestore = FirebaseFirestore.instanceFor(
    app: app,
    databaseId: 'travel-crew-db-2',
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: kAppName,
          theme: _buildTheme(Brightness.light),
          debugShowCheckedModeBanner: false,
          initialBinding: ScreenBindings(),
          initialRoute: kSplashScreenRoute,
          supportedLocales: const <Locale>[
            Locale('en', 'US'),
            Locale('es', ''),
            Locale('zh', ''),
          ],
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          getPages: RouteGenerator.getPages(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    var baseTheme = ThemeData(brightness: brightness);
    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      scaffoldBackgroundColor: AppColors.kScaffoldBgColor,
      colorScheme: ThemeData().colorScheme.copyWith(
        primary: AppColors.kPrimaryColor,
      ),
      // bottomSheetTheme: BottomSheetThemeData(
      //   backgroundColor: AppColors.kSecondaryColor.withValues(alpha: 0.6),
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.kWhiteColor),
        trackOutlineColor: WidgetStateProperty.all(AppColors.transparent),
      ),
      cardTheme: CardThemeData(
        surfaceTintColor: AppColors.kWhiteColor,
        color: AppColors.kWhiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}
