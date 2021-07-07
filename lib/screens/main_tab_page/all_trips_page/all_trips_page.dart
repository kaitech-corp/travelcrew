import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/database.dart';


class AllTripsPage extends StatelessWidget{
  final List<Trip> trip;

  const AllTripsPage({Key key, this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamProvider<List<TripAds>>.value(
      value: DatabaseService().adList,
      child: Container (
        child: AllTripsPage(),
      ),
    );
  }

}