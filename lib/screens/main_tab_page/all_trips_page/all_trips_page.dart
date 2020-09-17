import 'package:flutter/material.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/all_trips_new_design.dart';
import 'package:travelcrew/services/database.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';


class AllTripsPage extends StatelessWidget{

  AllTripsPage();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Trip>>.value(
      value: DatabaseService().trips,
      child: Container (
        // height: MediaQuery.of(context).size.height,
        child: AllTripsNewDesign(),
      ),
    );
  }
}