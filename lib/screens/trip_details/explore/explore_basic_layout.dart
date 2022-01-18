import 'package:flutter/material.dart';
import '../../../models/trip_model.dart';
import '../../alerts/alert_dialogs.dart';
import '../../../services/constants/constants.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/locator.dart';

class ExploreBasicLayout extends StatelessWidget{

  final Trip tripDetails;
  final heroTag;
  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  ExploreBasicLayout({this.tripDetails,this.heroTag});

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  tripDetails.urlToImage.isNotEmpty ? Hero(
                    tag: tripDetails.urlToImage,
                    transitionOnUserGestures: true,
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.fitWidth,
                      placeholder: travelImage,
                      image: tripDetails?.urlToImage,

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
                title: Text('${tripDetails.location}',style: TextStyle(fontSize: 20.0)),
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
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                ),
                child: Text(tripDetails.comment,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
              ),
            ],
          ),
        )
    );
  }
}



