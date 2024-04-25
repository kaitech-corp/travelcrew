import 'package:flutter/material.dart';

import '../../../models/activity_model/activity_model.dart';
import '../../../models/split_model/split_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions/detail_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/favorite_widget.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../size_config/size_config.dart';
import '../../Split/split_package.dart';
import 'activity_menu_button.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.trip,
  });

  final ActivityModel activity;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(defaultPadding),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          navigationService.navigateTo(DetailsPageRoute,
              arguments: DetailsPageArguments(
                type: 'Activity',
                activity: activity,
                trip: trip,
              ));
        },
        child: SizedBox(
          width: SizeConfig.screenWidth * 0.8,
          height: activity.link.isNotEmpty ? SizeConfig.screenHeight * .2 : SizeConfig.screenHeight * .1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                     if(activity.link.isNotEmpty) Expanded(
                        flex: 3,
                        child: _buildViewAnyLink()),
                      Flexible(
                        flex: 2,
                        child: _buildDetailsCard(context)),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _buildRow(context),
                            _buildActivityMenuButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: SizeConfig.blockSizeHorizontal * 3,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityMenuButton() {
    return ActivityMenuButton(activity: activity, trip: trip);
  }

  Widget _buildViewAnyLink() {
    return activity.link.isNotEmpty
        ? ViewAnyLink(
            link: activity.link,
            function: () => {},
          )
        : const SizedBox.shrink();
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          activity.activityType,
          style:
              SizeConfig.tablet ? headlineLarge(context) : titleMedium(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (activity.startTime.isNotEmpty)
          Text(
            '${activity.startTime} - ${activity.endTime}',
            style: titleSmall(context),
          )
        
      ],
    );
  }

  Widget _buildRow(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildSplitPackage(context),
        _buildFavoriteButton(context),
      ],
    );
  }

  Widget _buildSplitPackage(BuildContext context) {
    return SplitPackage().splitItemExist(
      context,
      SplitObject(
        itemDocID: activity.fieldID,
        tripDocID: trip.documentId,
        users: trip.accessUsers,
        itemName: activity.activityType,
        itemDescription: activity.comment,
        itemType: 'Activity',
        dateCreated: DateTime.now(),
        details: '',
        userSelectedList: <String>[],
        amountRemaining: 0,
        itemTotal: 0,
        lastUpdated: DateTime.now(),
        purchasedByUID: '',
      ),
      trip: trip,
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return IconButton(
      visualDensity: const VisualDensity(vertical: -4),
      icon: FavoriteWidget(
        uid: userService.currentUserID,
        voters: activity.voters,
      ),
      onPressed: () {
        final String fieldID = activity.fieldID;
        if (!activity.voters.contains(userService.currentUserID)) {
          DetailCloudFunction().addVoterToActivity(trip.documentId, fieldID);
        } else {
          DetailCloudFunction()
              .removeVoterFromActivity(trip.documentId, fieldID);
        }
      },
    );
  }
}
