import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../../models/trip_model/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/map_launcher.dart';
import '../../../size_config/size_config.dart';

class DetailsCardOne extends StatelessWidget {
  const DetailsCardOne({
    super.key,
    required this.trip,
  });
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(defaultPadding * 2),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: SizeConfig.screenWidth * .8,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Column(children: <Widget>[
                    Text(
                      TCFunctions().calculateTimeDifferenceInDays(
                          trip.startDateTimeStamp, trip.endDateTimeStamp),
                      style: titleMedium(context),
                    ),
                    Text(
                      'Duration',
                      style: titleSmall(context),
                    ),
                  ]),
                ),
                Expanded(
                  child: Column(children: <Widget>[
                    Text(
                      '${trip.accessUsers.length}',
                      style: titleMedium(context),
                    ),
                    Text(
                      'Members',
                      style: titleSmall(context),
                    ),
                  ]),
                ),
                Expanded(
                  child: Column(children: <Widget>[
                    if (trip.ispublic)
                      const IconThemeWidget(icon: Icons.public)
                    else
                      const IconThemeWidget(icon: Icons.public_off),
                    if (trip.ispublic)
                      Text(
                        'Public',
                        style: titleSmall(context),
                      )
                    else
                      Text(
                        'Private',
                        style: titleSmall(context),
                      ),
                  ]),
                ),
              ]),
        ),
      ),
    );
  }
}

class DetailsCardTwo extends StatelessWidget {
  const DetailsCardTwo({
    super.key,
    required this.trip,
    required this.event,
  });

  final Trip trip;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: SizedBox(
          width: SizeConfig.screenWidth * .8,
          child: Column(children: [
            ListTile(
              leading:
                  const TripDetailsIconThemeWidget(icon: Icons.location_pin),
              title: Text(
                trip.location ?? '',
                style: titleMedium(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                MapSearch().searchAddress(trip.location ?? '', context);
              },
            ),
            ListTile(
              leading:
                  const TripDetailsIconThemeWidget(icon: Icons.calendar_today),
              title: Text(
                TCFunctions().tripCardDate(trip.startDate!, trip.endDate!),
                style: titleMedium(context),
              ),
              onTap: () {
                Add2Calendar.addEvent2Cal(event);
              },
            ),
            ListTile(
              leading: const TripDetailsIconThemeWidget(icon: Icons.label),
              title: Text(
                trip.travelType ?? '',
                style: titleMedium(context),
              ),
            ),
            ListTile(
              leading:
                  const TripDetailsIconThemeWidget(icon: Icons.description),
              title: Text(
                trip.comment ?? '',
                style: titleMedium(context),
                
              ),
            ),
          ]),
        ));
  }
}
