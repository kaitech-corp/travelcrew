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

    // double _height = 10;
    // var _color = Colors.greenAccent;
    // double _width = SizeConfig.screenWidth;
    // var _borderRadius = BorderRadius.circular(0);
    //
    // void animate(int len){
    //   if(len == widget.trip.accessUsers.length){
    //     setState(() {
    //       _height = 250;
    //       _color = Colors.purpleAccent;
    //       _width = 250;
    //       _borderRadius = BorderRadius.circular(60);
    //     });
    //   }
    // }

    if(activityList != null) {
      setState(() {
        loading = false;
      });
      // animate(activityList[0].voters.length);
    }



    return loading ? Loading() : ListView.builder(
        itemCount: activityList != null ? activityList.length : 0,
        itemBuilder: (context, index){
          return ActivityItemLayout(activity: activityList[index],trip: widget.trip,);
        });
  }
}

// AnimatedContainer(
// // height: _height,
// width: _width,
// // color: _color,
// // decoration: BoxDecoration(
// //   color: _color,
// //   borderRadius: _borderRadius,
// // ),
// duration: Duration(seconds: 1),
// curve: Curves.easeInOutQuad,
// child: ActivityItemLayout(activity: activityList[0], trip: widget.trip,),
// ),
// Padding(padding: EdgeInsets.only(bottom: 10)),