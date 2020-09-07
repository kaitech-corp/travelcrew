import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/notifications/notification_list.dart';
import 'package:travelcrew/services/database.dart';

class Notifications extends StatelessWidget{

  Notifications();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamProvider<List<NotificationData>>.value(
      value: DatabaseService(uid: user.uid).notificationList,
      child: Scaffold(
        body: Container (
          child: NotificationList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            deleteAlert(context, user.uid);
          },
          child: Text('Clear All',textAlign: TextAlign.center,),

        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),

    );
  }
  deleteAlert(BuildContext context, String uid) {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to clear all notifications?'),
          content: const Text('Join requests and follow requests will also be removed.'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                DatabaseService(uid: uid).removeAllNotificationData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}