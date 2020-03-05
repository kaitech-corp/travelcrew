import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/explore/stream_to_explore.dart';
import 'package:travelcrew/services/badge_icon.dart';


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
              ImageLayout(trip.urlToImage != "" ? trip.urlToImage : "assests/images/barcelona.jpg"),
              ListTile(
                title: Text(trip.location != '' ? trip.location : 'Trip Name'),
                subtitle: Text("Travel Type: ${trip.travelType}",
                  textAlign: TextAlign.start,),
                trailing: BadgeIcon(
                  icon: Icon(Icons.message),
                  badgeCount: 9,
                ),

              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Owner: ${ownerName(user.uid)}'),
                      Text('${trip.startDate} to ${trip.endDate}')
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