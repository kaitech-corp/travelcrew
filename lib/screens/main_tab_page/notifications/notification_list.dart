import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'notifications_text_section.dart';



class NotificationList extends StatefulWidget {

  NotificationList();

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
          var item = notifications[index];

          return Dismissible(
            direction: DismissDirection.endToStart,
            // Show a red background as the item is swiped away.
            background: Container(color: Colors.red,
              alignment: AlignmentDirectional.centerStart,
              child: const Align(
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete,
                color: Colors.white,),
              )),
            key: UniqueKey(),
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
                CloudFunction().removeNotificationData(item.fieldID);
              });
              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: const Text("Notification removed.")));
            },

            child: NotificationsTextSection(notification: notifications[index],),
          );
        });
  }
}

class NotificationCount extends StatefulWidget{
  final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);

  NotificationCount();
  @override
  _NotificationCountState createState() => _NotificationCountState();
}
class _NotificationCountState extends State<NotificationCount> {
  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<List<NotificationData>>(context);

    return ListView.builder(
        itemCount: notifications != null ? notifications.length : 0,
        itemBuilder: (context, index) {
          return NotificationsTextSection(notification: notifications[index]);
        });
  }

}

