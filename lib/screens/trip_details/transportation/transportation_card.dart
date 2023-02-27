import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/custom_objects.dart';
import '../../../models/split_model.dart';
import '../../../models/transportation_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/locator.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/global_card.dart';
import '../../../size_config/size_config.dart';
import '../split/split_package.dart';

///Transportation card to display details
class TransportationCard extends StatelessWidget {
  TransportationCard({Key? key, required this.transportationData, required this.trip}) : super(key: key);
  final UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();
  final TransportationData transportationData;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return GlobalCard(
      widget: InkWell(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                visualDensity: const VisualDensity(vertical: -4),
                title: Text(
                  transportationData.mode,
                  style: SizeConfig.tablet
                      ? headlineLarge(context)
                      : headlineSmall(context),
                ),
                subtitle: Text(
                  transportationData.displayName,
                  style: titleMedium(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: menuButton(context),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (transportationData.mode == 'Flying')
                      Tooltip(
                          message: 'Airline and Flight Number',
                          child: Text(
                            '${transportationData.airline}: ${transportationData.flightNumber}',
                            style: titleMedium(context),
                          )),
                    if (transportationData.canCarpool)
                      Text(
                        'Open to Carpool',
                        style: titleSmall(context),
                      ),
                    if (transportationData.comment.isNotEmpty)
                      Text(
                        transportationData.comment,
                        style: titleMedium(context),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuButton(BuildContext context) {
    return transportationData.uid == currentUserProfile.uid
        ? PopupMenuButton<String>(
            icon: const IconThemeWidget(
              icon: Icons.more_horiz,
            ),
            onSelected: (String value) {
              switch (value) {
                case 'Edit':
                  {
                    navigationService.navigateTo(EditTransportationRoute,
                        arguments: transportationData);
                  }
                  break;
                case 'Split':
                  {
                    SplitPackage().splitItemAlert(
                        context,
                        SplitObject(
                            itemDocID: transportationData.fieldID,
                            tripDocID: trip.documentId,
                            users: trip.accessUsers,
                            itemName: transportationData.mode,
                            itemDescription: 'Transportation',
                            details: transportationData.comment,
                            itemType: 'Transportation', dateCreated: Timestamp.now(), userSelectedList: <String>[], amountRemaining: 0, itemTotal: 0, lastUpdated: Timestamp.now(), purchasedByUID: '',),
                        trip: trip);
                  }
                  break;
                default:
                  {
                    CloudFunction().deleteTransportation(
                        tripDocID: transportationData.tripDocID,
                        fieldID: transportationData.fieldID);
                  }
                  break;
              }
            },
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: 'Edit',
                child: ListTile(
                  leading: IconThemeWidget(icon: Icons.edit),
                  title: Text('Edit'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Split',
                child: ListTile(
                  leading: IconThemeWidget(icon: Icons.attach_money),
                  title: Text('Split'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'Delete',
                child: ListTile(
                  leading: IconThemeWidget(icon: Icons.delete),
                  title: Text('Delete'),
                ),
              ),
            ],
          )
        : PopupMenuButton<String>(
            icon: const IconThemeWidget(
              icon: Icons.more_horiz,
            ),
            onSelected: (String value) {
              switch (value) {
                case 'report':
                  {
                    // TravelCrewAlertDialogs().reportAlert(t)
                  }
                  break;
                default:
                  {}
                  break;
              }
            },
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: 'report',
                child: ListTile(
                  leading: IconThemeWidget(icon: Icons.report),
                  title: Text('Report'),
                ),
              ),
            ],
          );
  }
}
