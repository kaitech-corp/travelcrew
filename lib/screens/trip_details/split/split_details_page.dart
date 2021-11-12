import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:nil/nil.dart';
import 'package:travelcrew/models/cost_model.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/split_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/split/split_package.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';

import 'details_bottom_sheet.dart';

class SplitDetailsPage extends StatelessWidget {
  final SplitObject splitObject;
  final String purchasedByUID;
  final Trip tripDetails;

  const SplitDetailsPage(
      {Key key, this.splitObject, this.purchasedByUID, this.tripDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          splitObject.itemName,
          style: Theme.of(context).textTheme.headline5,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: StreamBuilder2(
        streams: Tuple2(
          DatabaseService(
                  itemDocID: splitObject.itemDocID,
                  tripDocID: splitObject.tripDocID)
              .costDataList,
          DatabaseService().getcrewList(tripDetails.accessUsers),
        ),
        builder: (BuildContext context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData) {
            List<CostObject> userCostData = snapshots.item1.data;
            List<String> uidList = [];
            userCostData.forEach((element) {
              if (!uidList.contains(element.uid)) {
                uidList.add(element.uid);
              }
            });
            var amountRemaining =
                SplitPackage().sumRemainingBalance(userCostData);

            ///Update remaining balance by checking if each
            ///outstanding balance adds up correctly
            if (amountRemaining != splitObject.amountRemaining) {
              DatabaseService().updateRemainingBalance(
                  splitObject, amountRemaining, uidList);
            }
            List<UserPublicProfile> userPublicData = snapshots.item2.data;
            return ListView.builder(
                itemCount: userCostData.length,
                itemBuilder: (context, index) {
                  CostObject costObject = userCostData[index];
                  UserPublicProfile userPublicProfile = userPublicData
                      .firstWhere((element) => element.uid == costObject.uid);
                  UserPublicProfile purchasedByUser = userPublicData
                      .firstWhere((element) => element.uid == purchasedByUID);
                  if (userPublicProfile.uid != purchasedByUID) {
                    return InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          builder: (BuildContext context) => UserSplitCostDetailsBottomSheet(
                            user: userPublicProfile,
                            costObject: costObject,
                            purchasedByUser: purchasedByUser,
                            splitObject: splitObject,
                          ),
                        );
                      },
                      child: Container(
                        // height: SizeConfig.screenHeight * .1,
                        // width: SizeConfig.screenWidth,
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                          color: Colors.grey[100],
                        ))),
                        padding: const EdgeInsets.all(4),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: userPublicProfile.urlToImage.isNotEmpty
                                ? Image.network(
                                    userPublicProfile.urlToImage,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.fill,
                                  )
                                : Image.asset(
                                    profileImagePlaceholder,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                          title: Text('${userPublicProfile.displayName}',
                              style: Theme.of(context).textTheme.subtitle1),
                          subtitle: (costObject.paid == false)
                              ? Text(
                                  'Owe: \$${costObject.amountOwe.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Cantata One',
                                      color: Colors.red))
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Paid',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Cantata One',
                                            color: Colors.green)),
                                    Text(
                                        TCFunctions().formatTimestamp(
                                            costObject.datePaid,
                                            wTime: true),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2),
                                  ],
                                ),
                          trailing: (splitObject.purchasedByUID ==
                                      userService.currentUserID ||
                                  costObject.uid == userService.currentUserID &&
                                      costObject.paid == false)
                              ? ElevatedButton(
                                  onPressed: () {
                                    DatabaseService()
                                        .markAsPaid(costObject, splitObject);
                                  },
                                  child: const Text('Paid'),
                                )
                              : nil,
                        ),
                      ),
                    );
                  } else {
                    return nil;
                  }
                });
          } else {
            return const Text('Empty');
          }
        },
      ),
    );
  }
}
