
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:theme_provider/theme_provider.dart';

class PrivateTripList extends StatelessWidget {

  var userService = locator<UserService>();

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<User>(context);
    return Container(
      child: privateTrips(context),
    );
  }

  Widget privateTrips(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (ThemeProvider.themeOf(context).id == 'light_theme') ? AssetImage(skyImage) : AssetImage(spaceImage),
          fit: BoxFit.cover,
        ),
      ),
      child: FutureBuilder(
        future: DatabaseService(uid: userService.currentUserID).privateTripList(),
        builder: (context, trips) {
          if (trips.hasData) {
            return Container(
                child: ListView.builder(
                  itemCount: trips.data.length,
                  itemBuilder: (context, index) {
                    Trip trip = trips.data[index];
                    return TappableCrewTripTile(trip: trip,);
                  },
                ));
          } else {
            return Loading();
          }
        },
      ),
    );
  }
}