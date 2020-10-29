import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/constants.dart';
import 'favorite_tappable_card.dart';

class FavoriteTripList extends StatefulWidget {
  @override
  _FavoriteTripState createState() => _FavoriteTripState();

}

class _FavoriteTripState extends State<FavoriteTripList> {
  @override
  Widget build(BuildContext context) {

    final trips = Provider.of<List<Trip>>(context);


    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(spaceImage),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView.builder(
          itemCount: trips != null ? trips.length : 0,
          itemBuilder: (context, index){
            var item = trips[index];
            return Dismissible(
              // Show a red background as the item is swiped away.
              background: Container(color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Icon(Icons.delete, color: Colors.white,),
                    const Icon(Icons.delete, color: Colors.white,)
                  ],
                ),),
              key: Key(item.documentId),
              onDismissed: (direction) {
                setState(() {
                  trips.removeAt(index);
                  CloudFunction().removeFavoriteFromTrip(item.documentId);
                });
                Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: Text("Tripped removed from favorites.")));
              },
              child: FavoriteTappableTripCard(trip: trips[index]),
            );
          }),
    );
  }
}
