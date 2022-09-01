import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/custom_objects.dart';
import '../../../models/notification_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/locator.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../alerts/alert_dialogs.dart';


/// Layout for notifications
class NotificationsCard extends StatelessWidget{
  NotificationsCard({required this.notification});
  final NotificationData notification;
  final UserPublicProfile currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();


  @override
  Widget build(BuildContext context) {

    final Map<String, Widget> notificationType = {
      'Activity' : notificationType1(context),
      'Lodging' : notificationType1(context),
      'Travel' :notificationType1(context),
      'joinRequest': notificationType2(context),
      'Follow' : notificationType3(context),
      'Welcome': notificationType4(context),
      'Invite' : notificationType5(context),
      'Follow_back': notificationType4(context),
      'Chat': notificationType6(context)
    };

    return notificationType[notification.type]!;
  }
// Activity or Lodging Notifications
  Widget notificationType1(BuildContext context){
    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text(notification.message),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        onTap: () async {
          if(notification.ispublic){
            final Trip trip = await DatabaseService().getTrip(notification.documentID);
            navigationService.navigateTo(ExploreRoute,arguments: trip);
          } else {
            final Trip trip = await DatabaseService().getPrivateTrip(notification.documentID);
            navigationService.navigateTo(ExploreRoute,arguments: trip);
          }
        },
      ),
    );
  }
// Join Request
  Widget notificationType2(BuildContext context) {

    return InkWell(
      onTap: () async {
        final Trip trip = await DatabaseService().getTrip(notification.documentID);
        navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
      },
      child: Card(
        color: Colors.white,
        key: Key(notification.fieldID),
        child: ListTile(
          title: Text(notification.message),
          subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
          trailing: IconButton(
            icon: const IconThemeWidget(icon:Icons.add_circle),
            onPressed: () async{
              final String fieldID = notification.fieldID;
              CloudFunction().joinTrip(notification.documentID, notification.ispublic,notification.uid);
              CloudFunction().removeNotificationData(fieldID);
              _showDialog(context);
            },
          ),
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
        title: Text(notification.message),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: const IconThemeWidget(icon:Icons.person_add),
          onPressed: () async{
            final String fieldID = notification.fieldID;
            CloudFunction().followUser(notification.uid);
            CloudFunction().removeNotificationData(fieldID);
            if (!currentUserProfile.following!.contains(notification.uid)) {
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
        title: Linkify(
          onOpen: (LinkableElement link) async {
            if (await canLaunch(link.url)) {
              await launch(link.url);
            } else {
              throw 'Could not launch $link';
            }
          },
          text: notification.message,
          style: Theme.of(context).textTheme.subtitle1,
          // textScaleFactor: 1.2,
          maxLines: 50,
          overflow: TextOverflow.ellipsis,
          linkStyle: const TextStyle(color: Colors.blue),
          textAlign: TextAlign.left,
        ),
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
        title: Text(notification.message),
        subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        trailing: IconButton(
          icon: const IconThemeWidget(icon:Icons.add_circle),
          onPressed: () async{
            final String fieldID = notification.fieldID;
            CloudFunction().joinTripInvite(notification.documentID, notification.uid, notification.ispublic);
            CloudFunction().removeNotificationData(fieldID);
            _showDialog(context);
          },
        ),
        onTap: () async {
          if(notification.ispublic){
            final Trip trip = await DatabaseService().getTrip(notification.documentID);
            navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
          }
        },
      ),
    );
  }
  // Chat Notification
  Widget notificationType6(BuildContext context){
    return InkWell(
      onTap: () async {
        final Trip trip = await DatabaseService().getTrip(notification.documentID);
        navigationService.navigateTo(ExploreRoute,arguments: trip);

      },
      child: Card(
        color: Colors.white,
        key: Key(notification.fieldID),
        child: ListTile(
          title: Text(notification.message),
          subtitle: Text(TCFunctions().readTimestamp(notification.timestamp.millisecondsSinceEpoch),style: Theme.of(context).textTheme.subtitle2,),
        ),
      ),
    );
  }

  _showDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request accepted.')));
  }
}

