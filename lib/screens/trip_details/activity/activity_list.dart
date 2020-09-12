import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import '../../../loading.dart';
import 'activity_item_layout.dart';

class ActivityList extends StatefulWidget {

  final Trip trip;
  ActivityList({this.trip});


  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
  @override
  Widget build(BuildContext context) {

    bool loading = true;
    final activityList = Provider.of<List<ActivityData>>(context);

    if(activityList != null) {
      setState(() {
        loading = false;
      });

    }

    return loading ? Loading() : ListView.builder(
        itemCount: activityList != null ? activityList.length : 0,
        itemBuilder: (context, index){
          return ActivityItemLayout(activity: activityList[index],trip: widget.trip,);
        });
  }
}