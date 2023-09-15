import 'package:flutter/material.dart';

import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/navigation/route_names.dart';
import '../../../../services/navigation/router.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/favorite_widget.dart';
import '../../../../services/widgets/link_previewer.dart';
import '../../../../size_config/size_config.dart';
import '../../../models/lodging_model/lodging_model.dart';
import '../../../models/split_model/split_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../Split/split_package.dart';
import 'lodging_menu_button.dart';

class LodgingCard extends StatelessWidget {

  const LodgingCard({super.key, required this.lodging, required this.trip});
  final LodgingModel lodging;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: _openDetailsPage,
      child: Container(
        margin: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            
            if (lodging.link.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ViewAnyLink(
                  link: lodging.link,
                  function: () => {},
                ),
              ),
            ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              title: Text(
                lodging.lodgingType,
                style: SizeConfig.tablet
                    ? headlineLarge(context)
                    : headlineSmall(context),
              ),
              subtitle: (lodging.startTime.isNotEmpty)
                  ? Text(
                      'Check in: ${lodging.startTime}',
                      style: titleSmall(context),
                    )
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SplitPackage().splitItemExist(
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
                    trip: trip),
                IconButton(
                    visualDensity: const VisualDensity(vertical: -4),
                    icon: FavoriteWidget(
                      uid: userService.currentUserID,
                      voters: lodging.voters,
                    ),
                    onPressed: _toggleFavorite),
                    LodgingMenuButton(
              trip: trip,
              lodging: lodging,
            ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetailsPage() {
    navigationService.navigateTo(
      DetailsPageRoute,
      arguments: DetailsPageArguments(
        type: 'Lodging',
        lodging: lodging,
        trip: trip,
      ),
    );
  }

  void _toggleFavorite() {
    final String fieldID = lodging.fieldID;
    final String uid = userService.currentUserID;
    if (!lodging.voters.contains(userService.currentUserID)) {
      CloudFunction().addVoterToLodging(trip.documentId, fieldID, uid);
    } else {
      CloudFunction().removeVoterFromLodging(trip.documentId, fieldID, uid);
    }
  }
}
