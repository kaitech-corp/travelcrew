import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';

class FavoriteTappableTripCard extends StatelessWidget {

  final Trip trip;
  FavoriteTappableTripCard({this.trip});

  @override
  Widget build(BuildContext context) {

    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExploreBasic(trip: trip,)),
          );
          print('Card tapped.');
        },
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
//              ImageLayout("assests/images/barcelona.jpg"),
              ListTile(
                title: Text((trip.location != '' ? trip.location : 'Trip Name').toUpperCase(), textScaleFactor: 1.25,),
                subtitle: Text("Travel Type: ${trip.travelType}",
                  textAlign: TextAlign.start,),
//              isThreeLine: true,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Owner:'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Start Date: ${trip.startDate}'),
                        Text('End Date: ${trip.endDate}')
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
