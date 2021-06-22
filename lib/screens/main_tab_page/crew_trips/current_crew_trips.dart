import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_grid.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';

class CurrentCrewTrips extends StatefulWidget{

  @override
  _CurrentCrewTripsState createState() => _CurrentCrewTripsState();

}

class _CurrentCrewTripsState extends State<CurrentCrewTrips>{

  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    new Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      builder: (context, trips){
        if(trips.hasError){
          CloudFunction().logError('Error streaming current trips: ${trips.error.toString()}');
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
      stream: DatabaseService().currentCrewTrips,
    );
  }



  }