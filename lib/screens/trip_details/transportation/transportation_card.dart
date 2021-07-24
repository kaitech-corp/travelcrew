import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/split_model.dart';
import 'package:travelcrew/models/transportation_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/split/split_package.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/global_card.dart';
import 'package:travelcrew/size_config/size_config.dart';

class TransportationCard extends StatelessWidget {

  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  final TransportationData transportationData;
  final Trip trip;
  TransportationCard({this.transportationData, this.trip});

  @override
  Widget build(BuildContext context) {
    return GlobalCard(
      widget: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(transportationData.mode,
                    style: SizeConfig.tablet ? Theme.of(context).textTheme.headline4 :
                    Theme.of(context).textTheme.headline6,),
                  menuButton(context),

                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 5.0,)),
              if(transportationData.mode == 'Flying') Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                      message: 'Airline and Flight Number',
                      child: Text('${transportationData.airline}: ${transportationData.flightNumber}',
                        style: Theme.of(context).textTheme.subtitle1,)),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 5)),
              if(transportationData.comment.isNotEmpty) Text(transportationData.comment,style: Theme.of(context).textTheme.subtitle1,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (transportationData.canCarpool) ?
                  Text('Open to Carpool',
                    style: Theme.of(context).textTheme.headline6,) :
                  Text(''),
                  Text(transportationData.displayName,
                    style: ReusableThemeColor().greenOrBlueTextColor(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,),
                ],
              ),
              if(ThemeProvider.themeOf(context).id != 'light_theme') Container(height: 1,color: Colors.grey,)
            ],
          ),
        ),
      ),
    );
  }
  Widget menuButton(BuildContext context){
    return transportationData.uid == currentUserProfile?.uid ?? '' ? PopupMenuButton<String>(
      icon: IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (value){
        switch (value){
          case "Edit": {
            navigationService.navigateTo(EditTransportationRoute, arguments: transportationData);
          }
          break;
          case "Split": {
            SplitPackage().splitItemAlert(context,
                SplitObject(
                    itemDocID:transportationData.fieldID,
                    tripDocID: trip.documentId,
                    users: trip.accessUsers,
                    itemName: transportationData.mode,
                    itemDescription: 'Transportation',
                    details: transportationData.comment,
                    itemType: "Transportation"
                ),
                trip: trip);
          }
          break;
          default: {
            CloudFunction().deleteTransportation(tripDocID: transportationData.tripDocID,fieldID: transportationData.fieldID);

          }
          break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>[
        const PopupMenuItem(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.edit),
            title: const Text('Edit'),
          ),
        ),
        const PopupMenuItem(
          value: 'Split',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.attach_money),
            title: const Text('Split'),
          ),
        ),
        const PopupMenuItem(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon:Icons.delete),
            title: const Text('Delete'),
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
      ],
    );
  }
}
