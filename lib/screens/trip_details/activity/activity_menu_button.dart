import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import '../../../models/activity_model.dart';
import '../../../models/split_model.dart';
import '../../../models/trip_model.dart';
import '../../alerts/alert_dialogs.dart';
import '../split/split_package.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/widgets/appearance_widgets.dart';

class ActivityMenuButton extends StatelessWidget{

  final ActivityData activity;
  final Trip trip;
  final Event event;

  const ActivityMenuButton({Key key, this.activity, this.trip,this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return activity.uid == userService.currentUserID ? PopupMenuButton<String>(
      icon: IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (value){
        switch (value){
          case "Edit": {
            navigationService.navigateTo(EditActivityRoute, arguments: EditActivityArguments(activity, trip));
          }
          break;
          case "View": {
            if(activity.link.isNotEmpty) TCFunctions().launchURL(activity.link);
          }
          break;
          case "Split": {
            SplitPackage().splitItemAlert(context,
                SplitObject(itemDocID:activity.fieldID,
                    tripDocID: trip.documentId,
                    users: trip.accessUsers,
                    itemName: activity.activityType,
                    itemDescription: activity.comment,
                    amountRemaining: 0,
                    itemType: "Activity" ),
                trip: trip);

          }
          break;
          case "Calendar":
            {
              Add2Calendar.addEvent2Cal(event);
            }
          break;
          default: {
            CloudFunction().removeActivity(trip.documentId,activity.fieldID);
          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>[
        const PopupMenuItem(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.edit),
            title: const Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'View',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.people),
            title: const Text('View Link'),
          ),
        ),
        const PopupMenuItem(
          value: 'Calendar',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.calendar_today_outlined),
            title: const Text('Save to Calendar'),
          ),
        ),
        const PopupMenuItem(
          value: 'Split',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.attach_money),
            title: const Text('Split'),
          ),
        ),
        const PopupMenuItem(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.delete),
            title: const Text('Delete Activity'),
          ),
        ),
      ],
    ):
    PopupMenuButton<String>(
      icon: IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (value){
        switch (value){
          case "Edit": {
            navigationService.navigateTo(EditActivityRoute, arguments: EditActivityArguments(activity, trip));
          }
          break;
          case "report":
            {
              TravelCrewAlertDialogs().reportAlert(context: context, activityData: activity, type: 'activity');
            }
            break;
          case "View": {
            if (activity.link.isNotEmpty) {
              TCFunctions().launchURL(activity.link);
            }
          }
          break;
          case "Split": {
            // if (false) {
            SplitPackage().splitItemExist(context,
                SplitObject(
                    itemDocID:activity.fieldID,
                    tripDocID: trip.documentId,
                    users: trip.accessUsers,
                    itemName: activity.activityType,
                    itemDescription: activity.comment,
                    amountRemaining: 0.01,
                    itemType: "Activity" ),
                trip: trip
            );
          }
          break;
          case "Calendar":
            {
              Add2Calendar.addEvent2Cal(event);
            }
            break;
          default: {
          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>[
        const PopupMenuItem(
          value: 'report',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.report),
            title: const Text('Report'),
          ),
        ),
        const PopupMenuItem(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.edit),
            title: const Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'View',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.link),
            title: const Text('View Link'),
          ),
        ),
        const PopupMenuItem(
          value: 'Split',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.attach_money),
            title: const Text('Split'),
          ),
        ),
        const PopupMenuItem(
          value: 'Calendar',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.calendar_today_outlined),
            title: const Text('Save to Calendar'),
          ),
        ),
      ],
    );
  }


}