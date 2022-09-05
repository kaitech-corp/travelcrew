import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import '../../../../models/trip_model.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import 'item_lists.dart';

/// List page
class ListPage extends StatelessWidget{

  const ListPage({Key? key, required this.trip}) : super(key: key);

  final Trip trip;
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Who's bringing what...",style: Theme.of(context).textTheme.headline6,),
                      ),
                      const IconThemeWidget(icon: EvaIcons.arrowDown)
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: BringListToDisplay(tripDocID: trip.documentId,)),
              ],
            )
    ),
          Expanded(
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Items still needed...',style: Theme.of(context).textTheme.headline6,),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: NeedListToDisplay(documentID: trip.documentId,)),
              ],
            )
    )
        ],
      ),
    );
  }

}