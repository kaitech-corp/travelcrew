import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/main_tab_page.dart';
import 'package:travelcrew/services/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class ProfileStream extends StatelessWidget{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override

  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.requestNotificationPermissions();

    final user = Provider.of<User>(context);

    return StreamProvider<UserProfile>.value(
      value: DatabaseService(uid: user.uid).currentUserPublicProfile,
      child: build2(context),
    );
  }

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
