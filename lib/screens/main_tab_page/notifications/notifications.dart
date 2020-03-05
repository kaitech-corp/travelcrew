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
      child: Container (
        child: NotificationList(),
      ),
    );
  }
}