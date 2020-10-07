import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/stream_to_explore.dart';
import 'package:travelcrew/services/locator.dart';



class TappableCrewTripTile extends StatelessWidget {

  final Trip trip;

  TappableCrewTripTile({this.trip});

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();




  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height*.2,
      width: double.infinity,
      margin: EdgeInsets.only(left: 10, bottom: 20, top: 20, right: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(
            offset: Offset(0, 10),
            blurRadius: 33,
            color: Color(Colors.blueGrey.value).withOpacity(.84),
            spreadRadius: 5,
          )
          ]
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(trip.location != null ? trip.location : 'Trip Name',style: Theme.of(context).textTheme.headline1,maxLines: 2,overflow: TextOverflow.ellipsis,),
              subtitle: Text(trip.travelType != null ? "${trip.travelType}" : "",
                textAlign: TextAlign.start, style: Theme.of(context).textTheme.subtitle1,maxLines: 1,overflow: TextOverflow.ellipsis,),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StreamToExplore(trip: trip,)),
                );
              },
            ),
            Expanded(
              child: Container(

                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${ownerName(userService.currentUserID)}',style: Theme.of(context).textTheme.subtitle1,),
                          Text(trip.startDate != null ? '${trip.startDate} - ${trip.endDate}' : 'Dates',style: Theme.of(context).textTheme.subtitle1,),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text('${trip.accessUsers.length} ',style: Theme.of(context).textTheme.subtitle2,),
                          Icon(Icons.people)
                        ],
                      ),
                    ],
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
  String ownerName(String currentUserID){
    if (trip.ownerID == currentUserID){
      return 'You';
    }else {
      return trip.displayName;
    }
  }

}