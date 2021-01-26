import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/lodging/lodging_list.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';


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
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          body: Container(
            child: LodgingList(trip: widget.trip,),
          ),
          floatingActionButton: FloatingActionButton(

            onPressed: () {
              navigationService.navigateTo(AddNewLodgingRoute, arguments: widget.trip);
            },
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
