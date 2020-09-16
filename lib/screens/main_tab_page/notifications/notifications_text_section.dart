import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';

class NotificationsTextSection extends StatelessWidget{
  final NotificationData notification;

  NotificationsTextSection({this.notification});



  @override
  Widget build(BuildContext context) {

    var notificationType = {
      'Activity' : notificationType1(),
      'Lodging' : notificationType1(),
      'joinRequest': notificationType2(context),
      'Invite' : notificationType2(context),
      'Follow' : notificationType3(context)
    };

    return notificationType[notification.type];
  }

  Widget notificationType1(){
    return Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch)),
        onTap: (){
          print('card tapped');
        },
      ),
    );
  }

  Widget notificationType2(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    return Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch)),
        trailing: IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () async{
            String fieldID = notification.fieldID;
            CloudFunction().joinTrip(notification.documentID, notification.uid);
            DatabaseService(uid: user.uid).removeNotificationData(fieldID);
            _showDialog(context);
          },
        ),
        onTap: (){
          print('card tapped');
        },
      ),
    );
  }

  Widget notificationType3(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    return Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch)),
        trailing: IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () async{
            String fieldID = notification.fieldID;
            DatabaseService(uid: user.uid).followUser(notification.documentID);
            DatabaseService(uid: user.uid).removeNotificationData(fieldID);
            _showDialog(context);
          },
        ),
        onTap: (){
          print('card tapped');
        },
      ),
    );
  }


  String readTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('MMM d HH:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = date.difference(now);
    var time = '';
    if (diff.inDays == 0) {
      time = format.format(date);
    } else {
      if ((diff.inDays).abs() == 1) {
        time = '1 DAY AGO';
      } else {
        time = (diff.inDays).abs().toString() + ' DAYS AGO';
      }
    }

    return time;
  }

  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Request accepted.')));
  }
}