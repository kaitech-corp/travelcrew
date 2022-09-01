import 'package:flutter/material.dart';

import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/locator.dart';
import '../../alerts/alert_dialogs.dart';

/// Basic Layout for Explore page
class ExploreBasicLayout extends StatelessWidget{

  ExploreBasicLayout({required this.tripDetails,this.heroTag});

  final Trip tripDetails;
  final heroTag;
  final UserPublicProfile currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  if (tripDetails.urlToImage?.isNotEmpty ?? false) Hero(
                    tag: tripDetails.documentId!,
                    transitionOnUserGestures: true,
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.fitWidth,
                      placeholder: travelImage,
                      image: tripDetails.urlToImage!,

                    ),
                  ) else Image.asset(travelImage,fit: BoxFit.fitWidth,),
                  Positioned(
                    right: 5,
                    bottom: 10,
                      child: ElevatedButton(
                          child: const Text('Request to Join',style: TextStyle(color: Colors.white),),
                          onPressed: ()
                          {
                            final String message = '${currentUserProfile.displayName} has requested to join your trip ${tripDetails.tripName}.';
                            final String trip = tripDetails.documentId!;
                            const String type = 'joinRequest';
                            final String ownerID = tripDetails.ownerID!;
                            final bool ispublic = tripDetails.ispublic;

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
                title: Text('${tripDetails.location}',style: const TextStyle(fontSize: 20.0)),
                subtitle: Text('Owner: ${tripDetails.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                trailing: IconButton(
                  icon: const Icon(Icons.report,),
                  onPressed: (){
                    TravelCrewAlertDialogs().reportAlert(context: context, tripDetails: tripDetails, type: 'trip');
                  },
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left:18.0, right: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${tripDetails.travelType}'.toUpperCase(),style: Theme.of(context).textTheme.subtitle2,),
                      Text('${TCFunctions().dateToMonthDay(tripDetails.startDate!)} - ${tripDetails.endDate}',style: Theme.of(context).textTheme.subtitle1,)


                    ],
                  ),
                ),
              ),

              if(tripDetails.comment?.isNotEmpty ?? false) Container(
                padding: const EdgeInsets.all(18.0),
                decoration: const BoxDecoration(
                ),
                child: Text(tripDetails.comment!,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
              ),
            ],
          ),
        )
    );
  }
}



