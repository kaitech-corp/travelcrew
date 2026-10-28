import 'package:travel_crew/services/safety_service.dart';
import 'package:travel_crew/services/recommendation_runtime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/firebase_options.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/views/main_view/controller/main_view_controller.dart';

import 'l10n/app_localizations.dart';
import 'services/notifications/notfication_services.dart';
import 'services/trip_link_service.dart';
import 'utils/app_strings.dart';
import 'utils/route_generator.dart';
import 'utils/screen_bindings.dart';

late FirebaseFirestore firestore;
MainViewController? mainViewController;
String userDeviceToken = '';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const bool useLocalFirebaseEmulators = bool.fromEnvironment(
  'TRAVEL_CREW_FIREBASE_EMULATORS',
);
const String _localFirebaseHost = String.fromEnvironment(
  'TRAVEL_CREW_FIREBASE_EMULATOR_HOST',
  defaultValue: 'localhost',
);
// Ports are overridable so device verification can run beside another
// emulator set. They only apply in the debug-only emulator mode.
const int _localFirestorePort = int.fromEnvironment(
  'TRAVEL_CREW_FIRESTORE_EMULATOR_PORT',
  defaultValue: 8080,
);
const int _localAuthPort = int.fromEnvironment(
  'TRAVEL_CREW_AUTH_EMULATOR_PORT',
  defaultValue: 9099,
);
const int _localFunctionsPort = int.fromEnvironment(
  'TRAVEL_CREW_FUNCTIONS_EMULATOR_PORT',
  defaultValue: 5001,
);
const int _localStoragePort = int.fromEnvironment(
  'TRAVEL_CREW_STORAGE_EMULATOR_PORT',
  defaultValue: 9199,
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TripLinkService.initialize();
  await initializeFirebase();
  SafetyService.initialize();
  RecommendationRuntime.initialize();
  if (!useLocalFirebaseEmulators) await initializeGoogleSignIn();
  await dotenv.load(isOptional: true);

  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // initAppsflyer();
  if (!useLocalFirebaseEmulators) {
    userDeviceToken = await FirebasePushNotificationApi().initNotifications();
  }

  runApp(const MyApp());
}

Future<void> initializeGoogleSignIn() async {
  await GoogleSignIn.instance.initialize(
    clientId:
        defaultTargetPlatform == TargetPlatform.iOS
            ? DefaultFirebaseOptions.ios.iosClientId
            : null,
  );
}

Future<void> initializeFirebase() async {
  if (useLocalFirebaseEmulators && !kDebugMode) {
    throw StateError('Local Firebase emulators require a debug build.');
  }
  if (useLocalFirebaseEmulators &&
      _localFirebaseHost != 'localhost' &&
      _localFirebaseHost != '127.0.0.1' &&
      _localFirebaseHost != '10.0.2.2') {
    throw StateError('Use a loopback Firebase emulator host.');
  }
  FirebaseApp app;
  if (Firebase.apps.isEmpty) {
    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    app = Firebase.app();
  }
  if (useLocalFirebaseEmulators &&
      app.options.projectId !=
          DefaultFirebaseOptions.currentPlatform.projectId) {
    throw StateError('The bundled Firebase project does not match this build.');
  }

  firestore = FirebaseFirestore.instanceFor(
    app: app,
    databaseId: 'travel-crew-db-2',
  );
  firestore.settings = Settings(persistenceEnabled: !useLocalFirebaseEmulators);
  if (useLocalFirebaseEmulators) {
    firestore.useFirestoreEmulator(_localFirebaseHost, _localFirestorePort);
    await FirebaseAuth.instance.useAuthEmulator(
      _localFirebaseHost,
      _localAuthPort,
    );
    FirebaseFunctions.instance.useFunctionsEmulator(
      _localFirebaseHost,
      _localFunctionsPort,
    );
    await FirebaseStorage.instance.useStorageEmulator(
      _localFirebaseHost,
      _localStoragePort,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      // Larger windows need more content space, not magnified phone controls.
      enableScaleWH: () => ScreenUtil().screenWidth < 600,
      enableScaleText: () => ScreenUtil().screenWidth < 600,
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
    final baseTheme = ThemeData(brightness: brightness);
    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      scaffoldBackgroundColor: AppColors.kScaffoldBgColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppColors.kPrimaryColor,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        constraints: BoxConstraints(maxWidth: 640),
      ),
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
