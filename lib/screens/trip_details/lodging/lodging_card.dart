import 'package:flutter/material.dart';

import '../../../models/lodging_model.dart';
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
import 'lodging_menu_button.dart';

/// Lodging card
class LodgingCard extends StatelessWidget {

  final LodgingData lodging;
  final Trip trip;

  LodgingCard({required this.lodging, required this.trip});


  @override
  Widget build(BuildContext context) {

    return Center(
        key: Key(lodging.fieldID!),
        child: GlobalCard(
          widget: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: (){
              navigationService.navigateTo(
                  DetailsPageRoute,
                  arguments: DetailsPageArguments(
                      type: 'Lodging',
                      lodging: lodging,
                      trip: trip));
            },
            child: Container(
              margin: const EdgeInsets.only(top: 4.0, left: 16.0,right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListTile(
                    visualDensity: VisualDensity(horizontal: 0,vertical: -4),
                    title: Text('${lodging.lodgingType}',style: SizeConfig.tablet ? Theme.of(context).textTheme.headline4 : Theme.of(context).textTheme.headline6,),
                    subtitle: (lodging.startTime?.isNotEmpty ?? false) ? Text('Check in: ${lodging.startTime}',style: Theme.of(context).textTheme.subtitle2,): null,
                    trailing: LodgingMenuButton(trip: trip,lodging: lodging,),
                  ),
                  if(lodging.link?.isNotEmpty ?? false) Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                    child: ViewAnyLink(link: lodging.link!,function: ()=>{},),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SplitPackage().splitItemExist(context,
                          SplitObject(
                              itemDocID:lodging.fieldID,
                              tripDocID: trip.documentId,
                              users: trip.accessUsers,
                              itemName: lodging.lodgingType,
                              itemDescription: lodging.comment,
                              itemType: "Lodging"
                          ), trip: trip),
                      IconButton(
                          visualDensity: VisualDensity(horizontal: 0,vertical: -4),
                          icon: FavoriteWidget(uid: userService.currentUserID,voters: lodging.voters!,),
                          onPressed: () {
                            String fieldID = lodging.fieldID!;
                            String uid = userService.currentUserID;
                            if (!lodging.voters!.contains(userService.currentUserID)) {
                              CloudFunction().addVoterToLodging(trip.documentId!, fieldID, uid);
                            } else {
                              CloudFunction().removeVoterFromLodging(trip.documentId!, fieldID, uid);
                            }
                          }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
