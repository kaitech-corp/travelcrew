import 'package:flutter/material.dart';

import '../../../models/activity_model.dart';
import '../../../models/split_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/widgets/favorite_widget.dart';
import '../../../services/widgets/global_card.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../size_config/size_config.dart';
import '../split/split_package.dart';
import 'activity_menu_button.dart';


class ActivityCard extends StatelessWidget {

  final ActivityData activity;
  final Trip trip;

  ActivityCard({this.activity, this.trip});


  @override
  Widget build(BuildContext context) {
    return Center(
        key: Key(activity.fieldID),
        child: GlobalCard(
          widget: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: (){
              navigationService.navigateTo(
                  DetailsPageRoute,
                  arguments: DetailsPageArguments(
                      type: 'Activity', activity: activity, trip: trip));
            },
            child: Container(
              margin: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ListTile(
                      visualDensity: const VisualDensity(
                          horizontal: 0, vertical: -4),
                      title: Text('${activity.activityType}',
                        style: SizeConfig.tablet ?
                        Theme
                            .of(context)
                            .textTheme
                            .headline4 :
                        Theme
                            .of(context)
                            .textTheme
                            .headline6,
                        maxLines: 2,
                      ),
                      trailing: ActivityMenuButton(
                        activity: activity, trip: trip,),
                      subtitle: activity.startTime?.isNotEmpty ?? false ?
                      Text('${activity.startTime ?? ''} - ${activity.endTime ??
                          ''}',
                        style: Theme
                            .of(context)
                            .textTheme
                            .subtitle2,) :
                      null,
                    ),
                    if(activity.link?.isNotEmpty ?? false)
                      ViewAnyLink(link: activity.link,function: ()=>{},),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SplitPackage().splitItemExist(context,
                            SplitObject(
                                itemDocID: activity.fieldID,
                                tripDocID: trip.documentId,
                                users: trip.accessUsers,
                                itemName: activity.activityType,
                                itemDescription: activity.comment,
                                itemType: "Activity"), trip: trip),
                        IconButton(
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            icon: FavoriteWidget(
                              uid: userService.currentUserID,
                              voters: activity.voters,),
                            onPressed: () {
                              String fieldID = activity.fieldID;
                              if (!activity.voters.contains(
                                  userService.currentUserID)) {
                                return CloudFunction().addVoterToActivity(trip
                                    .documentId, fieldID);
                              } else {
                                return CloudFunction().removeVoterFromActivity(
                                    trip.documentId, fieldID);
                              }
                            }
                        ),
                      ],
                    ),
                  ]
              ),
            ),
          ),
        )
    );
  }
}


