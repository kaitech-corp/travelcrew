import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/activity/edit_activity.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';

class ActivityItemLayout extends StatelessWidget {

  final userService = locator<UserService>();
  final ActivityData activity;
  final Trip trip;
  ActivityItemLayout({this.activity, this.trip});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {

          },
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
                      Text('${activity.activityType}',style: Theme.of(context).textTheme.headline1,),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),
                      Text('Comment: ${activity.comment}',style: Theme.of(context).textTheme.subtitle1,),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Owner: ${activity.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                          Text('Votes: ${activity.vote}',style: Theme.of(context).textTheme.subtitle1,),
                        ],
                      ),
                      Column (
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (activity.link?.isNotEmpty) Text('Link attached',style: Theme.of(context).textTheme.subtitle2,),
                          if (activity.urlToImage?.isNotEmpty) ImageLayout(activity.urlToImage),
                        ],
                      )
                    ],
                  ),
                ),
                activity.uid == userService.currentUserID ? ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: favorite(userService.currentUserID),
                      onPressed: () {
                        String fieldID = activity.fieldID;
                        if (!activity.voters.contains(userService.currentUserID)) {
                         return CloudFunction().addVoteToActivity(trip.documentId, fieldID);
                      // return DatabaseService(tripDocID: trip.documentId).addVoteToActivity(uid, fieldID);
                        } else {
                          return CloudFunction().removeVoteFromActivity(trip.documentId, fieldID);
                      // return DatabaseService(tripDocID: trip.documentId).removeVoteFromActivity(uid, fieldID);
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
                              if(activity.link.isNotEmpty) Navigator.push(
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
                        child: favorite(userService.currentUserID),
                        onPressed: () {
                          String fieldID = activity.fieldID;
                          if (!activity.voters.contains(userService.currentUserID)) {
                            return CloudFunction().addVoteToActivity(trip.documentId, fieldID);
                            // return DatabaseService(tripDocID: trip.documentId).addVoteToActivity(uid, fieldID);
                          } else {
                            return CloudFunction().removeVoteFromActivity(trip.documentId, fieldID);
                            // CloudFunction().removeVoterFromActivity(trip.documentId, fieldID);
                            // return DatabaseService(tripDocID: trip.documentId).removeVoteFromActivity(uid, fieldID);
                          }
                        }
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value){
                        switch (value){
                          case "report":
                            {
                              TravelCrewAlertDialogs().reportAlert(context: context, activityData: activity, type: 'activity');
                            }
                            break;
                          case "View": {
                            if (activity.link.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    WebViewScreen(activity.link, key)),
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
      ),
    );
  }
  favorite(String uid) {
    if (activity.voters.contains(uid)) {
      return Icon(Icons.favorite);
    } else {
      return Icon(Icons.favorite_border);
    }
  }
}
