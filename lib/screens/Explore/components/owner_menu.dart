import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../../models/trip_model/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../Alerts/alert_dialogs.dart';
import '../logic/logic.dart';

class PopupOwnerMenuButtonWidget extends StatelessWidget {
  const PopupOwnerMenuButtonWidget({
    super.key,
    required this.trip,
    required this.event,
  });

  final Trip trip;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const IconThemeWidget(
        icon: Icons.more_horiz,
      ),
      onSelected: (String value) {
        switch (value) {
          case 'Edit':
            {
              navigationService.navigateTo(EditTripDataRoute, arguments: trip);
            }
            break;
          case 'Calendar':
            {
              Add2Calendar.addEvent2Cal(event);
            }
            break;
          case 'Invite':
            {
              navigationService.navigateTo(FollowingListRoute, arguments: trip);
            }
            break;
          case 'Share':
            {
              shareTrip(context, trip.ispublic, trip.documentId);
            }
            break;
          case 'Convert':
            {
              TravelCrewAlertDialogs().convertTripAlert(context, trip);
            }
            break;
          case 'Delete':
            {
              TravelCrewAlertDialogs().deleteTripAlert(context, trip);
            }
          default:
            {}
            break;
        }
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
          value: 'Calendar',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.calendar_today_outlined),
            title: Text('Save to Calendar'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Invite',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.person_add),
            title: Text('Invite'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Share',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.share),
            title: Text('Share'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Convert',
          child: ListTile(
            leading: trip.ispublic
                ? const IconThemeWidget(icon: Icons.do_not_disturb_on)
                : const IconThemeWidget(icon: Icons.do_not_disturb_off),
            title: trip.ispublic
                ? const Text('Make Private')
                : const Text('Make Public'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.exit_to_app),
            title: Text('Delete Trip'),
          ),
        ),
      ],
    );
  }
}
