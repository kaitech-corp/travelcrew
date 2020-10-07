import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/screens/trip_details/lodging/edit_lodging.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';


class LodgingItemLayout extends StatelessWidget {

  var userService = locator<UserService>();
  final LodgingData lodging;
  final Trip trip;

  LodgingItemLayout({this.lodging, this.trip});

  @override
  Widget build(BuildContext context) {

    

    return Center(
      child: Card(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(
                  offset: Offset(0, 10),
                  blurRadius: 33,
                  color: Color(Colors.blueGrey.value).withOpacity(.84),
                  spreadRadius: 5,
                )
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                 Container(
                   padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('${lodging.lodgingType}',style: Theme.of(context).textTheme.headline1,),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),
                      Text('Comment: ${lodging.comment}',style: Theme.of(context).textTheme.subtitle1,),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${lodging.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                        Text('Votes: ${lodging.vote}',style: Theme.of(context).textTheme.subtitle1,),
                      ],
                    ),
                      Column (
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                           if (lodging.link.isNotEmpty ) Text('Link attached',style: Theme.of(context).textTheme.subtitle1,),
                          if (lodging.urlToImage.isNotEmpty) ImageLayout(lodging.urlToImage),
                        ],
                      )
                    ],
                  ),
                ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: favorite(userService.currentUserID),
                        onPressed: () {
                          String fieldID = lodging.fieldID;
                          String uid = userService.currentUserID;
                          if (!lodging.voters.contains(userService.currentUserID)) {
                            CloudFunction().addVoteToLodging(trip.documentId, fieldID);
                            CloudFunction().addVoterToLodging(trip.documentId, fieldID, uid);
                          } else {
                            CloudFunction().removeVoteFromLodging(trip.documentId, fieldID);
                            CloudFunction().removeVoterFromLodging(trip.documentId, fieldID, uid);
                          }
                        }
                    ),
                    lodging.uid == userService.currentUserID ? PopupMenuButton<String>(
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
                            if(lodging.link.isNotEmpty) Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  WebViewScreen(lodging.link, key)),
                            );
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
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'View',
                          child: ListTile(
                            leading: Icon(Icons.people),
                            title: Text('View Link'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Delete',
                          child: ListTile(
                            leading: Icon(Icons.exit_to_app),
                            title: Text('Delete Lodging'),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  WebViewScreen(lodging.link, key)),
                            );
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
                            leading: Icon(Icons.report),
                            title: Text('Report'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'View',
                          child: ListTile(
                            leading: Icon(Icons.people),
                            title: Text('View Link'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }
  favorite(String uid){
    if (lodging.voters.contains(uid)){
      return Icon(Icons.favorite);
    } else {
      return Icon(Icons.favorite_border);
    }
  }
  void userAlertDialog(BuildContext context) {

    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Currently under development.'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {

                },
                child: Text('Thank you for you patience.'),
              ),
            ],
          );
        }
    );
  }
}
