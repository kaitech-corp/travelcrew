import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/size_config/size_config.dart';
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
      height: double.infinity,
      width: double.infinity,
      child: ListView.builder(
          padding: EdgeInsets.all(0.0),
          itemCount: trips != null ? trips.length : 0,
          itemBuilder: (context, index){
            var item = trips[index];
            return Dismissible(
              direction: DismissDirection.endToStart,
              // Show a red background as the item is swiped away.
              background: Container(
                margin: EdgeInsets.all(SizeConfig.screenWidth*.05),
                color: Colors.red,
                child: const Align(alignment: Alignment.centerRight,child: const Icon(Icons.delete, color: Colors.white,)),),
              key: Key(item.documentId),
              onDismissed: (direction) {
                setState(() {
                  trips.removeAt(index);
                  CloudFunction().removeFavoriteFromTrip(item.documentId);
                });
                Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: const Text("Tripped removed from favorites.")));
              },
              child: FavoriteTappableTripCard(trip: trips[index]),
            );
          }),
    );
  }
}
