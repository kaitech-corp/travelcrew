import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/flight/flight_list.dart';
import 'package:travelcrew/services/database.dart';

import 'add_new_flight.dart';

class Flight extends StatefulWidget {

  final String tripDocID;
  Flight({this.tripDocID});

  @override
  State<StatefulWidget> createState() {
    return _FlightState();
  }
}

class _FlightState extends State<Flight> {
  _FlightState();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<FlightData>>.value(
      value: DatabaseService(tripDocID: widget.tripDocID).flightList,
      child: Scaffold(
        body: Container(
          child: FlightList()
        ),
        floatingActionButton: FloatingActionButton(

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewFlight()),
            );

          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}