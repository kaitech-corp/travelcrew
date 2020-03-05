import 'package:flutter/material.dart';
import 'package:travelcrew/services/database.dart';
import 'package:provider/provider.dart';
import 'trip_list.dart';
import 'package:travelcrew/models/custom_objects.dart';


class AllTripsPage extends StatelessWidget{

  AllTripsPage();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Trip>>.value(
      value: DatabaseService().trips,
      child: Container (
        child: TripList(),
      ),
    );
  }
}