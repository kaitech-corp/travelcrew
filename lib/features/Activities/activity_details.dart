import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

import '../../../services/constants/constants.dart';
import '../../../services/functions/calendar_events.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../services/widgets/loading.dart';
import '../../../services/widgets/map_launcher.dart';
import '../../../size_config/size_config.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/functions/date_time_retrieval.dart';
import '../Alerts/alert_dialogs.dart';
import 'components/activity_menu_button.dart';
import 'logic/logic.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({super.key, required this.activity, required this.trip});

  final ActivityModel activity;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activity',
          style: headlineSmall(context),
        ),
        backgroundColor: canvasColor,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          child: ActivityModelLayout(fieldID: activity.fieldID, trip: trip),
        ),
      ),
    );
  }
}

class ActivityModelLayout extends StatelessWidget {
  const ActivityModelLayout({
    super.key,
    required this.fieldID,
    required this.trip,
  });

  final String fieldID;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ActivityModel>(
      stream: getActivity(trip.documentId, fieldID),
      builder: (BuildContext context, AsyncSnapshot<ActivityModel> document) {
        if (document.hasData) {
          final ActivityModel model = document.data!;
          final ActivityModel activity = model;
          final Event event = createEvent(
              activity: activity, type: 'Activity', startDate: activity.startDateTimestamp!,endDate: activity.endDateTimestamp!,);

          return Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(45),
                    bottomRight: Radius.circular(45),
                  ),
                ),
                padding: EdgeInsets.all(SizeConfig.defaultPadding),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        activity.activityType,
                        style: headlineSmall(context),
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
                            icon: Icons.calendar_today),
                        title: Text(
                          DateTimeRetrieval().dateFormatter(activity.startDateTimestamp ?? DateTime(0), activity.endDateTimestamp ?? DateTime(0)),
                      
                          style: titleMedium(context),
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
                          style: titleMedium(context),
                        ),
                        onTap: () {},
                      ),
                    if (activity.startTime.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                            icon: Icons.access_time),
                        title: Text(
                          '${activity.startTime} - ${activity.endTime}',
                          style: titleMedium(context),
                        ),
                        onTap: () {},
                      ),
                    if (activity.location.isNotEmpty)
                      ListTile(
                        leading:
                            const TripDetailsIconThemeWidget(icon: Icons.map),
                        title: Text(
                          activity.location,
                          style: const TextStyle(color: Colors.blue),
                        ),
                        onTap: () {
                          MapSearch().searchAddress(activity.location, context);
                        },
                        onLongPress: () {
                          FlutterClipboard.copy(activity.location).whenComplete(
                              () => TravelCrewAlertDialogs()
                                  .copiedToClipboardDialog(context));
                        },
                      )
                    else
                      ListTile(
                        leading:
                            const TripDetailsIconThemeWidget(icon: Icons.map),
                        title: Text(
                          '...',
                          style: titleMedium(context),
                        ),
                      ),
                    if (activity.comment.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                            icon: Icons.comment),
                        title: Tooltip(
                          message: activity.comment,
                          child: Text(
                            activity.comment,
                            style: titleMedium(context),
                            maxLines: 7,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    else
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                            icon: Icons.comment),
                        title: Tooltip(
                          message: activity.comment,
                          child: Text(
                            '...',
                            style: titleMedium(context),
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
