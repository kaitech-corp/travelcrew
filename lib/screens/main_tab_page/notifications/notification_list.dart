import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'notifications_text_section.dart';

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();

}

class _NotificationListState extends State<NotificationList> {
  @override
  Widget build(BuildContext context) {

    final notifications = Provider.of<List<NotificationData>>(context);


    return ListView.builder(
        itemCount: notifications != null ? notifications.length : 0,
        itemBuilder: (context, index){
          return NotificationsTextSection(notification: notifications[index]);
        });
  }
}