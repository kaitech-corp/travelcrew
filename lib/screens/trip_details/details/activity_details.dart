import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../../../models/activity_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import '../../alerts/alert_dialogs.dart';
import '../activity/activity_menu_button.dart';

class ActivityDetails extends StatelessWidget {
  final ActivityData activity;
  final Trip trip;

  const ActivityDetails({Key? key, required this.activity, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Activity',
            style: Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: canvasColor,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: ActivityDataLayout(fieldID: activity.fieldID!, trip: trip),
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
    return StreamBuilder(
      stream: DatabaseService(fieldID: fieldID, tripDocID: trip.documentId)
          .activity,
      builder: (context, document) {
        if (document.hasData) {
          ActivityData activity = document.data as ActivityData;
          DateTimeModel timeModel = TCFunctions().addDateAndTime(
              startDate: activity.dateTimestamp!,
              startTime: activity.startTime!,
              endTime: activity.endTime!,
              hasEndDate: false);

          Event event = TCFunctions().createEvent(
              activity: activity, type: "Activity", timeModel: timeModel);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(45)),
                ),
                padding: EdgeInsets.all(SizeConfig.defaultPadding),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        activity.activityType!,
                        style: Theme.of(context).textTheme.headline5,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${activity.displayName}',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      trailing: ActivityMenuButton(
                          activity: activity, trip: trip, event: event),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                    activity.startDateTimestamp != null
                        ? ListTile(
                            leading: TripDetailsIconThemeWidget(
                              icon: Icons.calendar_today,
                            ),
                            title: Text(
                              "${TCFunctions().dateToMonthDayFromTimestamp(activity.startDateTimestamp!)} - "
                              "${TCFunctions().formatTimestamp(activity.endDateTimestamp!, wTime: false)}",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            onTap: () {
                              Add2Calendar.addEvent2Cal(event);
                            },
                          )
                        : ListTile(
                            leading: TripDetailsIconThemeWidget(
                              icon: Icons.calendar_today,
                            ),
                            title: Text(
                              '...',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            onTap: () {},
                          ),
                    if (activity.startTime?.isNotEmpty ?? false)
                      ListTile(
                        leading: TripDetailsIconThemeWidget(
                          icon: Icons.access_time,
                        ),
                        title: Text(
                          '${activity.startTime ?? ''} - ${activity.endTime ?? ''}',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onTap: () {},
                      ),
                    activity.location?.isNotEmpty ?? false
                        ? ListTile(
                            leading: TripDetailsIconThemeWidget(
                              icon: Icons.map,
                            ),
                            title: Text(
                              activity.location!,
                              style: TextStyle(color: Colors.blue),
                            ),
                            onTap: () {
                              MapsLauncher.launchQuery(activity.location!);
                            },
                            onLongPress: () {
                              FlutterClipboard.copy(activity.location!)
                                  .whenComplete(() => TravelCrewAlertDialogs()
                                      .copiedToClipboardDialog(context));
                            },
                          )
                        : ListTile(
                            leading: TripDetailsIconThemeWidget(
                              icon: Icons.map,
                            ),
                            title: Text(
                              '...',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                    activity.comment?.isNotEmpty ?? false
                        ? ListTile(
                            leading: TripDetailsIconThemeWidget(
                              icon: Icons.comment,
                            ),
                            title: Tooltip(
                                message: activity.comment,
                                child: Text(
                                  activity.comment!,
                                  style: Theme.of(context).textTheme.subtitle1,
                                  maxLines: 7,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          )
                        : ListTile(
                            leading: TripDetailsIconThemeWidget(
                              icon: Icons.comment,
                            ),
                            title: Tooltip(
                                message: activity.comment,
                                child: Text(
                                  '...',
                                  style: Theme.of(context).textTheme.subtitle1,
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ),
                  ],
                ),
              ),
              activity.link?.isNotEmpty ?? false
                  ? Expanded(
                      child: Container(
                        padding: EdgeInsets.all(SizeConfig.defaultPadding),
                        width: double.infinity,
                        child: InkWell(
                          child: ViewAnyLink(link: activity.link!,function: (){},),
                          onTap: () {
                            TCFunctions().launchURL(activity.link!);
                          },
                        ),
                      ),
                    )
                  : Container(height: 0,width: 0,),
            ],
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
