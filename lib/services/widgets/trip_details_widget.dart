import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';


import '../../features/Alerts/alert_dialogs.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/functions/tc_functions.dart';
import '../../size_config/size_config.dart';
import '../theme/text_styles.dart';
import 'appearance_widgets.dart';

class TripDetailsWidget extends StatelessWidget {
  const TripDetailsWidget({
    Key? key,
    required this.expandController,
    required this.tripDetails, required this.detailsPadding, required this.event,
  }) : super(key: key);

  final ExpandableController expandController;
  final Trip tripDetails;
  final double detailsPadding;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        Visibility(
          visible: !expandController.expanded,
          child: const Padding(
            padding: EdgeInsets.only(top: 15.0),
            // child: DateGauge(tripDetails: tripDetails),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpandableNotifier(
            controller: expandController,
            child: ScrollOnExpand(
              child: ExpandableTheme(
                data: const ExpandableThemeData(
                  iconSize: 25.0,
                  iconColor: Colors.black,
                ),
                child: ExpandablePanel(
                  header: Text('Trip Details', style: SizeConfig.tablet ? headlineLarge(context) : headlineSmall(context),),
                  collapsed: Container(),
                  expanded: Padding(
                    padding: EdgeInsets.all(detailsPadding),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const TripDetailsIconThemeWidget(icon: Icons.location_pin,),
                          title: Text(tripDetails.location ?? '',
                            style: titleMedium(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: (){
                            FlutterClipboard.copy(
                                tripDetails.location ?? '').whenComplete(() => TravelCrewAlertDialogs().copiedToClipboardDialog(context));
                          },
                        ),
                        ListTile(
                          leading: const TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                          title: Text('${TCFunctions().dateToMonthDay(tripDetails.startDate ?? '')} - ${tripDetails.endDate}',
                            style: titleMedium(context),
                          ),
                          onTap: (){
                            Add2Calendar.addEvent2Cal(event);
                          },
                        ),
                        ListTile(
                          leading: const TripDetailsIconThemeWidget(icon: Icons.label,),
                          title: Text(tripDetails.travelType ?? '',
                            style: titleMedium(context),
                          ),
                        ),
                        ListTile(
                          leading: const TripDetailsIconThemeWidget(icon: Icons.people,),
                          title: Text('${tripDetails.accessUsers.length} Members',
                            style: titleMedium(context),
                          ),
                        ),
                        ListTile(
                          leading: tripDetails.ispublic ?
                          const TripDetailsIconThemeWidget(icon: Icons.public,) :
                          const TripDetailsIconThemeWidget(icon: Icons.public_off,),
                          title: tripDetails.ispublic ?
                          Text('Public Trip',
                            style: titleMedium(context),) :
                          Text('Private Trip',
                            style: titleMedium(context),),
                        ),
                        if(tripDetails.comment?.isNotEmpty ?? false) ListTile(
                          leading: const TripDetailsIconThemeWidget(icon: Icons.comment,),
                          title: Text(tripDetails.comment!,
                            style: titleMedium(context),
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
