import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import '../../../loading.dart';

class PastCrewTrips extends StatefulWidget{

  @override
  _PastCrewTripsState createState() => _PastCrewTripsState();

}

class _PastCrewTripsState extends State<PastCrewTrips>{

  // @override
  // bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Positioned.fill(
          // top: defaultSize.toDouble() * 10.5,
          child: StreamBuilder(
            builder: (context, trips){
              if(trips.hasError){
                CloudFunction().logError('Error streaming past trips: ${trips.error.toString()}');
              }
              if(trips.hasData){
                List<Trip> tripList = trips.data;
                return ListView.builder(
                  padding: EdgeInsets.all(0.0),
                  itemCount: tripList.length ?? 0,
                  itemBuilder: (context, index){
                    return TappableCrewTripTile(trip: tripList[index]);
                  },
                );
              } else {
                return Loading();
              }
            },
            stream: DatabaseService().pastCrewTrips,
          ),)
      ],
    );
  }

}