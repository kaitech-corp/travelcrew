import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

import '../../../services/constants/constants.dart';
import '../../../services/functions/calendar_events.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../services/widgets/map_launcher.dart';
import '../../../size_config/size_config.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/functions/date_time_retrieval.dart';
import '../Alerts/alert_dialogs.dart';
import 'components/activity_menu_button.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails(
      {super.key, required this.activity, required this.trip});

  final ActivityModel activity;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: canvasColor,
        actions: [
          ActivityMenuButton(activity: activity, trip: trip)
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          child: ActivityDetailsLayout(activity: activity, trip: trip),
        ),
      ),
    );
  }
}

class ActivityDetailsLayout extends StatelessWidget {
  const ActivityDetailsLayout({
    super.key,
    required this.activity,
    required this.trip,
  });

  final ActivityModel activity;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final Event event = createEvent(
      activity: activity,
      type: 'Activity',
      startDate: activity.startDateTimestamp!,
      endDate: activity.endDateTimestamp!,
    );
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              left: defaultPadding, right: defaultPadding),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ListTile(
                      title: Text(
                        activity.activityType,
                        style: headlineSmall(context),
                      ),
                      subtitle: Text(
                        'Created by: ${activity.displayName}',
                        style: titleSmall(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Colors.grey,
                thickness: 2,
              ),
            ],
          ),
        ),
        if (activity.link.isNotEmpty)
          Container(
            padding: EdgeInsets.all(SizeConfig.defaultPadding),
            width: double.infinity,
            child: InkWell(
              child: ViewAnyLink(
                  hash: activity.hashCode,
                  link: activity.link,
                  multiMediaonly: false,
                  function: () {
                    TCFunctions().launchURL(activity.link);
                  }),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(activityImages[0], fit: BoxFit.fill),
            ),
          ),
        Card(
          margin: EdgeInsets.all(SizeConfig.defaultPadding),
          child: Column(
            children: <Widget>[
              if (activity.startDateTimestamp != null)
                ListTile(
                  leading: const TripDetailsIconThemeWidget(
                      icon: Icons.calendar_today),
                  title: Text(
                    DateTimeRetrieval().dateFormatter(
                        activity.startDateTimestamp ?? DateTime(0),
                        activity.endDateTimestamp ?? DateTime(0)),
                    style: labelLarge(context),
                  ),
                  onTap: () {
                    Add2Calendar.addEvent2Cal(event);
                  },
                )
              else
                ListTile(
                  leading: const TripDetailsIconThemeWidget(
                      icon: Icons.calendar_today),
                  title: Text(
                    '...',
                    style: labelLarge(context),
                  ),
                  onTap: () {},
                ),
              if (activity.startTime.isNotEmpty)
                ListTile(
                  leading:
                      const TripDetailsIconThemeWidget(icon: Icons.access_time),
                  title: Text(
                    '${activity.startTime} - ${activity.endTime}',
                    style: labelLarge(context),
                  ),
                  onTap: () {},
                ),
              if (activity.location.isNotEmpty)
                ListTile(
                  leading: const TripDetailsIconThemeWidget(icon: Icons.map),
                  title: Text(
                    activity.location,
                    style: labelLarge(context)?.copyWith(color: Colors.blue),
                  ),
                  onTap: () {
                    MapSearch().searchAddress(activity.location, context);
                  },
                  onLongPress: () {
                    FlutterClipboard.copy(activity.location).whenComplete(() =>
                        TravelCrewAlertDialogs()
                            .copiedToClipboardDialog(context));
                  },
                )
              else
                ListTile(
                  leading: const TripDetailsIconThemeWidget(icon: Icons.map),
                  title: Text(
                    '...',
                    style: labelLarge(context),
                  ),
                ),
              if (activity.comment.isNotEmpty)
                ListTile(
                  leading:
                      const TripDetailsIconThemeWidget(icon: Icons.comment),
                  title: Tooltip(
                    message: activity.comment,
                    child: Text(
                      activity.comment,
                      style: labelLarge(context),
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              else
                ListTile(
                  leading:
                      const TripDetailsIconThemeWidget(icon: Icons.comment),
                  title: Tooltip(
                    message: activity.comment,
                    child: Text(
                      '...',
                      style: labelLarge(context),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
