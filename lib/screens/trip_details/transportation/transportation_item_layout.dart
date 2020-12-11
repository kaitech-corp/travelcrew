import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/appearance_widgets.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';

class TransportationItemLayout extends StatelessWidget {


  final TransportationData transportationData;
  TransportationItemLayout({this.transportationData});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    Text(transportationData.displayName,style: ReusableThemeColor().greenOrBlackTextColor(context),),
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
                    // menuButton(context, transportationData),
                    if(currentUserProfile.uid == transportationData.uid) IconButton(icon: Icon(Icons.delete), onPressed: (){
                      TravelCrewAlertDialogs().deleteTransportationAlert(context, transportationData);
                    })
                  ],
                ),
                if(ThemeProvider.themeOf(context).id != 'light_theme') Container(height: 1,color: Colors.grey,)
              ],
            ),
          ),
        ),
    );
  }
  Widget menuButton(BuildContext context, TransportationData transportationData){
    return transportationData.uid == currentUserProfile.uid ? PopupMenuButton<String>(
      onSelected: (value){
        switch (value){
          case "Edit": {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) =>
            //       EditLodging(lodging: lodging, trip: trip,)),
            // );
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
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'Delete',
          child: ListTile(
            leading: const Icon(Icons.delete),
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
            leading: const Icon(Icons.report),
            title: const Text('Report'),
          ),
        ),
      ],
    );
  }
}
