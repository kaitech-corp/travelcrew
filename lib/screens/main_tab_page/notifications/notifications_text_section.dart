import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/explore/explore.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/tc_functions.dart';

class NotificationsTextSection extends StatelessWidget{
  final NotificationData notification;

  NotificationsTextSection({this.notification});

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

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
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        onTap: () async {
          if(notification.ispublic){
            Trip trip = await DatabaseService().getTrip(notification.documentID);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Explore(trip: trip,)),
            );
          } else {
            Trip trip = await DatabaseService().getPrivateTrip(notification.documentID);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Explore(trip: trip,)),
            );
          }
        },
      ),
    );
  }

  Widget notificationType2(BuildContext context) {

    return Card(
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () async{
            String fieldID = notification.fieldID;
            CloudFunction().joinTrip(notification.documentID, notification.ispublic,notification.uid);
            CloudFunction().removeNotificationData(fieldID);
            _showDialog(context);
          },
        ),
      ),
    );
  }

  Widget notificationType3(BuildContext context) {

    return Card(
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () async{
            String fieldID = notification.fieldID;
            CloudFunction().followUser(notification.uid);
            CloudFunction().removeNotificationData(fieldID);
            if (!currentUserProfile.following.contains(notification.uid)) {
              TravelCrewAlertDialogs().followBackAlert(context, notification.uid);
            }
          },
        ),
      ),
    );
  }

  Widget notificationType4(BuildContext context){
    return Card(
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
      ),
    );
  }

  Widget notificationType5(BuildContext context) {

    return Card(
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () async{
            String fieldID = notification.fieldID;
            CloudFunction().joinTripInvite(notification.documentID, notification.uid, notification.ispublic);
            CloudFunction().removeNotificationData(fieldID);
            _showDialog(context);
          },
        ),
      ),
    );
  }

  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: const Text('Request accepted.')));
  }
}

