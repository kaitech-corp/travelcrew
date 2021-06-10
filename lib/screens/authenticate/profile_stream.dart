import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/main_tab_page.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/firebase_messaging.dart';


class ProfileStream extends StatelessWidget{
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override

  @override
  Widget build(BuildContext context) {
    // _firebaseMessaging.requestPermission();


    final user = Provider.of<User>(context);

    return StreamProvider<UserPublicProfile>.value(
      value: DatabaseService(uid: user.uid).currentUserPublicProfile,
      child: build2(context),
    );
  }
//Pulls in notifications to show badge count.
  Widget build2(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamProvider<List<NotificationData>>.value(
      value: DatabaseService(uid: user.uid).notificationList,
      child: Container (
        child: MainTabPage(),
      ),
    );
  }
}
