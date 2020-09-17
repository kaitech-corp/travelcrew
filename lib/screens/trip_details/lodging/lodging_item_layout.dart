import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/screens/trip_details/lodging/edit_lodging.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';

class LodgingItemLayout extends StatelessWidget {

  final LodgingData lodging;
  final Trip trip;
  LodgingItemLayout({this.lodging, this.trip});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return Center(
      child: Card(
          child: Container(
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
                      Text('${lodging.lodgingType}', style: TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 1.25,),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${lodging.displayName}', style: TextStyle(fontSize: 16)),
                        Text('Likes: ${lodging.vote}'),
                      ],
                    ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),
                      Text('Comment: ${lodging.comment}'),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),
                      Column (
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                           if (lodging.link.isNotEmpty ) Text('Link attached'),
                          if (lodging.urlToImage.isNotEmpty) ImageLayout(lodging.urlToImage),
                        ],
                      )
                    ],
                  ),
                ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: favorite(user.uid),
                        onPressed: () {
                          String fieldID = lodging.fieldID;
                          String uid = user.uid;
                          if (!lodging.voters.contains(user.uid)) {
                            CloudFunction().addVoteToLodging(trip.documentId, fieldID);
                            CloudFunction().addVoterToLodging(trip.documentId, fieldID, uid);
                          } else {
                            CloudFunction().removeVoteFromLodging(trip.documentId, fieldID);
                            CloudFunction().removeVoterFromLodging(trip.documentId, fieldID, uid);
                          }
                        }
                    ),
                    lodging.uid == user.uid ? PopupMenuButton<String>(
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
                            Navigator.push(
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
