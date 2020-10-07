import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/locator.dart';
import 'models/custom_objects.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();

  runApp(TravelCrew());
}

class TravelCrew extends StatelessWidget{

  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {

    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Raleway',textTheme: TextTheme(
          headline1: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,),
            headline2: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            headline3: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.white),
            headline6: TextStyle(fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
            subtitle1: TextStyle(fontWeight: FontWeight.bold, ),
            subtitle2: TextStyle(fontWeight: FontWeight.w600),
          button: TextStyle(fontWeight: FontWeight.bold),
        )
        ),
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      ),
    );
  }
}
