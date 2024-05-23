import 'package:flutter/material.dart';

import '../../../models/activity_model/activity_model.dart';
import '../../../models/split_model/split_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/favorite_widget.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../size_config/size_config.dart';
import '../../Split/split_package.dart';
import '../logic/logic.dart';
import 'activity_menu_button.dart';
import 'card_layout.dart';

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
    return CardLayout(
      link: activity.link,
      viewAnyLink: _buildViewAnyLink(),
      detailsCard: _buildDetailsCard(context),
      buttonRow: _buildRow(context),
      navigationFunction: _openDetailsPage,
      menuButton: _buildActivityMenuButton(),
    );
  }
  

  void _openDetailsPage() {
    navigationService.navigateTo(DetailsPageRoute,
        arguments: DetailsPageArguments(
          type: 'Activity',
          activity: activity,
          trip: trip,
        ));
  }

  Widget _buildActivityMenuButton() {
    return ActivityMenuButton(activity: activity, trip: trip);
  }

  Widget _buildViewAnyLink() {
    return ViewAnyLink(
      hash: activity.hashCode,
      link: activity.link,
      multiMediaonly: true,
      function: _openDetailsPage,
    );
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
         Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Start: ${activity.startTime}',
                style: labelLarge(context),
              ),
              Text(
                'End: ${activity.endTime}',
                style: labelLarge(context),
              ),
            ],
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
          updateActivityVote(trip.documentId, fieldID, true);
        } else {
          updateActivityVote(trip.documentId, fieldID, false);
        }
      },
    );
  }
}
