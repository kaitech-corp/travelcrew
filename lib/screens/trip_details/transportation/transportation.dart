import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/transportation/add_new_transportation.dart';
import 'package:travelcrew/screens/trip_details/transportation/transportation_list.dart';
import 'package:travelcrew/services/database.dart';


class Transportation extends StatefulWidget {

  final Trip trip;
  Transportation({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _TransportationState();
  }
}

class _TransportationState extends State<Transportation> {
  _TransportationState();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<TransportationData>>.value(
      value: DatabaseService(tripDocID: widget.trip.documentId).transportList,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          body: Container(
            child: TransportationList()
          ),
          floatingActionButton: FloatingActionButton(

            onPressed: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => AddNewModeOfTransport(trip: widget.trip,)),
             );
            },
            child: Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}