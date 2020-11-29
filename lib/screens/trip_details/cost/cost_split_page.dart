import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/database.dart';

import '../../../loading.dart';

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
        height: MediaQuery.of(context).size.height * .4,
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
              return ListTile(
                key: Key(item.documentID),
                onLongPress: (){
                  TravelCrewAlertDialogs().deleteBringinItemAlert(context, tripDocID, item.documentID);
                },
                leading: CircleAvatar(child: Icon(Icons.shopping_basket),),
                title: Text(item.item.toUpperCase(),style: Theme.of(context).textTheme.subtitle1,),
                subtitle: Text(item.displayName,style: Theme.of(context).textTheme.subtitle2,),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: (){

                  },
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