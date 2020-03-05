import 'package:flutter/material.dart';
import 'package:travelcrew/screens/main_tab_page/favorites/favorite_list.dart';
import 'package:travelcrew/services/database.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';


class Favorites extends StatelessWidget{

  Favorites();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamProvider<List<Trip>>.value(
      value: DatabaseService(uid: user.uid).favoriteTrips,
      child: Container (
        child: FavoriteTripList(),
      ),
    );
  }
}