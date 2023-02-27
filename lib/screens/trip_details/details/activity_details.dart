import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

import '../../../models/activity_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/calendar_events.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../services/widgets/loading.dart';
import '../../../services/widgets/map_launcher.dart';
import '../../../size_config/size_config.dart';
import '../../alerts/alert_dialogs.dart';
import '../activity/activity_menu_button.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({Key? key, required this.activity, required this.trip})
      : super(key: key);
  final ActivityData activity;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Activity',
            style: headlineMedium(context),
          ),
          backgroundColor: canvasColor,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: ActivityDataLayout(fieldID: activity.fieldID, trip: trip),
          ),
        ));
  }
}

class ActivityDataLayout extends StatelessWidget {
  const ActivityDataLayout({
    Key? key,
    required this.fieldID,
    required this.trip,
  }) : super(key: key);

  final String fieldID;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ActivityData>(
      stream: DatabaseService(fieldID: fieldID, tripDocID: trip.documentId)
          .activity,
      builder: (BuildContext context, AsyncSnapshot<ActivityData> document) {
        if (document.hasData) {
          final ActivityData activityData = document.data!;
          final ActivityData activity = activityData;
          final DateTimeModel timeModel = DateTimeModel(
              startDate: activity.startDateTimestamp.toDate(),
              endDate: activity.endDateTimestamp.toDate());

          final Event event = createEvent(
              activity: activity, type: 'Activity', timeModel: timeModel);
          return Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(45)),
                ),
                padding: EdgeInsets.all(SizeConfig.defaultPadding),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        activity.activityType,
                        style: headlineMedium(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        activity.displayName,
                        style: titleMedium(context),
                      ),
                      trailing: ActivityMenuButton(
                          activity: activity, trip: trip, event: event),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                    if (activity.startDateTimestamp != null)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.calendar_today,
                        ),
                        title: Text(
                          '${TCFunctions().dateToMonthDayFromTimestamp(activity.startDateTimestamp)} - '
                          '${TCFunctions().formatTimestamp(activity.endDateTimestamp, wTime: false)}',
                          style: titleMedium(context),
                        ),
                        onTap: () {
                          Add2Calendar.addEvent2Cal(event);
                        },
                      )
                    else
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.calendar_today,
                        ),
                        title: Text(
                          '...',
                          style: titleMedium(context),
                        ),
                        onTap: () {},
                      ),
                    if (activity.startTime.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.access_time,
                        ),
                        title: Text(
                          '${activity.startTime} - ${activity.endTime}',
                          style: titleMedium(context),
                        ),
                        onTap: () {},
                      ),
                    if (activity.location.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.map,
                        ),
                        title: Text(
                          activity.location,
                          style: const TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          MapSearch().searchAddress(activity.location, context);
                          // MapLauncher.(activity.location);
                        },
                        onLongPress: () {
                          FlutterClipboard.copy(activity.location)
                              .whenComplete(() => TravelCrewAlertDialogs()
                                  .copiedToClipboardDialog(context));
                        },
                      )
                    else
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.map,
                        ),
                        title: Text(
                          '...',
                          style: titleMedium(context),
                        ),
                      ),
                    if (activity.comment.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.comment,
                        ),
                        title: Tooltip(
                            message: activity.comment,
                            child: Text(
                              activity.comment,
                              style: titleMedium(context),
                              maxLines: 7,
                              overflow: TextOverflow.ellipsis,
                            )),
                      )
                    else
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.comment,
                        ),
                        title: Tooltip(
                            message: activity.comment,
                            child: Text(
                              '...',
                              style: titleMedium(context),
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                  ],
                ),
              ),
              if (activity.link.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(SizeConfig.defaultPadding),
                    width: double.infinity,
                    child: InkWell(
                      child: ViewAnyLink(
                        link: activity.link,
                        function: () {},
                      ),
                      onTap: () {
                        TCFunctions().launchURL(activity.link);
                      },
                    ),
                  ),
                )
              else
                const SizedBox(
                  height: 0,
                  width: 0,
                ),
            ],
          );
        } else {
          return const Loading();
        }
      },
    );
  }
}
