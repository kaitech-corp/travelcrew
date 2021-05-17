import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/navigation/router.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/widgets/link_previewer.dart';


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
          margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              if(activity.link.isNotEmpty) TCFunctions().launchURL(activity.link);
            },
            child: Container(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('${activity.activityType}',style: Theme.of(context).textTheme.headline4,maxLines: 2,),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                    ),
                    if(activity.startTime?.isNotEmpty ?? false) Text('${activity.startTime ?? ''} - ${activity.endTime ?? ''}',style: Theme.of(context).textTheme.headline6,),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                    ),
                    if(activity.comment?.isNotEmpty ?? false) Tooltip(message:activity.comment,child: Text(activity.comment,style: Theme.of(context).textTheme.subtitle1,maxLines: 10,overflow: TextOverflow.ellipsis,)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                    ),

                    if(activity.link?.isNotEmpty ?? false) FlutterLinkView(link: activity.link),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${activity.displayName}',style: ReusableThemeColor().greenOrBlueTextColor(context),),
                        Row(
                          children: [
                            if(activity.link.isNotEmpty) IconThemeWidget(icon:Icons.link),
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
      icon: IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (value){
        switch (value){
          case "Edit": {
            navigationService.navigateTo(EditActivityRoute, arguments: EditActivityArguments(activity, trip));
          }
          break;
          case "View": {
            if(activity.link.isNotEmpty) TCFunctions().launchURL(activity.link);
          }
          break;
          case "Finalize": {
            TravelCrewAlertDialogs().finalizeOptionAlert(context, activity.fieldID);

          }
          break;
          default: {
            CloudFunction().removeLodging(trip.documentId, activity.fieldID);
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
        // const PopupMenuItem(
        //   value: 'Finalize',
        //   child: ListTile(
        //     leading: IconThemeWidget(icon: Icons.check_circle_outline),
        //     title: const Text('Finalize'),
        //   ),
        // ),
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
      icon: IconThemeWidget(icon: Icons.more_horiz,),
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
            leading: IconThemeWidget(icon:Icons.report),
            title: const Text('Report'),
          ),
        ),
        const PopupMenuItem(
          value: 'View',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.link),
            title: const Text('View Link'),
          ),
        ),
      ],
    );
  }
}


