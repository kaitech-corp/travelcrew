import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/widgets/reusableWidgets.dart';
import 'package:travelcrew/size_config/size_config.dart';

import 'appearance_widgets.dart';

class TripDetailsWidget extends StatelessWidget {
  const TripDetailsWidget({
    Key key,
    @required this.expandController,
    @required this.tripDetails, this.detailsPadding, this.event,
  }) : super(key: key);

  final ExpandableController expandController;
  final Trip tripDetails;
  final double detailsPadding;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Visibility(
          visible: !expandController.expanded,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: DateGauge(tripDetails: tripDetails),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpandableNotifier(
            controller: expandController,
            child: ScrollOnExpand(
              scrollOnExpand: true,
              child: ExpandableTheme(
                data: ExpandableThemeData(
                  iconSize: 25.0,
                  iconColor: Colors.black,
                ),
                child: ExpandablePanel(
                  header: Text('Trip Details', style: SizeConfig.tablet ? Theme.of(context).textTheme.headline4 : Theme.of(context).textTheme.headline6,),
                  collapsed: Container(),
                  expanded: Padding(
                    padding: EdgeInsets.all(detailsPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: TripDetailsIconThemeWidget(icon: Icons.location_pin,),
                          title: Text('${tripDetails.location}',
                            style: Theme.of(context).textTheme.subtitle1,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: (){
                            FlutterClipboard.copy(
                                tripDetails.location).whenComplete(() => TravelCrewAlertDialogs().copiedToClipboardDialog(context));
                          },
                        ),
                        ListTile(
                          leading: TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                          title: Text('${TCFunctions().dateToMonthDay(tripDetails.startDate)} - ${tripDetails.endDate}',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          onTap: (){
                            Add2Calendar.addEvent2Cal(event);
                          },
                        ),
                        ListTile(
                          leading: TripDetailsIconThemeWidget(icon: Icons.label,),
                          title: Text('${tripDetails.travelType}',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        ListTile(
                          leading: TripDetailsIconThemeWidget(icon: Icons.people,),
                          title: Text('${tripDetails.accessUsers.length} Members',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        ListTile(
                          leading: tripDetails.ispublic ?
                          TripDetailsIconThemeWidget(icon: Icons.public,) :
                          TripDetailsIconThemeWidget(icon: Icons.public_off,),
                          title: tripDetails.ispublic ?
                          Text('Public Trip',
                            style: Theme.of(context).textTheme.subtitle1,) :
                          Text('Private Trip',
                            style: Theme.of(context).textTheme.subtitle1,),
                        ),
                        if(tripDetails.comment.isNotEmpty) ListTile(
                          leading: TripDetailsIconThemeWidget(icon: Icons.comment,),
                          title: Text(tripDetails.comment,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
