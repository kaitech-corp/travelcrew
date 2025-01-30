import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';

import '../services/constants/constants.dart';
import '../services/firebase_messaging.dart';
import '../services/initializer/project_initializer.dart';
import '../services/locator.dart';
import '../services/navigation/navigation_service.dart';
import '../services/navigation/router.dart';
import '../services/responsive/responsive_wrapper.dart';
import '../services/theme/theme_data.dart';
import '../size_config/size_config.dart';

import 'repositories/user_repository.dart';
import 'screens/Auth/bloc/Authentification/authentication_bloc.dart';
import 'screens/Auth/bloc/Authentification/authentication_event.dart';
import 'screens/Auth/bloc/Authentification/authentication_state.dart';
import 'screens/Auth/login_screen.dart';


import 'screens/Main_Page/main_page.dart';
import 'services/l10n.dart';

void main() async {
  await projectInitializer();

  final UserRepository userRepository = UserRepository();

  runApp(BlocProvider<AuthenticationBloc>(
      create: (BuildContext context) =>
          AuthenticationBloc(userRepository: userRepository)
            ..add(AuthenticationLoggedIn()),
      child: TravelCrew(
        userRepository: userRepository,
      )));
}

class TravelCrew extends StatefulWidget {
  const TravelCrew({super.key, this.userRepository});
  final UserRepository? userRepository;

  @override
  State<TravelCrew> createState() => _TravelCrewState();
}

class _TravelCrewState extends State<TravelCrew> {
  // FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    if (Platform.isIOS) {
      requestPermissions();
    } else {
      try {
        androidFCMSetting();
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder:
        (BuildContext context, Orientation orientation, ScreenType screenType) {
      return MaterialApp(
        builder: (BuildContext context, Widget? widget) {
          return responsiveWrapperBuilder(context, widget!);
        },
        home: AnimatedSplashScreen(
          splash: splashScreenLogo,
          animationDuration: const Duration(milliseconds: 1000),
          splashIconSize: double.maxFinite,
          nextScreen: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (BuildContext context, AuthenticationState state) {
            SizeConfig().init(context);
            if (state is AuthenticationSuccess) {
              getCurrentUserProfile();
              return const MainPage();
            } else {
              return LoginScreen();
            }
          }),
        ),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: L10n.all,
        debugShowCheckedModeBanner: false,
        theme: themeDataBuilder(),
        navigatorKey: locator<NavigationService>().navigationKey,
        onGenerateRoute: generateRoute,
      );
    });
  }
}
