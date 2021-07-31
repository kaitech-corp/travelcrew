import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:travelcrew/models/lodging_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging_menu_button.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/link_previewer.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';

class LodgingDetails extends StatelessWidget{

  final LodgingData lodging;
  final Trip trip;

  const LodgingDetails({Key key, this.lodging,this.trip}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Lodging',style: Theme.of(context).textTheme.headline5,),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: LodgingDataLayout(fieldID: lodging.fieldID, trip: trip,),
          ),
        )
    );
  }
}

class LodgingDataLayout extends StatelessWidget {
  const LodgingDataLayout({
    Key key,
    @required this.fieldID,
    @required this.trip,
  }) : super(key: key);

  final String fieldID;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService(fieldID: fieldID,tripDocID: trip.documentId).lodging,
      builder: (context, document){
        if(document.hasData){
          LodgingData lodging = document.data;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(SizeConfig.defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(45),bottomRight: Radius.circular(45)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title:Text(lodging.lodgingType,
                        style: Theme.of(context).textTheme.headline5,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,),
                      subtitle: Text('Creator: ${lodging.displayName}',
                        style: Theme.of(context).textTheme.subtitle1,),
                      trailing: LodgingMenuButton(lodging: lodging,trip: trip,),
                    ),
                    Divider(color: Colors.black,thickness: 2,),
                    lodging.startDateTimestamp != null ?? false ? ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                      title: Text(
                        "${TCFunctions().dateToMonthDayFromTimestamp(lodging.startDateTimestamp)} - "
                            "${TCFunctions().formatTimestamp(lodging.endDateTimestamp,wTime: false)}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      onTap: (){
                         Event event = Event(
                          title: lodging.lodgingType,
                          description: lodging.comment,
                          location: lodging.location,
                          startDate: lodging.startDateTimestamp?.toDate() ?? trip.startDateTimeStamp.toDate(),
                          endDate: lodging.endDateTimestamp?.toDate() ?? trip.endDateTimeStamp.toDate(),
                        );
                        Add2Calendar.addEvent2Cal(event);
                      },
                    ):
                    ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                      title: Text('...',style: Theme.of(context).textTheme.subtitle1,),
                      onTap: (){
                      },
                    ),
                    if(lodging.startTime?.isNotEmpty ?? false) ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.access_time,),
                      title: Text('Check in: ${lodging.startTime} ',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      onTap: (){

                      },
                    ),
                    if(lodging.endTime?.isNotEmpty ?? false) ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.access_time,),
                      title: Text('Check out: ${lodging.endTime}',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      onTap: (){

                      },
                    ),

                    lodging.location?.isNotEmpty ?? false ? ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.map,),
                      title: Text(lodging.location,style: Theme.of(context).textTheme.subtitle1,),
                      onTap: (){
                        MapsLauncher.launchQuery(lodging.location);
                      },
                      onLongPress: (){
                        FlutterClipboard.copy(
                            lodging.location).whenComplete(() => TravelCrewAlertDialogs().copiedToClipboardDialog(context));
                      },
                    ):
                    ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.map,),
                      title: Text('...',style: Theme.of(context).textTheme.subtitle1,),
                    ),
                    lodging.comment?.isNotEmpty ?? false ? ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.comment,),
                      title: Tooltip(
                          message:lodging.comment,
                          child: Text(lodging.comment,
                            style: Theme.of(context).textTheme.subtitle1,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,)
                      ),
                    ):
                    ListTile(
                      leading: TripDetailsIconThemeWidget(icon: Icons.comment,),
                      title: Tooltip(
                          message:lodging.comment,
                          child: Text('...',
                            style: Theme.of(context).textTheme.subtitle1,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,)
                      ),
                    ),
                  ],
                ),
              ),
              lodging.link?.isNotEmpty ?? false ?
              Container(
                padding: EdgeInsets.all(SizeConfig.defaultPadding),
                width: double.infinity,
                child: InkWell(
                  child: FlutterLinkView(link: lodging.link),
                  onTap: (){
                    TCFunctions().launchURL(lodging.link);
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
