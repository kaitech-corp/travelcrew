import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/size_config/size_config.dart';

class FavoriteTappableTripCard extends StatelessWidget {

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final Trip trip;
  FavoriteTappableTripCard({this.trip});

  @override
  Widget build(BuildContext context) {

    return Card(
      color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(50.0)),
      ),
      margin: EdgeInsets.all(SizeConfig.screenWidth*.05),
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
          // color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
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
                decoration: (ThemeProvider.themeOf(context).id == 'light_theme') ?
                BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(75.0)),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue,
                        Colors.lightBlueAccent
                      ]
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black,
                  //     blurRadius: 10.0,
                  //   ),
                  //   BoxShadow(
                  //     color: Colors.blueAccent,
                  //     blurRadius: 10.0,
                  //   ),
                  // ],
                ):
                // BoxDecoration(
                //   // color:  Colors.black,
                //   borderRadius: BorderRadius.only(topRight: Radius.circular(75.0)),
                // ),
                null,

                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Creator: ${trip.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${trip.startDate.split(',')[0]}-${trip.endDate}',style: Theme.of(context).textTheme.subtitle2,),
                        // Text('${trip.endDate}',style: Theme.of(context).textTheme.subtitle2,)
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
