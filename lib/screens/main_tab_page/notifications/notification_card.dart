import 'package:flutter/material.dart';
import 'package:travelcrew/models/notification_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';

class NotificationsCard extends StatelessWidget{
  final NotificationData notification;
  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  NotificationsCard({this.notification});


  @override
  Widget build(BuildContext context) {

    var notificationType = {
      'Activity' : notificationType1(context),
      'Lodging' : notificationType1(context),
      'Travel' :notificationType1(context),
      'joinRequest': notificationType2(context),
      'Follow' : notificationType3(context),
      'Welcome': notificationType4(context),
      'Invite' : notificationType5(context),
      'Follow_back': notificationType4(context)
    };

    return notificationType[notification.type];
  }
// Activity or Lodging Notifications
  Widget notificationType1(BuildContext context){
    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        onTap: () async {
          if(notification.ispublic){
            Trip trip = await DatabaseService().getTrip(notification.documentID);
            navigationService.navigateTo(ExploreRoute,arguments: trip);
          } else {
            Trip trip = await DatabaseService().getPrivateTrip(notification.documentID);
            navigationService.navigateTo(ExploreRoute,arguments: trip);
          }
        },
      ),
    );
  }
// Join Request
  Widget notificationType2(BuildContext context) {

    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: IconThemeWidget(icon:Icons.add_circle),
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
// Follow Request Notification
  Widget notificationType3(BuildContext context) {

    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: IconThemeWidget(icon:Icons.person_add),
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
// Welcome or Follow back Notification
  Widget notificationType4(BuildContext context){
    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
      ),
    );
  }
// Invitation Notification
  Widget notificationType5(BuildContext context) {

    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text('${notification.message}'),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: IconThemeWidget(icon:Icons.add_circle),
          onPressed: () async{
            String fieldID = notification.fieldID;
            CloudFunction().joinTripInvite(notification.documentID, notification.uid, notification.ispublic);
            CloudFunction().removeNotificationData(fieldID);
            _showDialog(context);
          },
        ),
        onTap: () async {
          if(notification.ispublic){
            Trip trip = await DatabaseService().getTrip(notification.documentID);
            navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
          }
        },
      ),
    );
  }

  _showDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Request accepted.')));
  }
}

