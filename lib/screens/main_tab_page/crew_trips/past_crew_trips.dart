import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_tile.dart';
import 'package:travelcrew/services/database.dart';
import '../../../loading.dart';

class PastCrewTrips extends StatefulWidget{

  @override
  _PastCrewTripsState createState() => _PastCrewTripsState();

}

class _PastCrewTripsState extends State<PastCrewTrips>with
    AutomaticKeepAliveClientMixin<PastCrewTrips>{

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        // Container(
        //   height: SizeConfig.screenHeight,
        //   width: SizeConfig.screenWidth,
        //   // color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black,
        //   decoration: BoxDecoration(
        //     image: DecorationImage(
        //       image: (ThemeProvider.themeOf(context).id == 'light_theme') ? AssetImage(skyImage) : AssetImage(spaceImage),
        //       fit: BoxFit.fitHeight,
        //     ),
        //   ),
        // ),
        // HangingImageTheme(),
        Positioned.fill(
          // top: defaultSize.toDouble() * 10.5,
          child: StreamBuilder(
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
            stream: DatabaseService().pastCrewTrips,
          ),)
      ],
    );
  }

}