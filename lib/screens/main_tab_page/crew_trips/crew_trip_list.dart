import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';
import 'package:travelcrew/services/constants.dart';

class CrewTripList extends StatefulWidget {
  final int type;
  CrewTripList({this.type});


  @override
  _CrewTripListState createState() => _CrewTripListState();

}

class _CrewTripListState extends State<CrewTripList> {


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    var yesterday = DateTime(now.year, now.month, now.day - 1);
    bool loading = true;
    var crewTrips = Provider.of<List<Trip>>(context);

    if(crewTrips != null) {
      setState(() {
        loading = false;
        if (widget.type == 1) {
          crewTrips = crewTrips.where((trip) => yesterday.isAfter(trip.endDateTimeStamp.toDate())).toList().reversed.toList();
        } else {
          crewTrips = crewTrips.where((trip) =>
              trip.endDateTimeStamp.toDate().isAfter(yesterday)).toList();

        }
      });
    }
    return loading ? Loading() : Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (ThemeProvider.themeOf(context).id == 'light_theme') ? AssetImage(skyImage) : AssetImage(spaceImage),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView.builder(
        itemCount: crewTrips.length ?? 0,
        itemBuilder: (context, index){
          return TappableCrewTripTile(trip: crewTrips[index]);
        },
      ),
    );
  }
}

