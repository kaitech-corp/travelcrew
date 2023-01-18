import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/activity_model.dart';
import '../../../models/split_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../alerts/alert_dialogs.dart';
import '../split/split_package.dart';

class ActivityMenuButton extends StatelessWidget{

  const ActivityMenuButton({Key? key, required this.activity, required this.trip, this.event}) : super(key: key);

  final ActivityData activity;
  final Trip trip;
  final Event? event;

  @override
  Widget build(BuildContext context) {
    return activity.uid == userService.currentUserID ? PopupMenuButton<String>(
      icon: const IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (String value){
        switch (value){
          case 'Edit': {
            navigationService.navigateTo(EditActivityRoute, arguments: EditActivityArguments(activity, trip));
          }
          break;
          case 'View': {
            if(activity.link.isNotEmpty) {
              TCFunctions().launchURL(activity.link);
            }
          }
          break;
          case 'Split': {
            SplitPackage().splitItemAlert(context,
                SplitObject(itemDocID:activity.fieldID,
                    tripDocID: trip.documentId,
                    users: trip.accessUsers,
                    itemName: activity.activityType,
                    itemDescription: activity.comment,
                    amountRemaining: 0,
                    itemType: 'Activity', dateCreated: Timestamp.now(), details: '', userSelectedList: <String>[],  itemTotal: 0, lastUpdated: Timestamp.now(), purchasedByUID: ''),
                trip: trip);

          }
          break;
          case 'Calendar':
            {
              Add2Calendar.addEvent2Cal(event!);
            }
          break;
          default: {
            CloudFunction().removeActivity(trip.documentId,activity.fieldID);
          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) =><PopupMenuItem<String>>[
        const PopupMenuItem<String>(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.edit),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'View',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.people),
            title: Text('View Link'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Calendar',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.calendar_today_outlined),
            title: Text('Save to Calendar'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Split',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.attach_money),
            title: Text('Split'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.delete),
            title: Text('Delete Activity'),
          ),
        ),
      ],
    ):
    PopupMenuButton<String>(
      icon: const IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (String value){
        switch (value){
          case 'Edit': {
            navigationService.navigateTo(EditActivityRoute, arguments: EditActivityArguments(activity, trip));
          }
          break;
          case 'report':
            {
              TravelCrewAlertDialogs().reportAlert(context: context, activityData: activity, type: 'activity');
            }
            break;
          case 'View': {
            if (activity.link.isNotEmpty) {
              TCFunctions().launchURL(activity.link);
            }
          }
          break;
          case 'Split': {
            // if (false) {
            SplitPackage().splitItemExist(context,
                SplitObject(
                    itemDocID:activity.fieldID,
                    tripDocID: trip.documentId,
                    users: trip.accessUsers,
                    itemName: activity.activityType,
                    itemDescription: activity.comment,
                    amountRemaining: 0.01,
                    itemType: 'Activity', dateCreated: Timestamp.now(), details: '', userSelectedList: <String>[], itemTotal: 0, lastUpdated: Timestamp.now(), purchasedByUID: '' ),
                trip: trip
            );
          }
          break;
          case 'Calendar':
            {
              Add2Calendar.addEvent2Cal(event!);
            }
            break;
          default: {
          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) =><PopupMenuItem<String>>[
        const PopupMenuItem<String>(
          value: 'report',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.report),
            title: Text('Report'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.edit),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'View',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.link),
            title: Text('View Link'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Split',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.attach_money),
            title: Text('Split'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Calendar',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.calendar_today_outlined),
            title: Text('Save to Calendar'),
          ),
        ),
      ],
    );
  }
}
