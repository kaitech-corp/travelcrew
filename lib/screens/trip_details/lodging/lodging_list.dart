import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/lodging_model.dart';
import 'package:travelcrew/models/trip_model.dart';

import '../../../services/widgets/loading.dart';
import 'lodging_item_layout.dart';

class LodgingList extends StatefulWidget {

  final Trip trip;
  LodgingList({this.trip});

  @override
  _LodgingListState createState() => _LodgingListState();

}

class _LodgingListState extends State<LodgingList> {
  @override
  Widget build(BuildContext context) {

    final lodgingList = Provider.of<List<LodgingData>>(context);
    bool loading = true;
    if(lodgingList != null) {
      setState(() {
        loading = false;
      });

    }

    return loading ? Loading() : ListView.builder(
        itemCount: lodgingList != null ? lodgingList.length : 0,
        itemBuilder: (context, index){
          return LodgingItemLayout(lodging: lodgingList[index],trip: widget.trip,);
        });
  }
}

