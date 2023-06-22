import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';

import '../../../services/constants/constants.dart';
import '../../../services/functions/calendar_events.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../services/widgets/loading.dart';
import '../../../services/widgets/map_launcher.dart';
import '../../../size_config/size_config.dart';
import '../../models/lodging_model/lodging_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/functions/date_time_retrieval.dart';
import '../Alerts/alert_dialogs.dart';
import 'components/lodging_menu_button.dart';
import 'logic/logic.dart';


class LodgingDetails extends StatelessWidget {
  const LodgingDetails({Key? key, required this.lodging, required this.trip})
      : super(key: key);
  final LodgingModel lodging;
  final Trip trip;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Lodging',
            style: headlineSmall(context),
          ),
          backgroundColor: canvasColor,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: LodgingModelLayout(
              fieldID: lodging.fieldID,
              trip: trip,
            ),
          ),
        ));
  }
}

class LodgingModelLayout extends StatelessWidget {
  const LodgingModelLayout({
    Key? key,
    required this.fieldID,
    required this.trip,
  }) : super(key: key);

  final String fieldID;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LodgingModel>(
      stream: StreamLodging(tripDocID: trip.documentId,fieldID: fieldID).
          lodging,
      builder: (BuildContext context, AsyncSnapshot<LodgingModel?> document) {
        if (document.hasData) {
          final LodgingModel lodging = document.data!;

          final Event event = createEvent(
              lodging: lodging, startDate: lodging.startDateTimestamp!, endDate:lodging.endDateTimestamp!, type: 'Lodging');
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
                        style: headlineSmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        lodging.displayName,
                        style: titleMedium(context),
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
                          DateTimeRetrieval().dateFormatter(lodging.startDateTimestamp ?? DateTime(0), lodging.endDateTimestamp ?? DateTime(0)),
                      
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
                    if (lodging.startTime.isNotEmpty)
                      ListTile(
                        leading: const TripDetailsIconThemeWidget(
                          icon: Icons.access_time,
                        ),
                        title: Text(
                          'Check in: ${lodging.startTime} ',
                          style: titleMedium(context),
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
                          style: titleMedium(context),
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
                          MapSearch().searchAddress(lodging.location, context);
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
                          style: titleMedium(context),
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
                              style: titleMedium(context),
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
                              style: titleMedium(context),
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
            ],
          );
        } else {
          return const Loading();
        }
      },
    );
  }
}
