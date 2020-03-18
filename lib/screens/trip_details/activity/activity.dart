import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/activity/activity_list.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';
import 'package:travelcrew/services/database.dart';

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
        child: Scaffold(
          body: Container(
            child: ActivityList(tripDocID: widget.trip.documentId,),
          ),
            floatingActionButton: FloatingActionButton(

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewActivity(trip: widget.trip,)),
                );
              },
              child: Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      );
    }
  }

