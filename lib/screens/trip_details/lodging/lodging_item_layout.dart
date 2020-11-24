import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/lodging/edit_lodging.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/tc_functions.dart';


class LodgingItemLayout extends StatelessWidget {

  var userService = locator<UserService>();
  final LodgingData lodging;
  final Trip trip;

  LodgingItemLayout({this.lodging, this.trip});

  @override
  Widget build(BuildContext context) {

    

    return Center(
        key: Key(lodging.fieldID),
      child: Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              if(lodging.link.isNotEmpty) TCFunctions().launchURL(lodging.link);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('${lodging.lodgingType}',style: Theme.of(context).textTheme.headline4,),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                  ),
                  if(lodging.comment.isNotEmpty) Text(lodging.comment,style: Theme.of(context).textTheme.subtitle1,),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                  ),
                  if(lodging.startTime.isNotEmpty) Text('${lodging.startTime ?? ''} - ${lodging.endTime ?? ''}',style: Theme.of(context).textTheme.headline6,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('${lodging.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                      Row(
                        children: [
                          if(lodging.link.isNotEmpty) Icon(Icons.link),
                          IconButton(
                              icon: favorite(userService.currentUserID),
                              onPressed: () {
                                String fieldID = lodging.fieldID;
                                String uid = userService.currentUserID;
                                if (!lodging.voters.contains(userService.currentUserID)) {
                                  // CloudFunction().addVoteToLodging(trip.documentId, fieldID);
                                  CloudFunction().addVoterToLodging(trip.documentId, fieldID, uid);
                                } else {
                                  // CloudFunction().removeVoteFromLodging(trip.documentId, fieldID);
                                  CloudFunction().removeVoterFromLodging(trip.documentId, fieldID, uid);
                                }
                              }
                          ),
                          Text('${lodging.voters.length}',style: Theme.of(context).textTheme.subtitle1,),
                          menuButton(context),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
    ));
  }
  favorite(String uid){
    if (lodging.voters.contains(uid)){
      return const Icon(Icons.favorite,color: Colors.red);
    } else {
      return const Icon(Icons.favorite_border,color: Colors.red);
    }
  }

  Widget menuButton(BuildContext context){
    return lodging.uid == userService.currentUserID ? PopupMenuButton<String>(
      onSelected: (value){
        switch (value){
          case "Edit": {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  EditLodging(lodging: lodging, trip: trip,)),
            );
          }
          break;
          case "View": {
            if(lodging.link.isNotEmpty) TCFunctions().launchURL(lodging.link);
          }
          break;
          case "Delete": {
            CloudFunction().removeLodging(trip.documentId, lodging.fieldID);
          }
          break;
          default: {

          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>[
        const PopupMenuItem(
          value: 'Edit',
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'View',
          child: ListTile(
            leading: const Icon(Icons.people),
            title: const Text('View Link'),
          ),
        ),
        const PopupMenuItem(
          value: 'Delete',
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Lodging'),
          ),
        ),
      ],
    ):
    PopupMenuButton<String>(
      onSelected: (value){
        switch (value){
          case "report":
            {
              TravelCrewAlertDialogs().reportAlert(context: context, lodgingData: lodging, type: 'lodging');
            }
            break;
          case "View": {
            if (lodging.link.isNotEmpty) {
              TCFunctions().launchURL(lodging.link);
            }
          }
          break;
          default: {

          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>[
        const PopupMenuItem(
          value: 'report',
          child: ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report'),
          ),
        ),
        const PopupMenuItem(
          value: 'View',
          child: ListTile(
            leading: const Icon(Icons.people),
            title: const Text('View Link'),
          ),
        ),
      ],
    );
  }
}
