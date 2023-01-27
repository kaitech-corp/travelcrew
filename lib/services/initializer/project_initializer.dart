import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../blocs/bloc_observer/custom_bloc_observer.dart';
import '../locator.dart';

Future<String> projectInitializer() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp();
  setupLocator();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  Bloc.observer = CustomBlocObserver();

  Bloc.observer = CustomBlocObserver();

  return 'initialized';
}
