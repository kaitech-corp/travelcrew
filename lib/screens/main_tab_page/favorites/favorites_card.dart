import 'package:flutter/material.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/locator.dart';
import '../../../services/navigation/route_names.dart';
import '../../../size_config/size_config.dart';
import '../../alerts/alert_dialogs.dart';


/// Favorites card layout
class FavoritesCard extends StatelessWidget {

  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  final Trip trip;
  FavoritesCard({this.trip});

  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(topRight: Radius.circular(50.0)),
      ),
      margin: EdgeInsets.all(SizeConfig.screenWidth*.05),
      key: Key(trip.documentId),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
        },
        child: Container(
          // margin: const EdgeInsets.only(left: 15,right: 15, bottom: 20, top: 10),
          decoration:BoxDecoration(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(50.0)),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.lightBlueAccent.shade200
                ]
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text((trip.tripName).toUpperCase(),style: Theme.of(context).textTheme.headline5,maxLines: 1,overflow: TextOverflow.ellipsis,),
                subtitle: Text("Travel Type: ${trip.travelType}",
                  textAlign: TextAlign.start,style: Theme.of(context).textTheme.subtitle2,maxLines: 1,overflow: TextOverflow.ellipsis,),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: (){
                    String message = '${currentUserProfile.displayName} has requested to join your trip ${trip.tripName}.';
                    String type = 'joinRequest';

                    CloudFunction().addNewNotification(message: message,
                      documentID: trip.documentId,
                      type: type,
                      ownerID: trip.ownerID,
                      ispublic: trip.ispublic,
                    );
                    TravelCrewAlertDialogs().showRequestDialog(context);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(75.0)),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue,
                        Colors.lightBlueAccent
                      ]
                  ),
                ),

                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Creator: ${trip.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${trip.startDate.split(',')[0]}-${trip.endDate}',style: Theme.of(context).textTheme.subtitle2,),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
