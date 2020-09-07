import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/loading.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';
import 'package:travelcrew/services/database.dart';

class PrivateTripList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Container(
      child: privateTrips(user.uid),
    );
  }

  Widget privateTrips(String uid) {
    return FutureBuilder(
      future: DatabaseService(uid: uid).privateTripList(),
      builder: (context, trips) {
        if (trips.hasData) {
          return ListView.builder(
            itemCount: trips.data.length,
            itemBuilder: (context, index) {
              Trip trip = trips.data[index];
              return TappableCrewTripTile(trip: trip,);
            },
          );
        } else {
          return Loading();
        }
      },
    );
  }
}