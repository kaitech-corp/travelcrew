// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:nil/nil.dart';

import '../../../services/database.dart';
import '../../../services/theme/text_styles.dart';
import '../../../size_config/size_config.dart';
import '../../models/cost_model/cost_object_model.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../../models/split_model/split_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/constants/constants.dart';
import '../../services/functions/date_time_retrieval.dart';
import 'details_bottom_sheet.dart';
import 'logic/split_functions.dart';
import 'split_package.dart';

/// Details page for split items
class SplitDetailsPage extends StatelessWidget {
  const SplitDetailsPage(
      {Key? key, required this.splitObject, required this.trip})
      : super(key: key);
  final SplitObject splitObject;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          splitObject.itemName,
          style: headlineSmall(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: StreamBuilder(
          stream: SplitFunctions(itemDocID: splitObject.itemDocID).costDataList,
          builder: (context, snapshot1) {
            return StreamBuilder(
              stream: getcrewList(trip.accessUsers),
              builder: (BuildContext context, snapshot2) {
                if (snapshot1.hasData && snapshot2.hasData) {
                  final List<CostObjectModel> userCostData =
                      snapshot1.data! as List<CostObjectModel>;
                  final List<String> uidList = <String>[];
                  for (final CostObjectModel element in userCostData) {
                    if (!uidList.contains(element.uid)) {
                      uidList.add(element.uid);
                    }
                  }
                  final double amountRemaining =
                      SplitPackage().sumRemainingBalance(userCostData);

                  ///Update remaining balance by checking if each
                  ///outstanding balance adds up correctly
                  if (amountRemaining != splitObject.amountRemaining) {
                    updateRemainingBalance(
                        splitObject, amountRemaining, uidList);
                  }
                  final List<UserPublicProfile> userPublicData =
                      snapshot2.data! as List<UserPublicProfile>;
                  return ListView.builder(
                      itemCount: userCostData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final CostObjectModel costObject = userCostData[index];
                        UserPublicProfile userPublicProfile;
                        userPublicProfile = userPublicData.firstWhere(
                            (UserPublicProfile element) =>
                                element.uid == costObject.uid,
                            orElse: () => UserPublicProfile.mock());

                        final UserPublicProfile purchasedByUser =
                            userPublicData.firstWhere(
                                (UserPublicProfile element) =>
                                    element.uid == splitObject.purchasedByUID,
                                orElse: () => UserPublicProfile.mock());
                        if (userPublicProfile.uid !=
                            splitObject.purchasedByUID) {
                          return InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20))),
                                builder: (BuildContext context) =>
                                    UserSplitCostDetailsBottomSheet(
                                  user: userPublicProfile,
                                  costObject: costObject,
                                  purchasedByUser: purchasedByUser,
                                  splitObject: splitObject,
                                ),
                              );
                            },
                            child: Container(
                              height: SizeConfig.screenHeight * .1,
                              width: SizeConfig.screenWidth,
                              // decoration: BoxDecoration(
                              //     border: Border(
                              //         top: BorderSide(
                              //   color: Colors.grey[100]!,
                              // ))),
                              color: (costObject.paid)
                                  ? Colors.greenAccent
                                  : Colors.white,
                              padding: const EdgeInsets.all(4),
                              child: ListTile(
                                leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                      (userPublicProfile.urlToImage != null &&
                                              userPublicProfile
                                                  .urlToImage!.isNotEmpty)
                                          ? userPublicProfile.urlToImage!
                                          : profileImagePlaceholder,
                                    )),
                                title: Text(userPublicProfile.displayName,
                                    style: titleMedium(context)),
                                subtitle: (costObject.paid == false)
                                    ? Text(
                                        'Owe: \$${costObject.amountOwe.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Cantata One',
                                            color: Colors.red))
                                    : Text(
                                        DateTimeRetrieval().formatDateTime(
                                          costObject.datePaid!,
                                        ),
                                        style: titleSmall(context)),
                                trailing: (splitObject.purchasedByUID ==
                                            userService.currentUserID ||
                                        costObject.uid ==
                                                userService.currentUserID &&
                                            costObject.paid == false)
                                    ? ElevatedButton(
                                        onPressed: () {
                                          markAsPaid(costObject, splitObject);
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
            );
          }),
    );
  }
}
