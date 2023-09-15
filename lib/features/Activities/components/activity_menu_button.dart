import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';


import '../../../models/activity_model/activity_model.dart';
import '../../../models/split_model/split_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../Split/split_package.dart';



class ActivityMenuButton extends StatelessWidget {
  const ActivityMenuButton({super.key, required this.activity, required this.trip, this.event});

  final ActivityModel activity;
  final Trip trip;
  final Event? event;

  void handleMenuItemSelection(String value, BuildContext context) {
    switch (value) {
      case 'Edit':
        navigationService.navigateTo(EditActivityRoute, arguments: EditActivityArguments(activity, trip));
        break;
      case 'View':
        if (activity.link.isNotEmpty) {
          TCFunctions().launchURL(activity.link);
        }
        break;
      case 'Split':
        SplitPackage().splitItemAlert(
          context,
          SplitObject(
            itemDocID: activity.fieldID,
            tripDocID: trip.documentId,
            users: trip.accessUsers,
            itemName: activity.activityType,
            itemDescription: activity.comment,
            amountRemaining: 0,
            itemType: 'Activity',
            dateCreated: DateTime.now(),
            details: '',
            userSelectedList: <String>[],
            itemTotal: 0,
            lastUpdated: DateTime.now(),
            purchasedByUID: '',
          ),
          trip: trip,
        );
        break;
      case 'Calendar':
        Add2Calendar.addEvent2Cal(event!);
        break;
      case 'Delete':
        CloudFunction().removeActivity(trip.documentId, activity.fieldID);
        break;
      case 'report':
        // TravelCrewAlertDialogs().reportAlert(context: context, activityData: activity, type: 'activity');
        break;
    }
  }

  List<PopupMenuItem<String>> getMenuItems(BuildContext context) {
    final List<PopupMenuItem<String>> menuItems = <PopupMenuItem<String>>[
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
          leading: IconThemeWidget(icon: Icons.attach_money),
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
    ];

    if (activity.uid != userService.currentUserID) {
      menuItems.insert(
        0,
        const PopupMenuItem<String>(
          value: 'report',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.report),
            title: Text('Report'),
          ),
        ),
      );
    }

    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const IconThemeWidget(icon: Icons.more_horiz),
      onSelected: (String value) => handleMenuItemSelection(value, context),
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => getMenuItems(context),
    );
  }
}

