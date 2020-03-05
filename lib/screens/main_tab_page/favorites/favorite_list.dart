import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';

import 'favorite_tappable_card.dart';

class FavoriteTripList extends StatefulWidget {
  @override
  _FavoriteTripState createState() => _FavoriteTripState();

}

class _FavoriteTripState extends State<FavoriteTripList> {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    final trips = Provider.of<List<Trip>>(context);


    return ListView.builder(
        itemCount: trips != null ? trips.length : 0,
        itemBuilder: (context, index){
          var item = trips[index];
          return Dismissible(
            // Show a red background as the item is swiped away.
            background: Container(color: Colors.red),
            key: Key(item.documentId),
            onDismissed: (direction) {
              setState(() {
                trips.removeAt(index);
                DatabaseService(tripDocID: item.documentId).removeFavoriteFromTrip(user.uid);
              });

              Scaffold
                  .of(context)
                  .showSnackBar(SnackBar(content: Text("Tripped removed from favorites.")));
            },
            child: FavoriteTappableTripCard(trip: trips[index]),
          );
        });
  }
}
