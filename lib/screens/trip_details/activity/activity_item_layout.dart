import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/activity/edit_activity.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';

class ActivityItemLayout extends StatelessWidget {

  final ActivityData activity;
  final Trip trip;
  ActivityItemLayout({this.activity, this.trip});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);


    return Center(
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {

          },
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
//                ImageLayout(_text ?? "assests/images/barcelona.jpg"),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('${activity.activityType}', style: TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 1.25,),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),
                      Text('Comment: ${activity.comment}', style: TextStyle(fontSize: 16),),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Owner: ${activity.displayName}'),
                          Text('Votes: ${activity.vote}'),
                        ],
                      ),
                      Column (
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (activity.link?.isNotEmpty) Text('Link attached'),
                          if (activity.urlToImage?.isNotEmpty) ImageLayout(activity.urlToImage),
                        ],
                      )
                    ],
                  ),
                ),
                activity.uid == user.uid ? ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: favorite(user.uid),
                      onPressed: () {
                        String fieldID = activity.fieldID;
                        String uid = user.uid;
                        if (!activity.voters.contains(user.uid)) {
                      return DatabaseService(tripDocID: trip.documentId).addVoteToActivity(uid, fieldID);
                        } else {
                      return DatabaseService(tripDocID: trip.documentId).removeVoteFromActivity(uid, fieldID);
                        }
                      }
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value){
                        switch (value){
                          case "Edit": {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  EditActivity(activity: activity, trip: trip,)),
                            );
                          }
                          break;
                          case "View": {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    WebViewScreen(activity.link, key)),
                              );
                          }
                          break;
                          case "Delete": {
                            CloudFunction().removeActivity(trip.documentId, activity.fieldID);
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
                            title: Text('Delete Activity'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ):
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                        child: favorite(user.uid),
                        onPressed: () {
                          String fieldID = activity.fieldID;
                          String uid = user.uid;
                          if (!activity.voters.contains(user.uid)) {
                            CloudFunction().addVoteToActivity(trip.documentId, fieldID, uid);
                            // return DatabaseService(tripDocID: trip.documentId).addVoteToActivity(uid, fieldID);
                          } else {
                            // CloudFunction().removeVoteFromActivity(trip.documentId, fieldID, uid);
                            // CloudFunction().removeVoterFromActivity(trip.documentId, fieldID, uid);
                            return DatabaseService(tripDocID: trip.documentId).removeVoteFromActivity(uid, fieldID);
                          }
                        }
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value){
                        switch (value){
                          case "View": {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  WebViewScreen(activity.link, key)),
                            );
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
      ),
    );
  }
  favorite(String uid){
      if (activity.voters.contains(uid)) {
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
