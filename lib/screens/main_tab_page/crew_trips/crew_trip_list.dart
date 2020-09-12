import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';

class CrewTripList extends StatefulWidget {
  int type;
  CrewTripList({this.type});

  @override
  _CrewTripListState createState() => _CrewTripListState();

}

class _CrewTripListState extends State<CrewTripList> {
  @override
  Widget build(BuildContext context) {
    bool loading = true;
    var crewtrips = Provider.of<List<Trip>>(context);
    if(crewtrips != null) {
      setState(() {
        loading = false;
        if (widget.type == 1) {
          crewtrips = crewtrips.where((trip) => trip.endDateTimeStamp.toDate().isBefore(DateTime.now())).toList();

        } else {
          crewtrips = crewtrips.where((trip) =>
              trip.endDateTimeStamp.toDate().isAfter(DateTime.now())).toList();
        }
      });

    }
    return loading ? Loading() : ListView.builder(
      itemCount: crewtrips.length ?? 0,
      itemBuilder: (context, index){
        return TappableCrewTripTile(trip: crewtrips[index]);
      },);
  }
}

