import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:travelcrew/models/activity_model.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/activity/activity_menu_button.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/link_previewer.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';

class ActivityDetails extends StatelessWidget{
  final ActivityData activity;
  final Trip trip;

  const ActivityDetails({Key key, this.activity, this.trip}) : super(key: key);


  @override
  Widget build(BuildContext context) {




    return Scaffold(
      appBar: AppBar(
        title: Text('Activity',style: Theme.of(context).textTheme.headline5,),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          child: ActivityDataLayout(fieldID: activity.fieldID, trip: trip),
        ),
      )
    );
  }
}

class ActivityDataLayout extends StatelessWidget {
  const ActivityDataLayout({
    Key key,
    @required this.fieldID,
    @required this.trip,
  }) : super(key: key);

  final String fieldID;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService(fieldID: fieldID,tripDocID: trip.documentId).activity,
      builder: (context, document){
        if(document.hasData){
          ActivityData activity = document.data;
          DateTimeModel timeModel = TCFunctions().addDateAndTime(
              startDate: activity.dateTimestamp,
              startTime: activity.startTime,
              endTime: activity.endTime,
              hasEndDate: false);

          Event event = TCFunctions().createEvent(activity: activity,type: "Activity",timeModel: timeModel);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(45),bottomRight: Radius.circular(45)),
                ),
                padding: EdgeInsets.all(SizeConfig.defaultPadding),
                child: Column(
                  children: [
                    ListTile(
                      title:Text(activity.activityType,
                        style: Theme.of(context).textTheme.headline5,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,),
                      subtitle: Text('${activity.displayName}',
                        style: Theme.of(context).textTheme.subtitle1,),
                      trailing: ActivityMenuButton(activity: activity,trip: trip,event: event),
                    ),
                    Divider(color: Colors.black,thickness: 2,),
                    activity.dateTimestamp != null ?? false ? ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                      title: Text(
                        '${TCFunctions().formatTimestamp(activity.dateTimestamp,wTime: false)}',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      onTap: (){
                        Add2Calendar.addEvent2Cal(event);
                      },
                    ):
                    ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                      title: Text('...',style: Theme.of(context).textTheme.subtitle1,),
                      onTap: (){
                      },
                    ),
                    if(activity.startTime?.isNotEmpty ?? false) ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.access_time,),
                      title:  Text('${activity.startTime ?? ''} - ${activity.endTime ?? ''}',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      onTap: (){

                      },
                    ),
                    activity.location?.isNotEmpty ?? false ? ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.map,),
                      title: Text(activity.location,style: TextStyle(color: Colors.blue),),
                      onTap: (){
                        MapsLauncher.launchQuery(activity.location);
                      },
                      onLongPress: (){
                        FlutterClipboard.copy(
                            activity.location).whenComplete(() => TravelCrewAlertDialogs().copiedToClipboardDialog(context));
                      },
                    ):
                    ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.map,),
                      title: Text('...',style: Theme.of(context).textTheme.subtitle1,),
                    ),
                    activity.comment?.isNotEmpty ?? false ? ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.comment,),
                      title: Tooltip(
                          message:activity.comment,
                          child: Text(activity.comment,
                            style: Theme.of(context).textTheme.subtitle1,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,)
                      ),
                    ):
                    ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.comment,),
                      title: Tooltip(
                          message:activity.comment,
                          child: Text('...',
                            style: Theme.of(context).textTheme.subtitle1,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,)
                      ),
                    ),
                  ],
                ),
              ),
              activity.link?.isNotEmpty ?? false ?
              Container(
                padding: EdgeInsets.all(SizeConfig.defaultPadding),
                width: double.infinity,
                child: InkWell(
                  child: FlutterLinkView(link: activity.link),
                  onTap: (){
                    TCFunctions().launchURL(activity.link);
                  },),
              ):
              Container(),

            ],
          );
        } else {
          return Loading();
        }
      },
    );
  }
}