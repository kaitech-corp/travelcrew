import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/activity/activity_list.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';

class Activity extends StatefulWidget {

  final Trip trip;
  Activity({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _ActivityState();
  }
}

  class _ActivityState extends State<Activity> {

    @override
    Widget build(BuildContext context) {
      return StreamProvider.value(
        value: DatabaseService(tripDocID: widget.trip.documentId).activityList,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            body: Container(
              child: ActivityList(trip: widget.trip,),
            ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  navigationService.navigateTo(AddNewActivityRoute, arguments: widget.trip);
                },
                child: const Icon(Icons.add),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        ),
      );
    }
  }

