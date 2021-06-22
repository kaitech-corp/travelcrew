import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_grid.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';

class PrivateTripList extends StatefulWidget {


  @override
  _PrivateTripListState createState() => _PrivateTripListState();
}

class _PrivateTripListState extends State<PrivateTripList>{

  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: privateTrips(context),
    );
  }

  Widget privateTrips(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          // top: defaultSize.toDouble() * 10.5,
          child: StreamBuilder(
            builder: (context, trips){
              if(trips.hasError){
                CloudFunction().logError('Error streaming private trips: ${trips.error.toString()}');
              }
              if(trips.hasData){
                List<Trip> tripList = trips.data;
                return SizeConfig.tablet ?
                SliverGridView(trips: tripList, length: tripList.length):
                ListView.builder(
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
            stream: DatabaseService().privateTrips,
          ),
        ),
      ],
    );
  }
}