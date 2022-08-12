import 'package:flutter/material.dart';

import '../../../models/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/locator.dart';
import '../../alerts/alert_dialogs.dart';

/// Basic Layout for Explore page
class ExploreBasicLayout extends StatelessWidget{

  final Trip trip;
  final heroTag;
  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  ExploreBasicLayout({required this.trip,this.heroTag});

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  trip.urlToImage.isNotEmpty ? Hero(
                    tag: trip.urlToImage,
                    transitionOnUserGestures: true,
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.fitWidth,
                      placeholder: travelImage,
                      image: trip?.urlToImage,

                    ),
                  ):
                  Image.asset(travelImage,fit: BoxFit.fitWidth,),
                  Positioned(
                    right: 5,
                    bottom: 10,
                      child: ElevatedButton(
                          child: const Text('Request to Join',style: TextStyle(color: Colors.white),),
                          onPressed: ()
                          {
                            String message = '${currentUserProfile.displayName} has requested to join your trip ${trip.tripName}.';
                            String trip = trip.documentId;
                            String type = 'joinRequest';
                            String ownerID = trip.ownerID;
                            bool ispublic = trip.ispublic;

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
                title: Text('${trip.location}',style: TextStyle(fontSize: 20.0)),
                subtitle: Text('Owner: ${trip.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                trailing: IconButton(
                  icon: const Icon(Icons.report,),
                  onPressed: (){
                    TravelCrewAlertDialogs().reportAlert(context: context, trip: trip, type: 'trip');
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
                      Text('${trip.travelType}'.toUpperCase(),style: Theme.of(context).textTheme.subtitle2,),
                      Text('${TCFunctions().dateToMonthDay(trip.startDate)} - ${trip.endDate}',style: Theme.of(context).textTheme.subtitle1,)


                    ],
                  ),
                ),
              ),

              if(trip.comment.isNotEmpty) Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                ),
                child: Text(trip.comment,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
              ),
            ],
          ),
        )
    );
  }
}



