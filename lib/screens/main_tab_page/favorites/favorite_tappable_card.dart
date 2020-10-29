import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';

class FavoriteTappableTripCard extends StatelessWidget {

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final Trip trip;
  FavoriteTappableTripCard({this.trip});

  @override
  Widget build(BuildContext context) {

    return Card(
      key: Key(trip.documentId),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text((trip.tripName).toUpperCase(),style: Theme.of(context).textTheme.headline4,maxLines: 1,overflow: TextOverflow.ellipsis,),
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
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Owner: ${trip.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Start Date: ${trip.startDate}',style: Theme.of(context).textTheme.subtitle2,),
                        Text('End Date: ${trip.endDate}',style: Theme.of(context).textTheme.subtitle2,)
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
