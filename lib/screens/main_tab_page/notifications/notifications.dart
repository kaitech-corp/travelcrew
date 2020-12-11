import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/main_tab_page/notifications/notification_list.dart';
import 'package:travelcrew/services/database.dart';

class Notifications extends StatelessWidget{

  Notifications();

  @override
  Widget build(BuildContext context) {

    return StreamProvider<List<NotificationData>>.value(
      value: DatabaseService().notificationList,
      child: Scaffold(
        body: Container (
          child: NotificationList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            TravelCrewAlertDialogs().deleteNotificationsAlert(context);
          },
          child: const Text('Clear All',textAlign: TextAlign.center,),

        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),

    );
  }

}