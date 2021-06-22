import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';

class ExploreBasicLayout extends StatelessWidget{

  final Trip tripDetails;
  final heroTag;

  ExploreBasicLayout({this.tripDetails,this.heroTag});

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        body: SingleChildScrollView(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  Hero(
                    tag: tripDetails.urlToImage,
                    transitionOnUserGestures: true,
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.fitWidth,
                      placeholder: travelImage,
                      image: tripDetails.urlToImage,

                    ),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 10,
                      child: ElevatedButton(
                          child: const Text('Request to Join',style: TextStyle(color: Colors.white),),
                          onPressed: ()
                          {
                            String message = '${currentUserProfile.displayName} has requested to join your trip ${tripDetails.tripName}.';
                            String trip = tripDetails.documentId;
                            String type = 'joinRequest';
                            String ownerID = tripDetails.ownerID;
                            bool ispublic = tripDetails.ispublic;

                            CloudFunction().addNewNotification(message: message,
                              documentID: trip,
                              type: type,
                              ownerID: ownerID,
                              ispublic: ispublic,
                            );
                            TravelCrewAlertDialogs().showRequestDialog(context);
                          }
                      ),),
                ],
              ),
              ListTile(
                title: Text('${tripDetails.location}'.toUpperCase(),style: TextStyle(fontSize: 20.0)),
                subtitle: Text('Owner: ${tripDetails.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                trailing: IconButton(
                  icon: const Icon(Icons.report,),
                  onPressed: (){
                    TravelCrewAlertDialogs().reportAlert(context: context, tripDetails: tripDetails, type: 'tripDetails');
                  },
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left:18.0, right: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${tripDetails.travelType}'.toUpperCase(),style: Theme.of(context).textTheme.subtitle2,),
                      Text('${TCFunctions().dateToMonthDay(tripDetails.startDate)} - ${tripDetails.endDate}',style: Theme.of(context).textTheme.subtitle1,)


                    ],
                  ),
                ),
              ),

              if(tripDetails.comment.isNotEmpty) Container(
                // margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                    // border: Border.all(color: Colors.blueAccent)
                ),
                child: Text(tripDetails.comment,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
              ),
            ],
          ),
        )
    );
  }
}



