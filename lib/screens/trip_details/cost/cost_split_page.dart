import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/cost/progress_bar.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';

import '../../../services/widgets/loading.dart';

class CostPage extends StatelessWidget{

  final Trip tripDetails;
  CostPage({this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Split', ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Container(
            child: BringListCostDisplay(tripDocID: tripDetails.documentId,),
          ),
        ),
      )
    );
  }

}

class BringListCostDisplay extends StatelessWidget{

  final String tripDocID;
  BringListCostDisplay({this.tripDocID});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        height: MediaQuery.of(context).size.height,
        child: bringList(),
      ),
    );
  }

  Widget bringList() {
    return StreamBuilder(
      builder: (context, items) {
        if (items.hasData) {
          return ListView.builder(
            itemCount: items.data.length,
            itemBuilder: (context, index) {
              Bringing item = items.data[index];
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      key: Key(item.documentID),
                      onLongPress: (){
                        TravelCrewAlertDialogs().deleteBringinItemAlert(context, tripDocID, item.documentID);
                      },
                      leading: CircleAvatar(child: Icon(Icons.shopping_basket),),
                      title: Text(item.item.toUpperCase(),style: Theme.of(context).textTheme.subtitle1,),
                      subtitle: Text(item.displayName,style: Theme.of(context).textTheme.subtitle2,),
                      trailing: Text('\$100'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ProgressBarWidget(currentValue: 20, maxValue: 100,)
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ExpandablePanel(
                        header: Text('Details', style: Theme.of(context).textTheme.headline2,),
                        // collapsed:
                        expanded: Container(
                          height: SizeConfig.screenHeight*.3,
                          width: SizeConfig.screenWidth,
                          child: ListView.builder(
                            itemCount: 3,
                              itemBuilder: (context, index){
                              return ListTile(
                                title: Text('User $index'),
                                trailing: Text('\$33.33'),
                              );
                              }),
                        )
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Loading();
        }
      },
      stream: DatabaseService().getBringingList(tripDocID),
      // future: ,
    );
  }
  favorite(Bringing item){
    if (item.voters?.contains(currentUserProfile.uid) ?? false){
      return const Icon(Icons.favorite,color: Colors.red);
    } else {
      return const Icon(Icons.favorite_border,color: Colors.red);
    }
  }
}