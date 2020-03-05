import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'activity_item_layout.dart';

class ActivityList extends StatefulWidget {

  final String tripDocID;
  ActivityList({this.tripDocID});


  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  @override
  Widget build(BuildContext context) {

    final activityList = Provider.of<List<ActivityData>>(context);



    return ListView.builder(
        itemCount: activityList != null ? activityList.length : 0,
        itemBuilder: (context, index){
          return ActivityItemLayout(activity: activityList[index],tripDocID: widget.tripDocID,);
        });
  }
}