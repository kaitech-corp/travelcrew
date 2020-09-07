import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/activity/activity_list.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';


class Members extends StatelessWidget {
  final Trip trip;
  Members({this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ActivityList(trip: trip,),
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewActivity(trip: trip,)),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

