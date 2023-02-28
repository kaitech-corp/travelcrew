import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/activity_model.dart';
import '../../../models/split_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/favorite_widget.dart';
import '../../../services/widgets/global_card.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../size_config/size_config.dart';
import '../split/split_package.dart';
import 'activity_menu_button.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({Key? key, required this.activity, required this.trip})
      : super(key: key);

  final ActivityData activity;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Center(
        key: Key(activity.fieldID),
        child: GlobalCard(
          widget: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              navigationService.navigateTo(DetailsPageRoute,
                  arguments: DetailsPageArguments(
                      type: 'Activity', activity: activity, trip: trip));
            },
            child: Container(
              margin: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
              child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ListTile(
                      visualDensity: const VisualDensity(vertical: -4),
                      title: Text(
                        activity.activityType,
                        style: SizeConfig.tablet
                            ? headlineLarge(context)
                            : titleLarge(context),
                        maxLines: 2,
                      ),
                      trailing: ActivityMenuButton(
                        activity: activity,
                        trip: trip,
                      ),
                      subtitle: activity.startTime.isNotEmpty
                          ? Text(
                              '${activity.startTime} - ${activity.endTime}',
                              style: titleSmall(context),
                            )
                          : null,
                    ),
                    if (activity.link.isNotEmpty)
                      ViewAnyLink(
                        link: activity.link,
                        function: () => <void>{},
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SplitPackage().splitItemExist(
                            context,
                            SplitObject(
                                itemDocID: activity.fieldID,
                                tripDocID: trip.documentId,
                                users: trip.accessUsers,
                                itemName: activity.activityType,
                                itemDescription: activity.comment,
                                itemType: 'Activity', dateCreated: Timestamp.now(), details: '', userSelectedList: <String>[], amountRemaining: 0, itemTotal: 0, lastUpdated: Timestamp.now(), purchasedByUID: ''),
                            trip: trip),
                        IconButton(
                            visualDensity: const VisualDensity(vertical: -4),
                            icon: FavoriteWidget(
                              uid: userService.currentUserID,
                              voters: activity.voters,
                            ),
                            onPressed: () {
                              final String fieldID = activity.fieldID;
                              if (!activity.voters
                                  .contains(userService.currentUserID)) {
                                CloudFunction().addVoterToActivity(
                                    trip.documentId, fieldID);
                              } else {
                                CloudFunction().removeVoterFromActivity(
                                    trip.documentId, fieldID);
                              }
                            }),
                      ],
                    ),
                  ]),
            ),
          ),
        ));
  }
}
