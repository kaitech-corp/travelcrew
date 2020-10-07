import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/stream_to_explore.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';

class NotificationsTextSection extends StatelessWidget{
  final NotificationData notification;

  NotificationsTextSection({this.notification});

  var userService = locator<UserService>();

  @override
  Widget build(BuildContext context) {

    var notificationType = {
      'Activity' : notificationType1(context),
      'Lodging' : notificationType1(context),
      'joinRequest': notificationType2(context),
      'Follow' : notificationType3(context),
      'Welcome': notificationType4(context),
      'Invite' : notificationType5(context),
    };

    return notificationType[notification.type];
  }

  Widget notificationType1(BuildContext context){
    return Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        onTap: () async {
          if(notification.ispublic){
            Trip trip = await DatabaseService().getTrip(notification.documentID);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StreamToExplore(trip: trip,)),
            );
          } else {
            Trip trip = await DatabaseService().getPrivateTrip(notification.documentID);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StreamToExplore(trip: trip,)),
            );
          }
        },
      ),
    );
  }

  Widget notificationType2(BuildContext context) {

    return Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () async{
            String fieldID = notification.fieldID;
            CloudFunction().joinTrip(notification.documentID, notification.ispublic,notification.uid);
            CloudFunction().removeNotificationData(fieldID);
            // DatabaseService(uid: userService.currentUserID).removeNotificationData(fieldID);
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

    return Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () async{
            String fieldID = notification.fieldID;
            CloudFunction().followUser(notification.uid);
            CloudFunction().removeNotificationData(fieldID);
            // DatabaseService(uid: userService.currentUserID).followUser(notification.documentID);
            // DatabaseService(uid: userService.currentUserID).removeNotificationData(fieldID);
            _showDialog(context);
          },
        ),
        onTap: (){
          print('card tapped');
        },
      ),
    );
  }

  Widget notificationType4(BuildContext context){
    return Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        onTap: (){
          print('card tapped');
        },
      ),
    );
  }

  Widget notificationType5(BuildContext context) {

    return Card(
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () async{
            String fieldID = notification.fieldID;
            CloudFunction().joinTripInvite(notification.documentID, notification.uid, notification.ispublic);
            CloudFunction().removeNotificationData(fieldID);
            // DatabaseService(uid: userService.currentUserID).removeNotificationData(fieldID);
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

