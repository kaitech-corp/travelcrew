import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/explore/lists/item_lists.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';

class ListPage extends StatelessWidget{

  final Trip tripDetails;

  const ListPage({Key key, this.tripDetails}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child:
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Who's bringing what...",style: Theme.of(context).textTheme.headline6,),
                      ),
                      IconThemeWidget(icon: EvaIcons.arrowDown)
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: BringListToDisplay(tripDocID: tripDetails.documentId,)),
              ],
            )
    ),
          Expanded(
            flex: 1,
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Items still needed...",style: Theme.of(context).textTheme.headline6,),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: NeedListToDisplay(documentID: tripDetails.documentId,)),
              ],
            )
    )
        ],
      ),
    );
  }

}