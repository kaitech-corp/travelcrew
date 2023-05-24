import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../../../services/database.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../models/lodging_model/lodging_model.dart';
import '../../../models/trip_model/trip_model.dart';


/// Lodging menu button
class LodgingMenuButton extends StatelessWidget {
  const LodgingMenuButton(
      {Key? key, required this.trip, required this.lodging, this.event})
      : super(key: key);

  final Trip trip;
  final LodgingModel lodging;
  final Event? event;

  @override
  Widget build(BuildContext context) {
    return lodging.uid == userService.currentUserID
        ? PopupMenuButton<String>(
            icon: const IconThemeWidget(
              icon: Icons.more_horiz,
            ),
            onSelected: (String value) {
              // switch (value) {
              //   case 'Edit':
              //     {
              //       navigationService.navigateTo(EditLodgingRoute,
              //           arguments: EditLodgingArguments(lodging, trip));
              //     }
              //     break;
              //   case 'View':
              //     {
              //       if (lodging.link.isNotEmpty) {
              //         TCFunctions().launchURL(lodging.link);
              //       }
              //     }
              //     break;
              //   case 'Split':
              //     {
              //       SplitPackage().splitItemAlert(
              //           context,
              //           SplitObject(
              //               itemDocID: lodging.fieldID,
              //               tripDocID: trip.documentId,
              //               users: trip.accessUsers,
              //               itemName: lodging.lodgingType,
              //               itemDescription: lodging.comment,
              //               amountRemaining: 0,
              //               itemType: 'Lodging',
              //               dateCreated: DateTime.now(),
              //               details: '',
              //               userSelectedList: <String>[],
              //               itemTotal: 0,
              //               lastUpdated: DateTime.now(),
              //               purchasedByUID: ''),
              //           trip: trip);
              //     }
              //     break;
              //   case 'Calendar':
              //     {
              //       Add2Calendar.addEvent2Cal(event!);
              //     }
              //     break;
              //   default:
              //     {
              //       CloudFunction()
              //           .removeLodging(trip.documentId, lodging.fieldID);
              //     }
              //     break;
              // }
            },
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
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
                value: 'Split',
                child: ListTile(
                  leading: IconThemeWidget(icon: Icons.attach_money),
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
              const PopupMenuItem<String>(
                value: 'Delete',
                child: ListTile(
                  leading: IconThemeWidget(icon: Icons.delete),
                  title: Text('Delete Lodging'),
                ),
              ),
            ],
          )
        : PopupMenuButton<String>(
            icon: const IconThemeWidget(
              icon: Icons.more_horiz,
            ),
            onSelected: (String value) {
              // switch (value) {
              //   case 'Edit':
              //     {
              //       // navigationService.navigateTo(EditLodgingRoute,
              //       //     arguments: EditLodgingArguments(lodging, trip));
              //     }
              //     break;
              //   case 'report':
              //     {
              //       // TravelCrewAlertDialogs().reportAlert(
              //       //     context: context,
              //       //     lodgingData: lodging,
              //       //     type: 'lodging');
              //     }
              //     break;
              //   case 'View':
              //     {
              //       // if (lodging.link.isNotEmpty) {
              //       //   TCFunctions().launchURL(lodging.link);
              //       }
              //     }
              //     break;
              //   case 'Split':
              //     {
              //       SplitPackage().splitItemAlert(
              //           context,
              //           SplitObject(
              //               itemDocID: lodging.fieldID,
              //               tripDocID: trip.documentId,
              //               users: trip.accessUsers,
              //               itemName: lodging.lodgingType,
              //               itemDescription: lodging.comment,
              //               amountRemaining: 0,
              //               itemType: 'Lodging',
              //               dateCreated: DateTime.now(),
              //               details: '',
              //               userSelectedList: <String>[],
              //               itemTotal: 0,
              //               lastUpdated: DateTime.now(),
              //               purchasedByUID: ''),
              //           trip: trip);
              //     }
              //     break;
              //   case 'Calendar':
              //     {
              //       Add2Calendar.addEvent2Cal(event!);
              //     }
              //     break;
              //   default:
              //     {}
              //     break;
              // }
            },
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: 'report',
                child: ListTile(
                  leading: IconThemeWidget(icon: Icons.report),
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
                  leading: IconThemeWidget(icon: Icons.people),
                  title: Text('View Link'),
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
