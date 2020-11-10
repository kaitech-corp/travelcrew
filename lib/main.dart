import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/screens/add_trip/add_trip.dart';
import 'package:travelcrew/screens/add_trip/google_places.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/all_trips_page.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/crew_trips.dart';
import 'package:travelcrew/screens/main_tab_page/favorites/favorites.dart';
import 'package:travelcrew/screens/main_tab_page/main_tab_page.dart';
import 'package:travelcrew/screens/main_tab_page/notifications/notifications.dart';
import 'package:travelcrew/screens/menu_screens/dm_chats/chats_page.dart';
import 'package:travelcrew/screens/menu_screens/help/feedback_page.dart';
import 'package:travelcrew/screens/menu_screens/help/help.dart';
import 'package:travelcrew/screens/menu_screens/help/report.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/menu_screens/users/dm_chat/dm_chat.dart';
import 'package:travelcrew/screens/menu_screens/users/user_profile_page.dart';
import 'package:travelcrew/screens/menu_screens/users/users.dart';
import 'package:travelcrew/screens/profile_page/edit_profile_page.dart';
import 'package:travelcrew/screens/profile_page/profile_page.dart';
import 'package:travelcrew/screens/trip_details/activity/activity.dart';
import 'package:travelcrew/screens/trip_details/activity/edit_activity.dart';
import 'package:travelcrew/screens/trip_details/chat/chat.dart';
import 'package:travelcrew/screens/add_trip/edit_trip.dart';
import 'package:travelcrew/screens/trip_details/explore/explore.dart';
import 'package:travelcrew/screens/trip_details/explore/members/members_layout.dart';
import 'package:travelcrew/screens/trip_details/lodging/edit_lodging.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/push_notifications.dart';
import 'models/custom_objects.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


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
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    setupLocator();
    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    FirebaseMessaging().configure(
        onMessage:
            (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  content: ListTile(
                    title: Text(message['notification']['title']),
                    subtitle: Text(message['notification']['body']),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
          );
        },
      onLaunch: (Map<String, dynamic> message) async {

      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );

  }
  @override
  Widget build(BuildContext context) {

    FirebaseCrashlytics.instance.log('YOUR LOG COMES HERE');

    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Cantata One',textTheme: TextTheme(
          headline1: TextStyle(fontWeight: FontWeight.bold, fontSize: 24,color: Colors.white),
            headline2: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            headline3: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white),
            headline4: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            headline5: TextStyle(fontWeight: FontWeight.w600,color: Colors.white, fontSize: 14),
            headline6: TextStyle(fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
            subtitle1: TextStyle(fontWeight: FontWeight.bold),
            subtitle2: TextStyle(fontWeight: FontWeight.w600),
          button: TextStyle(fontWeight: FontWeight.bold),
        ),
          brightness: Brightness.light,
          primaryColor: Colors.black,
          accentColor: Colors.blueAccent,

        ),
        routes: <String, WidgetBuilder>{
          '/wrapper': (BuildContext context)=> new Wrapper(),
          '/addTrip': (BuildContext context)=> new AddTrip(),
          '/allTrips': (BuildContext context)=> new AllTripsPage(),
          '/crewTrips': (BuildContext context)=> new CrewTrips(),
          '/favorites': (BuildContext context)=> new Favorites(),
          '/notifications': (BuildContext context)=> new Notifications(),
          '/mainTabPage': (BuildContext context)=> new MainTabPage(),
          '/profilePage': (BuildContext context)=> new ProfilePage(),
          '/help': (BuildContext context)=> new HelpPage(),
          '/feedback': (BuildContext context)=> new FeedbackPage(),
          '/reportContent': (BuildContext context)=> new ReportContent(),
          '/mainMenu': (BuildContext context)=> new MainMenuButtons(),
          '/userProfilePage': (BuildContext context)=> new UserProfilePage(),
          '/usersFromMenu': (BuildContext context)=> new Users(),
          '/editProfilePage': (BuildContext context)=> new EditProfilePage(),
          '/activity': (BuildContext context)=> new Activity(),
          '/editActivity': (BuildContext context)=> new EditActivity(),
          '/chat': (BuildContext context)=> new Chat(),
          '/memberLayout': (BuildContext context)=> new MembersLayout(),
          '/editTrip': (BuildContext context)=> new EditTripData(),
          '/explore': (BuildContext context)=> new Explore(),
          '/lodging': (BuildContext context)=> new Lodging(),
          '/editLodging': (BuildContext context)=> new EditLodging(),
          '/googlePlaces': (BuildContext context)=> new GooglePlaces(),
          '/chats_page': (BuildContext context)=> new DMChatListPage(),
        },
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      ),
    );
  }
}
