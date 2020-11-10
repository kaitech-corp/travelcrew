import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/activity/edit_activity.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';

class ActivityItemLayout extends StatelessWidget {

  final userService = locator<UserService>();
  final ActivityData activity;
  final Trip trip;
  ActivityItemLayout({this.activity, this.trip});

  @override
  Widget build(BuildContext context) {

    return Center(
        key: Key(activity.fieldID),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              if(activity.link.isNotEmpty) TCFunctions().launchURL(activity.link);
            },
            child: Container(
              width: SizeConfig.screenWidth *.9,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(
                    offset: const Offset(0, 10),
                    blurRadius: 33,
                    color: Color(Colors.blueGrey.value).withOpacity(.84),
                    spreadRadius: 5,
                  )
                  ]),
              child: Container(
                margin: const EdgeInsets.only(left: 10,top: 10, right: 10, bottom: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('${activity.activityType}',style: Theme.of(context).textTheme.headline4,maxLines: 2,),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),
                      Text('Comment: ${activity.comment}',style: Theme.of(context).textTheme.subtitle1,maxLines: 5,overflow: TextOverflow.ellipsis,),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),
                      Visibility(
                        visible: activity.startTime.isNotEmpty,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Start: ${activity.startTime ?? ''}',style: Theme.of(context).textTheme.subtitle1,),
                            Text('End: ${activity.endTime ?? ''}',style: Theme.of(context).textTheme.subtitle1,),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${activity.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                          Row(
                            children: [
                              if(activity.link.isNotEmpty) Icon(Icons.link),
                              IconButton(
                                  icon: favorite(userService.currentUserID),
                                  onPressed: () {
                                    String fieldID = activity.fieldID;
                                    if (!activity.voters.contains(userService.currentUserID)) {
                                      return CloudFunction().addVoterToActivity(trip.documentId, fieldID);
                                      // return DatabaseService(tripDocID: trip.documentId).addVoteToActivity(uid, fieldID);
                                    } else {
                                      return CloudFunction().removeVoterFromActivity(trip.documentId, fieldID);
                                      // return DatabaseService(tripDocID: trip.documentId).removeVoteFromActivity(uid, fieldID);
                                    }
                                  }
                              ),
                              Text('${activity.voters.length}',style: Theme.of(context).textTheme.subtitle1,),
                              menuButton(context),
                            ],
                          ),
                        ],
                      ),
                    ]
                ),
              ),
            ),
          ),
        )
    );
  }
  favorite(String uid) {
    if (activity.voters.contains(uid)) {
      return const Icon(Icons.favorite);
    } else {
      return const Icon(Icons.favorite_border);
    }
  }

  Widget menuButton(BuildContext context){
    return activity.uid == userService.currentUserID ? PopupMenuButton<String>(
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
            if(activity.link.isNotEmpty) TCFunctions().launchURL(activity.link);
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
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Delete Activity'),
          ),
        ),
      ],
    ):
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
              TCFunctions().launchURL(activity.link);
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
            leading: const Icon(Icons.link),
            title: const Text('View Link'),
          ),
        ),
      ],
    );
  }
}
