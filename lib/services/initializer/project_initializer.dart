import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../blocs/bloc_observer/custom_bloc_observer.dart';
import '../../firebase_options.dart';
import '../locator.dart';

Future<String> projectInitializer() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // 8e3eb48c-6397-464a-8330-8c290947be9b
    // 8e3eb48c-6397-464a-8330-8c290947be9b
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  setupLocator();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  Bloc.observer = CustomBlocObserver();

  Bloc.observer = CustomBlocObserver();

  return 'initialized';
}
