import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:nil/nil.dart';

import '../../../models/custom_objects.dart';
import '../../../models/lodging_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/calendar_events.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';
import '../../alerts/alert_dialogs.dart';
import '../lodging/lodging_menu_button.dart';

class LodgingDetails extends StatelessWidget {
  const LodgingDetails({Key? key, required this.lodging, required this.trip})
      : super(key: key);
  final LodgingData lodging;
  final Trip trip;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Lodging',
            style: Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: canvasColor,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: LodgingDataLayout(
              fieldID: lodging.fieldID,
              trip: trip,
            ),
          ),
        ));
  }
}

class LodgingDataLayout extends StatelessWidget {
  const LodgingDataLayout({
    Key? key,
    required this.fieldID,
    required this.trip,
  }) : super(key: key);

  final String fieldID;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LodgingData>(
      stream:
          DatabaseService(fieldID: fieldID, tripDocID: trip.documentId).lodging,
      builder: (BuildContext context, AsyncSnapshot<LodgingData?> document) {
        if (document.hasData) {
          final LodgingData lodging = document.data!;
          final DateTimeModel timeModel = DateTimeModel(
              startDate: lodging.startDateTimestamp.toDate(),
              endDate: lodging.endDateTimestamp.toDate());

          final Event event = createEvent(
              lodging: lodging, timeModel: timeModel, type: 'Lodging');
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(SizeConfig.defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(45)),
                ),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        lodging.lodgingType,
                        style: Theme.of(context).textTheme.headline5,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Creator: ${lodging.displayName}',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      trailing: LodgingMenuButton(
                        lodging: lodging,
                        trip: trip,
                        event: event,
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                    if (lodging.startDateTimestamp != null)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.calendar_today,
                        ),
                        title: Text(
                          '${TCFunctions().dateToMonthDayFromTimestamp(lodging.startDateTimestamp)} - '
                          '${TCFunctions().formatTimestamp(lodging.endDateTimestamp, wTime: false)}',
                          style: Theme.of(context).textTheme.subtitle1,
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
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onTap: () {},
                      ),
                    if (lodging.startTime.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.access_time,
                        ),
                        title: Text(
                          'Check in: ${lodging.startTime} ',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onTap: () {},
                      ),
                    if (lodging.endTime.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.access_time,
                        ),
                        title: Text(
                          'Check out: ${lodging.endTime}',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onTap: () {},
                      ),
                    if (lodging.location.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.map,
                        ),
                        title: Text(lodging.location,
                            style: const TextStyle(color: Colors.blue)),
                        onTap: () {
                          MapsLauncher.launchQuery(lodging.location);
                        },
                        onLongPress: () {
                          FlutterClipboard.copy(lodging.location).whenComplete(
                              () => TravelCrewAlertDialogs()
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
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    if (lodging.comment.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.comment,
                        ),
                        title: Tooltip(
                            message: lodging.comment,
                            child: Text(
                              lodging.comment,
                              style: Theme.of(context).textTheme.subtitle1,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            )),
                      )
                    else
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.comment,
                        ),
                        title: Tooltip(
                            message: lodging.comment,
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
              if (lodging.link.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(SizeConfig.defaultPadding),
                  width: double.infinity,
                  child: InkWell(
                    child: ViewAnyLink(
                      link: lodging.link,
                      function: () {},
                    ),
                    onTap: () {
                      TCFunctions().launchURL(lodging.link);
                    },
                  ),
                )
              else
                nil,
            ],
          );
        } else {
          return const Loading();
        }
      },
    );
  }
}
