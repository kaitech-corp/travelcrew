import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/explore/stream_to_explore.dart';


class TappableCrewTripCard extends StatelessWidget {

  final Trip trip;
  TappableCrewTripCard({this.trip});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Stream_to_Explore(trip: trip,)),
          );
          print('Card tapped.');
        },
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ImageLayout(trip.urlToImage != "" ? trip.urlToImage : "assests/images/travelPics.png"),
              ListTile(
                title: Text(trip.location != null ? trip.location : 'Trip Name'),
                subtitle: Text(trip.travelType != null ? "Travel Type: ${trip.travelType}" : "Travel Type:",
                  textAlign: TextAlign.start,),
                trailing: Icon(Icons.message),
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Owner: ${ownerName(user.uid)}'),
                      Text(trip.startDate != null ? '${trip.startDate} to ${trip.endDate}' : 'Dates')
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
  String ownerName(String uid){
    if (trip.ownerID == uid){
      return 'You';
    }else {
      return trip.displayName;
    }
  }

}