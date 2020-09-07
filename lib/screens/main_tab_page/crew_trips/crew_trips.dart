import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';
import 'crew_trip_list.dart';

class CrewTrips extends StatelessWidget{

  int type;
  CrewTrips({this.type});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return StreamProvider<List<Trip>>.value(
        value: DatabaseService(uid: user.uid).crewTrips,
        child: CrewTripList(type: type,)
    );
  }
}