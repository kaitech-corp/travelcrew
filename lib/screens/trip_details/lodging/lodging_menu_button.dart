import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../../models/lodging_model.dart';
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

/// Lodging menu button
class LodgingMenuButton  extends StatelessWidget{

  const LodgingMenuButton({Key? key, required this.trip, required this.lodging, this.event}) : super(key: key);

  final Trip trip;
  final LodgingData lodging;
  final Event? event;

  @override
  Widget build(BuildContext context) {
    return lodging.uid == userService.currentUserID ? PopupMenuButton<String>(
      icon: const IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (String value){
        switch (value){
          case 'Edit': {
            navigationService.navigateTo(EditLodgingRoute,arguments: EditLodgingArguments(lodging, trip));
          }
          break;
          case 'View': {
            if(lodging.link?.isNotEmpty ?? false) TCFunctions().launchURL(lodging.link!);
          }
          break;
          case 'Split': {
            SplitPackage().splitItemAlert(context,
                SplitObject(
                    itemDocID:lodging.fieldID,
                    tripDocID: trip.documentId,
                    users: trip.accessUsers,
                    itemName: lodging.lodgingType,
                    itemDescription: lodging.comment,
                    amountRemaining: 0,
                    itemType: 'Lodging'),
                trip: trip);
          }
          break;
          case 'Calendar':
            {
              Add2Calendar.addEvent2Cal(event!);
            }
          break;
          default: {
            CloudFunction().removeLodging(trip.documentId,lodging.fieldID!);
          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) =>[
        const PopupMenuItem(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.edit),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'View',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.people),
            title: Text('View Link'),
          ),
        ),
        const PopupMenuItem(
          value: 'Split',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.attach_money),
            title: Text('Split'),
          ),
        ),
        const PopupMenuItem(
          value: 'Calendar',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.calendar_today_outlined),
            title: Text('Save to Calendar'),
          ),
        ),
        const PopupMenuItem(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.delete),
            title: Text('Delete Lodging'),
          ),
        ),
      ],
    ):
    PopupMenuButton<String>(
      icon: const IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (String value){
        switch (value){
          case 'Edit': {
            navigationService.navigateTo(EditLodgingRoute,arguments: EditLodgingArguments(lodging, trip));
          }
          break;
          case 'report':
            {
              TravelCrewAlertDialogs().reportAlert(context: context, lodgingData: lodging, type: 'lodging');
            }
            break;
          case 'View': {
            if (lodging.link?.isNotEmpty ?? false) {
              TCFunctions().launchURL(lodging.link!);
            }
          }
          break;
          case 'Split': {
            SplitPackage().splitItemAlert(context,
                SplitObject(
                    itemDocID:lodging.fieldID,
                    tripDocID: trip.documentId,
                    users: trip.accessUsers,
                    itemName: lodging.lodgingType,
                    itemDescription: lodging.comment,
                    amountRemaining: 0,
                    itemType: 'Lodging'),
                trip: trip);
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
      itemBuilder: (BuildContext context) =>[
        const PopupMenuItem(
          value: 'report',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.report),
            title: Text('Report'),
          ),
        ),
        const PopupMenuItem(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.edit),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'View',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.people),
            title: Text('View Link'),
          ),
        ),
        const PopupMenuItem(
          value: 'Split',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.attach_money),
            title: Text('Split'),
          ),
        ),
        const PopupMenuItem(
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