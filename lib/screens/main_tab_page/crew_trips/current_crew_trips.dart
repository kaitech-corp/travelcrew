import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/reusableWidgets.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../../loading.dart';

class CurrentCrewTrips extends StatefulWidget{

  @override
  _CurrentCrewTripsState createState() => _CurrentCrewTripsState();

}

class _CurrentCrewTripsState extends State<CurrentCrewTrips>with
    AutomaticKeepAliveClientMixin<CurrentCrewTrips>{

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    new Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      builder: (context, trips){
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
      stream: DatabaseService().currentCrewTrips,
    );
  }

  }