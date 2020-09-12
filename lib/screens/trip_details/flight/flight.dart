import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/flight/flight_list.dart';
import 'package:travelcrew/services/database.dart';


class Flight extends StatefulWidget {

  final Trip trip;
  Flight({this.trip});

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
      value: DatabaseService(tripDocID: widget.trip.documentId).flightList,
      child: Scaffold(
        body: Container(
          child: FlightList()
        ),
        floatingActionButton: FloatingActionButton(

          onPressed: () {
//            Navigator.push(
//              context,
//              MaterialPageRoute(builder: (context) => AddNewFlight()),
//            );
            userAlertDialog(context);
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
  void userAlertDialog(BuildContext context) {

     showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Feature coming soon!'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {

                },
                child: Text('Thank you for you patience.'),
              ),
            ],
          );
        }
    );
  }
}