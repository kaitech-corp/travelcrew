import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/flight/flight_item_layout.dart';


class FlightList extends StatefulWidget {
  @override
  _FlightListState createState() => _FlightListState();
  bool loading = true;
}

class _FlightListState extends State<FlightList> {
  @override
  Widget build(BuildContext context) {

    final flightList = Provider.of<List<FlightData>>(context);
    if(flightList != null) {
      setState(() {
        widget.loading = false;
      });
    }

    return ListView.builder(
        itemCount: flightList != null ? flightList.length : 0,
        itemBuilder: (context, index){
          return FlightItemLayout(flight: flightList[index],);
        });
  }
}