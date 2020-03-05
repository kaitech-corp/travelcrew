import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/loading.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_list.dart';

class CrewTripList extends StatefulWidget {
  @override
  _CrewTripListState createState() => _CrewTripListState();

}

class _CrewTripListState extends State<CrewTripList> {
  @override
  Widget build(BuildContext context) {
    bool loading = true;
    final crewtrips = Provider.of<List<Trip>>(context);
    if(crewtrips != null) {
      setState(() {
        loading = false;
      });
    }
    return loading ? Loading() : ListView.builder(
        itemCount: crewtrips.length ?? 0,
        itemBuilder: (context, index){
          return TappableCrewTripCard(trip: crewtrips[index]);
        },);
  }
}