import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
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

    return Card(
      margin: EdgeInsets.only(left: 20, bottom: 20, top: 20, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StreamToExplore(trip: trip,)),
          );
        },
        child: Container(
          height: trip.urlToImage.isNotEmpty ? size.height* .31 : size.height*.11,
          width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                trip.urlToImage.isNotEmpty ? Flexible(flex: 2,child: ImageLayout2(trip.urlToImage)) : Container(),
                Flexible(
                  flex: 1,
                  child: ListTile(
                    title: Text(trip.location != null ? trip.location : 'Trip Name',style: Theme.of(context).textTheme.headline4,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    subtitle:  Text(trip.startDate != null ? '${trip.startDate} - ${trip.endDate}' : 'Dates',style: Theme.of(context).textTheme.subtitle1,),
                    trailing: Wrap(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 5,
                      children: <Widget>[
                        Text('${trip.accessUsers.length} ',style: Theme.of(context).textTheme.subtitle1,),
                        Icon(Icons.people)
                      ],
                    ),

                  ),
                ),
              ],
            ),
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