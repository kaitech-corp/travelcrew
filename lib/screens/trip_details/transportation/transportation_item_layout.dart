 import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/cost/split_package.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';

class TransportationItemLayout extends StatelessWidget {


  final TransportationData transportationData;
  final Trip trip;
  TransportationItemLayout({this.transportationData, this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(transportationData.displayName,style: ReusableThemeColor().greenOrBlueTextColor(context),),
                    Text(transportationData.mode,style: Theme.of(context).textTheme.headline4,),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 5.0,)),
                if(transportationData.mode == 'Flying') Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Tooltip(
                        message: 'Airline and Flight Number',
                          child: Text('${transportationData.airline}: ${transportationData.flightNumber}',style: Theme.of(context).textTheme.subtitle1,)),
                      // Text('${transportationData.flightNumber}',style: Theme.of(context).textTheme.subtitle1,),
                    ],
                  ),
                const Padding(padding: EdgeInsets.only(top: 5)),
                if(transportationData.comment.isNotEmpty) Text(transportationData.comment,style: Theme.of(context).textTheme.subtitle1,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (transportationData.canCarpool) ? Text('Open to Carpool',style: Theme.of(context).textTheme.headline6,) : Text(''),
                    menuButton(context),
                    // if(currentUserProfile.uid == transportationData.uid) IconButton(icon: IconThemeWidget(icon:Icons.delete), onPressed: (){
                    //   TravelCrewAlertDialogs().deleteTransportationAlert(context, transportationData);
                    // })
                  ],
                ),
                if(ThemeProvider.themeOf(context).id != 'light_theme') Container(height: 1,color: Colors.grey,)
              ],
            ),
          ),
        ),
    );
  }
  Widget menuButton(BuildContext context){
    return transportationData.uid == currentUserProfile.uid ? PopupMenuButton<String>(
      icon: IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (value){
        switch (value){
          case "Edit": {
            navigationService.navigateTo(EditTransportationRoute, arguments: transportationData);
          }
          break;
          case "Split": {
            SplitPackage().splitItemAlert(context,
                SplitObject(
                    itemDocID:transportationData.fieldID,
                    tripDocID: trip.documentId,
                    users: trip.accessUsers,
                    itemName: transportationData.mode,
                    itemDescription: 'Transportation',
                    details: transportationData.comment
                ),
                trip: trip);
          }
          break;
          case "Delete": {
            CloudFunction().deleteTransportation(tripDocID: transportationData.tripDocID,fieldID: transportationData.fieldID);
          }
          break;
          default: {

          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>[
         const PopupMenuItem(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.edit),
            title: const Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'Split',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.attach_money),
            title: const Text('Split'),
          ),
        ),
         const PopupMenuItem(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.delete),
            title: const Text('Delete'),
          ),
        ),
      ],
    ):
    PopupMenuButton<String>(
      onSelected: (value){
        switch (value){
          case "report":
            {

            }
            break;
          default: {

          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>[
        const PopupMenuItem(
          value: 'report',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.report),
            title: const Text('Report'),
          ),
        ),
      ],
    );
  }
}
