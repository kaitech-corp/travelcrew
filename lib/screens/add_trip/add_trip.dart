import 'package:flutter/material.dart';
import 'package:travelcrew/screens/add_trip/add_trip_widget.dart';
import 'package:travelcrew/services/database.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';


class AddTrip extends StatelessWidget{

  AddTrip();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamProvider<UserProfile>.value(
      value: DatabaseService(uid: user.uid).currentUserPublicProfile,
      child: Container (
        child: HomeMaterial(),
      ),
    );
  }
}