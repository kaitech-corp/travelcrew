import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';
import 'notifications_text_section.dart';

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();

}

class _NotificationListState extends State<NotificationList> {
  @override
  Widget build(BuildContext context) {

    final notifications = Provider.of<List<NotificationData>>(context);
    final user = Provider.of<UserProfile>(context);

    return ListView.builder(
        itemCount: notifications != null ? notifications.length : 0,
        itemBuilder: (context, index){
          var item = notifications[index];
          return Dismissible(
            // Show a red background as the item is swiped away.
            background: Container(color: Colors.red),
            key: Key(item.documentID),
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
                DatabaseService(uid: user.uid).removeNotificationData(item.fieldID);
              });

              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text("Notification removed.")));
            },
            child: NotificationsTextSection(notification: notifications[index]),
          );
        });
  }
}