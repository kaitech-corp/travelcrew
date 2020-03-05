import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic.dart';
import 'package:travelcrew/services/database.dart';

class TappableTripCard extends StatelessWidget {

  final Trip trip;
  TappableTripCard({this.trip});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);

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
                title: Text((trip.location != '' ? trip.location : 'Trip Name'), textScaleFactor: 1.25,),
                subtitle: Text("Travel Type: ${trip.travelType}",
                  textAlign: TextAlign.start,),
//              isThreeLine: true,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Owner: ${ownerName(user.uid)}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Start Date: ${trip.startDate}'),
                        Text('End Date: ${trip.endDate}')
                      ],
                    ),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: favorite(user.uid),
                          onPressed: () {
                            if (trip.favorite.contains(user.uid)){
                              return DatabaseService(tripDocID: trip.documentId).removeFavoriteFromTrip(user.uid);
                            } else {
                              return DatabaseService(tripDocID: trip.documentId)
                                  .addFavoriteToTrip(user.uid);
                            }
                            /* ... */ },
                        ),
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
  
  favorite(String uid){
    if (trip.favorite.contains(uid)){

      return Icon(Icons.favorite);
    } else {
      return Icon(Icons.favorite_border);
    }
  }
  ownerName(String uid){
    if (trip.ownerID == uid){
      return 'You';
    }else {
      return trip.displayName;
    }
  }
}
