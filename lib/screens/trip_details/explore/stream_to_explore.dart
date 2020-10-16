import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';

import 'explore.dart';

class StreamToExplore extends StatelessWidget{
  var userService = locator<UserService>();
  final Trip trip;
  StreamToExplore({this.trip});

  @override
  Widget build(BuildContext context) {


    return StreamProvider<List<ChatData>>.value(
      value: DatabaseService(tripDocID: trip.documentId, uid: userService.currentUserID).chatListNotification,
      child: Container (
        child: Explore(trip: trip,),
      ),
    );
  }
}