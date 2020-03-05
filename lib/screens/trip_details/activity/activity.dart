import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/screens/trip_details/activity/activity_list.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';
import 'package:travelcrew/services/database.dart';

class Activity extends StatefulWidget {

  final String tripDocID;
  Activity({this.tripDocID});

  @override
  State<StatefulWidget> createState() {
    return _ActivityState();
  }
}

  class _ActivityState extends State<Activity> {

    @override
    Widget build(BuildContext context) {
      return StreamProvider.value(
        value: DatabaseService(tripDocID: widget.tripDocID).activityList,
        child: Scaffold(
          body: Container(
            child: ActivityList(tripDocID: widget.tripDocID,),
          ),
            floatingActionButton: FloatingActionButton(

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewActivity(tripDocID: widget.tripDocID,)),
                );
              },
              child: Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      );
    }
  }

