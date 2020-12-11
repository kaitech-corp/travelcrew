import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/activity/edit_activity.dart';
import 'package:travelcrew/services/appearance_widgets.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/tc_functions.dart';
import 'package:travelcrew/services/reusableWidgets.dart';

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
          color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              if(activity.link.isNotEmpty) TCFunctions().launchURL(activity.link);
            },
            child: Container(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('${activity.activityType}',style: Theme.of(context).textTheme.headline4,maxLines: 2,),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),
                      if(activity.startTime.isNotEmpty) Text('${activity.startTime ?? ''} - ${activity.endTime ?? ''}',style: Theme.of(context).textTheme.headline6,),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),
                      if(activity.comment.isNotEmpty) Tooltip(message:activity.comment,child: Text(activity.comment,style: Theme.of(context).textTheme.subtitle1,maxLines: 10,overflow: TextOverflow.ellipsis,)),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),

                      if(activity.link.isNotEmpty) LinkPreview(link: activity.link),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${activity.displayName}',style: ReusableThemeColor().greenOrBlackTextColor(context),),
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
                      if(ThemeProvider.themeOf(context).id != 'light_theme') Container(height: 1,color: Colors.grey,)
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
      return const Icon(Icons.favorite,color: Colors.red,);
    } else {
      return const Icon(Icons.favorite_border,color: Colors.red);
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
            leading: IconThemeWidget(icon: Icons.edit),
            title: const Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'View',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.people),
            title: const Text('View Link'),
          ),
        ),
        const PopupMenuItem(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.delete),
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


