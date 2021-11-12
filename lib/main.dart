import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_event.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_state.dart';
import 'package:travelcrew/repositories/user_repository.dart';
import 'package:travelcrew/screens/complete_profile/complete_profile_page.dart';
import 'package:travelcrew/screens/login/login_screen.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/firebase_messaging.dart';
import 'package:travelcrew/services/initializer/project_initializer.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/navigation/navigation_service.dart';
import 'package:travelcrew/services/navigation/router.dart';
import 'package:travelcrew/services/responsive/responsive_wrapper.dart';
import 'package:travelcrew/services/theme/theme_data.dart';
import 'package:travelcrew/services/widgets/launch_icon_badger.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';




void main() async {

  await ProjectInitializer();

  final UserRepository userRepository = UserRepository();

  runApp(BlocProvider(
    create: (BuildContext context) => AuthenticationBloc(
      userRepository: userRepository,
    )..add(AuthenticationStarted()),
      child: TravelCrew(userRepository: userRepository,)));

}

class TravelCrew extends StatefulWidget{
  final UserRepository userRepository;

  TravelCrew({this.userRepository });
  @override
  _TravelCrewState createState() => _TravelCrewState();
}

class _TravelCrewState extends State<TravelCrew> {
  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    // DatabaseService().getUserNotificationSettings();

    if (Platform.isIOS) {
      FBMessaging().requestPermissions();
    } else {
      FBMessaging().androidFCMSetting();
      FirebaseMessaging.onBackgroundMessage((message) async {
        FBMessaging().firebaseMessagingBackgroundHandler(message);
      });
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log('App Started');
    return Sizer(
      builder: (context,orientation, deviceType) {
        return MaterialApp(
                builder: (context, widget) {
                  return ResponsiveWrapperBuilder(context, widget);
                },
                home: BlocBuilder<AuthenticationBloc,AuthenticationState>(
                        builder: (context,state){
                          SizeConfig().init(context);
                          if (state is AuthenticationFailure) {
                            return LoginScreen();
                          }
                          if (state is AuthenticationSuccess) {
                            return FutureBuilder(
                              builder: (context, data) {
                                if (data.data == true) {

                                  return LaunchIconBadger();
                                } else if (data.data == false){
                                  return CompleteProfile(userRepository: widget.userRepository,);
                                }
                                return Loading();
                              },
                              future: DatabaseService(uid: state.firebaseUser?.uid).checkUserHasProfile(),
                            );
                          } else {
                            return LoginScreen();
                          }
                        }),
                debugShowCheckedModeBanner: false,
                theme:  ThemeDataBuilder(),
                navigatorKey: locator<NavigationService>().navigationKey,
                onGenerateRoute: generateRoute,
                navigatorObservers: [
                  FirebaseAnalyticsObserver(analytics: analytics)
                ],
              );
      }
    );
  }


}
