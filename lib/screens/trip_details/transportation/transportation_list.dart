import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/transportation/transportation_item_layout.dart';


class TransportationList extends StatefulWidget {

  @override
  _TransportationListState createState() => _TransportationListState();
  bool loading = true;
}

class _TransportationListState extends State<TransportationList> {
  @override
  Widget build(BuildContext context) {

    final modeList = Provider.of<List<TransportationData>>(context);
    if(modeList != null) {
      setState(() {
        widget.loading = false;
      });
    }

    return ListView.builder(
        itemCount: modeList != null ? modeList.length : 0,
        itemBuilder: (context, index){
          return TransportationItemLayout(transportationData: modeList[index],);
        });
  }
}