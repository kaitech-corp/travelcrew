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
import '../../models/lodging_model/lodging_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/functions/date_time_retrieval.dart';
import '../Alerts/alert_dialogs.dart';
import 'components/lodging_menu_button.dart';

class LodgingDetails extends StatelessWidget {
  const LodgingDetails({super.key, required this.lodging, required this.trip});

  final LodgingModel lodging;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: canvasColor,
        actions: [
          LodgingMenuButton(lodging: lodging, trip: trip),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          child: LodgingDetailsLayout(lodging: lodging, trip: trip),
        ),
      ),
    );
  }
}

class LodgingDetailsLayout extends StatelessWidget {
  const LodgingDetailsLayout({
    super.key,
    required this.lodging,
    required this.trip,
  });

  final LodgingModel lodging;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final Event event = createEvent(
      lodging: lodging,
      type: 'Lodging',
      startDate: lodging.startDateTimestamp!,
      endDate: lodging.endDateTimestamp!,
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
                        lodging.lodgingType,
                        style: headlineSmall(context),
                      ),
                      subtitle: Text(
                        'Created by: ${lodging.displayName}',
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
        if (lodging.link.isNotEmpty)
          Container(
            padding: EdgeInsets.all(SizeConfig.defaultPadding),
            width: double.infinity,
            child: InkWell(
              child: ViewAnyLink(
                  hash: lodging.hashCode,
                  link: lodging.link,
                  multiMediaonly: false,
                  function: () {
                    TCFunctions().launchURL(lodging.link);
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
              if (lodging.startDateTimestamp != null)
                ListTile(
                  leading: const TripDetailsIconThemeWidget(
                      icon: Icons.calendar_today),
                  title: Text(
                    DateTimeRetrieval().dateFormatter(
                        lodging.startDateTimestamp ?? DateTime(0),
                        lodging.endDateTimestamp ?? DateTime(0)),
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
              if (lodging.startTime.isNotEmpty)
                ListTile(
                  leading:
                      const TripDetailsIconThemeWidget(icon: Icons.access_time),
                  title: Text(
                    '${lodging.startTime} - ${lodging.endTime}',
                    style: labelLarge(context),
                  ),
                  onTap: () {},
                ),
              if (lodging.location.isNotEmpty)
                ListTile(
                  leading: const TripDetailsIconThemeWidget(icon: Icons.map),
                  title: Text(
                    lodging.location,
                    style: labelLarge(context)?.copyWith(color: Colors.blue),
                  ),
                  onTap: () {
                    MapSearch().searchAddress(lodging.location, context);
                  },
                  onLongPress: () {
                    FlutterClipboard.copy(lodging.location).whenComplete(() =>
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
              if (lodging.comment.isNotEmpty)
                ListTile(
                  leading:
                      const TripDetailsIconThemeWidget(icon: Icons.comment),
                  title: Tooltip(
                    message: lodging.comment,
                    child: Text(
                      lodging.comment,
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
                    message: lodging.comment,
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
