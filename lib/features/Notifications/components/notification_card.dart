// ignore_for_file: only_throw_errors

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/locator.dart';
import '../../../../services/navigation/route_names.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../models/notification_model/notification_model.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/functions/tc_functions.dart';
import '../../Alerts/alert_dialogs.dart';
import '../../Trip_Management/logic/logic.dart';


/// Layout for notifications
class NotificationsCard extends StatelessWidget {
  NotificationsCard({Key? key, required this.notification}) : super(key: key);
  final NotificationModel notification;
  final UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget> notificationType = <String, Widget>{
      'Activity': notificationType1(context),
      'Lodging': notificationType1(context),
      'Travel': notificationType1(context),
      'joinRequest': notificationType2(context),
      'Follow': notificationType3(context),
      'Welcome': notificationType4(context),
      'Invite': notificationType5(context),
      'Follow_back': notificationType4(context),
      'Chat': notificationType6(context)
    };

    return notificationType[notification.type]!;
  }

// Activity or Lodging Notifications
  Widget notificationType1(BuildContext context) {
    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: ListTile(
        title: Text(notification.message),
        subtitle: Text(readTimestamp(notification.timestamp!),
          style: titleSmall(context),
        ),
        onTap: () async {
          if (notification.ispublic!) {
            final Trip trip =
                await getTrip(notification.documentID!);
            navigationService.navigateTo(ExploreRoute, arguments: trip);
          } else {
            final Trip trip =
                await getPrivateTrip(notification.documentID!);
            navigationService.navigateTo(ExploreRoute, arguments: trip);
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
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () async {
                final Trip trip =
                    await getTrip(notification.documentID!);
                navigationService.navigateTo(ExploreBasicRoute,
                    arguments: trip);
              },
              child: ListTile(
                title: Text(notification.message),
                subtitle: Text(
                      readTimestamp(notification.timestamp!),
                  style: titleSmall(context),
                ),
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const IconThemeWidget(icon: Icons.add_circle),
              onPressed: () async {
                final String fieldID = notification.fieldID;
                CloudFunction().joinTrip(notification.documentID!,
                    notification.ispublic!, notification.uid);
                CloudFunction().removeNotificationData(fieldID);
                _showDialog(context);
              },
            ),
          ),
        ],
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
        subtitle: Text(readTimestamp(notification.timestamp!),
          style: titleSmall(context),
        ),
        trailing: IconButton(
          icon: const IconThemeWidget(icon: Icons.person_add),
          onPressed: () async {
            final String fieldID = notification.fieldID;
            CloudFunction().followUser(notification.uid);
            CloudFunction().removeNotificationData(fieldID);
            if (!currentUserProfile.following!.contains(notification.uid)) {
              TravelCrewAlertDialogs()
                  .followBackAlert(context, notification.uid);
            }
          },
        ),
      ),
    );
  }

// Welcome or Follow back Notification
  Widget notificationType4(BuildContext context) {
    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: ListTile(
        title: Linkify(
          onOpen: (LinkableElement link) async {
            if (await canLaunchUrl(Uri(path: link.url))) {
              await launchUrl(Uri(path: link.url));
            } else {
              throw 'Could not launch $link';
            }
          },
          text: notification.message,
          style: titleMedium(context),
          // textScaleFactor: 1.2,
          maxLines: 50,
          overflow: TextOverflow.ellipsis,
          linkStyle: const TextStyle(color: Colors.blue),
          textAlign: TextAlign.left,
        ),
        subtitle: Text(notification.timestamp!.toString(),
          style: titleSmall(context),
        ),
      ),
    );
  }

// Invitation Notification
  Widget notificationType5(BuildContext context) {
    return Card(
      color: Colors.white,
      key: Key(notification.fieldID),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () async {
                if (notification.ispublic!) {
                  final Trip trip =
                      await getTrip(notification.documentID!);
                  navigationService.navigateTo(ExploreBasicRoute,
                      arguments: trip);
                }
              },
              child: ListTile(
                title: Text(notification.message),
                subtitle: Text(readTimestamp(notification.timestamp!),
                  style: titleSmall(context),
                ),
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const IconThemeWidget(icon: Icons.add_circle),
              onPressed: () async {
                final String fieldID = notification.fieldID;
                CloudFunction().joinTripInvite(notification.documentID!,
                    notification.uid, notification.ispublic!);
                CloudFunction().removeNotificationData(fieldID);
                _showDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Chat Notification
  Widget notificationType6(BuildContext context) {
    return InkWell(
      onTap: () async {
        final Trip trip =
            await getTrip(notification.documentID!);
        navigationService.navigateTo(ExploreRoute, arguments: trip);
      },
      child: Card(
        color: Colors.white,
        key: Key(notification.fieldID),
        child: ListTile(
          title: Text(notification.message),
          subtitle: Text(readTimestamp(notification.timestamp!),
            style: titleSmall(context),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Request accepted.')));
  }
}
