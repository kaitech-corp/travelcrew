import 'package:flutter/material.dart';

import '../../../../services/database.dart';
import '../../../../services/navigation/route_names.dart';
import '../../../../services/navigation/router.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/link_previewer.dart';
import '../../../../size_config/size_config.dart';
import '../../../models/lodging_model/lodging_model.dart';
import '../../../models/split_model/split_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/widgets/favorite_widget.dart';
import '../../Activities/components/card_layout.dart';
import '../../Split/split_package.dart';
import '../logic/logic.dart';
import 'lodging_menu_button.dart';

class LodgingCard extends StatelessWidget {
  const LodgingCard({
    super.key,
    required this.lodging,
    required this.trip,
  });
  final LodgingModel lodging;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      link: lodging.link,
      viewAnyLink: _buildViewAnyLink(),
      detailsCard: _buildDetailsCard(context),
      buttonRow: _buildRow(context),
      navigationFunction: _openDetailsPage,
      menuButton: _buildlodgingMenuButton(),
    );
  }

  void _openDetailsPage() {
    navigationService.navigateTo(DetailsPageRoute,
        arguments: DetailsPageArguments(
          type: 'Lodging',
          lodging: lodging,
          trip: trip,
        ));
  }

  Widget _buildlodgingMenuButton() {
    return LodgingMenuButton(lodging: lodging, trip: trip);
  }

  Widget _buildViewAnyLink() {
    return ViewAnyLink(
      hash: lodging.hashCode,
      link: lodging.link,
      multiMediaonly: true,
      function: () => <Map<dynamic, dynamic>>{},
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          lodging.lodgingType,
          style:
              SizeConfig.tablet ? headlineLarge(context) : titleMedium(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (lodging.startTime.isNotEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Check-in: ${lodging.startTime}',
                style: labelLarge(context),
              ),
              Text(
                'Checkout: ${lodging.endTime}',
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
            itemDocID: lodging.fieldID,
            tripDocID: trip.documentId,
            users: trip.accessUsers,
            itemName: lodging.lodgingType,
            itemDescription: lodging.comment,
            itemType: 'Lodging',
            dateCreated: DateTime.now(),
            details: '',
            userSelectedList: <String>[],
            amountRemaining: 0,
            itemTotal: 0,
            lastUpdated: DateTime.now(),
            purchasedByUID: ''),
        trip: trip);
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return IconButton(
      visualDensity: const VisualDensity(vertical: -4),
      icon: FavoriteWidget(
        uid: userService.currentUserID,
        voters: lodging.voters,
      ),
      onPressed: () {
        final String fieldID = lodging.fieldID;
        if (!lodging.voters.contains(userService.currentUserID)) {
          updateLodgingVote(trip.documentId, fieldID, true);
        } else {
          updateLodgingVote(trip.documentId, fieldID, false);
        }
      },
    );
  }
}
