import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';

import 'explore.dart';

class Stream_to_Explore extends StatelessWidget{
  final Trip trip;
  Stream_to_Explore({this.trip});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamProvider<List<ChatData>>.value(
      value: DatabaseService(tripDocID: trip.documentId, uid: user.uid).chatListNotification,
      child: Container (
        child: Explore(trip: trip,),
      ),
    );
  }
}