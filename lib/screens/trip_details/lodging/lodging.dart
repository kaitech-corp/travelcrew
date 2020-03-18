import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging_list.dart';
import 'package:travelcrew/services/database.dart';

import 'add_new_lodging.dart';

class Lodging extends StatefulWidget {

  final Trip trip;
  Lodging({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _LodgingState();
  }
}

class _LodgingState extends State<Lodging> {

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: DatabaseService(tripDocID: widget.trip.documentId).lodgingList,
      child: Scaffold(
        body: Container(
          child: LodgingList(tripDocID: widget.trip.documentId,),
        ),
        floatingActionButton: FloatingActionButton(

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddNewLodging(trip: widget.trip,)),
            );
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

// Code to add Dismissable action
//Dismissible(
//onDismissed: (DismissDirection direction) {
//setState(() {
//lodging.removeAt(index);
//});
//},
//secondaryBackground: Container(
//child: Column(
//mainAxisSize: MainAxisSize.min,
//crossAxisAlignment: CrossAxisAlignment.end,
//mainAxisAlignment: MainAxisAlignment.center,
//children: <Widget>[
//Text('Delete',
//style: TextStyle(color: Colors.white), textScaleFactor: 1.5,)
//],
//),
//color: Colors.red,
//
//),
//background: Container(),
//child: lodging[index],
//key: UniqueKey(),
//direction: DismissDirection.endToStart,
//);