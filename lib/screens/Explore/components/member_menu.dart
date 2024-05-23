import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../../models/trip_model/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../Alerts/alert_dialogs.dart';
import '../logic/logic.dart';

class PopupMemberMenuButtonWidget extends StatelessWidget {
  const PopupMemberMenuButtonWidget({
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
          case 'Report':
            {
              TravelCrewAlertDialogs().reportAlert(
                  context: context, tripDetails: trip, type: 'trip');
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
          case 'Leave':
            {
              TravelCrewAlertDialogs()
                  .leaveTripAlert(context, userService.currentUserID, trip);
            }
            break;
          default:
            {}
            break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        const PopupMenuItem<String>(
          value: 'Report',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.report),
            title: Text('Report'),
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
        const PopupMenuItem<String>(
          value: 'Leave',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.exit_to_app),
            title: Text('Leave Group'),
          ),
        ),
      ],
    );
  }
}
