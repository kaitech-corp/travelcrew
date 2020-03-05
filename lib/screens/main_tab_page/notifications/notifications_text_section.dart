import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';

class NotificationsTextSection extends StatelessWidget{
  final NotificationData notification;

  NotificationsTextSection({this.notification});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);

    return notification.type != 'joinRequest' ? Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch)),
      ),
    ):
    Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch)),
        trailing: IconButton(
         icon: Icon(Icons.add_circle),
          onPressed: () async{
            String fieldID = notification.fieldID;
            DatabaseService(tripDocID: notification.documentID, uid: notification.uid).joinTrip();
            DatabaseService(uid: user.uid).removeNotificationData(fieldID);
            _showDialog(context);
          print('Pressed');
          },
        ),
      ),
    );
  }
  String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('HH:mm a');
    var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + 'DAY AGO';
      } else {
        time = diff.inDays.toString() + 'DAYS AGO';
      }
    }

    return time;
  }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Request accepted.')));
  }
}