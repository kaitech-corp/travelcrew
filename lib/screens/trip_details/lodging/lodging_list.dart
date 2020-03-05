import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';

import 'lodging_item_layout.dart';

class LodgingList extends StatefulWidget {

  final String tripDocID;
  LodgingList({this.tripDocID});

  @override
  _LodgingListState createState() => _LodgingListState();

}

class _LodgingListState extends State<LodgingList> {
  @override
  Widget build(BuildContext context) {

    final lodgingList = Provider.of<List<LodgingData>>(context);


    return ListView.builder(
        itemCount: lodgingList != null ? lodgingList.length : 0,
        itemBuilder: (context, index){
          return LodgingItemLayout(lodging: lodgingList[index],tripDocID: widget.tripDocID,);
        });
  }
}

