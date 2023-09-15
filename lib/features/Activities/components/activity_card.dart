import 'package:flutter/material.dart';

import '../../../models/activity_model/activity_model.dart';
import '../../../models/split_model/split_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/favorite_widget.dart';
import '../../../services/widgets/link_previewer.dart';
import '../../../size_config/size_config.dart';

import '../../Split/split_package.dart';
import 'activity_menu_button.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity, required this.trip});

  final ActivityModel activity;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () {
        navigationService.navigateTo(DetailsPageRoute,
            arguments: DetailsPageArguments(
                type: 'Activity', activity: activity, trip: trip));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _buildViewAnyLink(),
            _buildListTile(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _buildRow(context),
                _buildActivityMenuButton(),
              ],
            ),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMenuButton() {
    return ActivityMenuButton(activity: activity, trip: trip);
  }

  Widget _buildViewAnyLink() {
    if (activity.link.isNotEmpty) {
      return ViewAnyLink(
        link: activity.link,
        function: () => <void>{},
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildListTile(BuildContext context) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -4),
      title: Text(
        activity.activityType,
        style: SizeConfig.tablet ? headlineLarge(context) : titleLarge(context),
        maxLines: 2,
      ),
      subtitle: activity.startTime.isNotEmpty
          ? Text(
              '${activity.startTime} - ${activity.endTime}',
              style: titleSmall(context),
            )
          : null,
    );
  }

  Widget _buildRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          purchasedByUID: ''),
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
          CloudFunction().addVoterToActivity(trip.documentId, fieldID);
        } else {
          CloudFunction().removeVoterFromActivity(trip.documentId, fieldID);
        }
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(height: 2, color: Colors.grey[200]),
    );
  }
}
