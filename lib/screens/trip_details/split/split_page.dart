import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:nil/nil.dart';

import '../../../models/cost_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/split_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../size_config/size_config.dart';
import 'bloc_builder.dart';
import 'details_bottom_sheet.dart';
import 'split_package.dart';

/// Split Page
class SplitPage extends StatefulWidget {

  const SplitPage({required this.trip,});
  final Trip trip;

  @override
  _SplitPageState createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {

  @override
  Widget build(BuildContext context) {
    return SplitBlocBuilder(
      trip: widget.trip,
    );
  }

  Widget costDetailsStream(SplitObject splitObject, String purchasedByUID) {
    return SingleChildScrollView(
      child: SizedBox(
        height: SizeConfig.screenHeight * .4,
        width: SizeConfig.screenWidth,
        child: StreamBuilder2(
          streams: StreamTuple2(
            DatabaseService(
                    itemDocID: splitObject.itemDocID,
                    tripDocID: splitObject.tripDocID)
                .costDataList,
            DatabaseService().getcrewList(widget.trip.accessUsers!),
          ),
          builder: (BuildContext context, SnapshotTuple2<Object?, Object?> snapshots) {
            if (snapshots.snapshot1.hasData && snapshots.snapshot2.hasData) {
              final List<CostObject> userCostData = snapshots.snapshot1.data as List<CostObject>;
              final List<String> uidList = [];
              for (final CostObject element in userCostData) {
                if (!uidList.contains(element.uid)) {
                  uidList.add(element.uid!);
                }
              }

              final double amountRemaining =
                  SplitPackage().sumRemainingBalance(userCostData);

              ///Update remaining balance by checking if each outstanding balance adds up correctly
              if (amountRemaining != splitObject.amountRemaining) {
                DatabaseService().updateRemainingBalance(
                    splitObject, amountRemaining, uidList);
              }
              final List<UserPublicProfile> userPublicData = snapshots.snapshot2.data as List<UserPublicProfile>;
              return ListView.builder(
                  itemCount: userCostData.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CostObject costObject = userCostData[index];
                    final UserPublicProfile userPublicProfile = userPublicData
                        .firstWhere((UserPublicProfile element) => element.uid == costObject.uid);
                    final UserPublicProfile purchasedByUser = userPublicData
                        .firstWhere((UserPublicProfile element) => element.uid == purchasedByUID);
                    if (userPublicProfile.uid != purchasedByUID) {
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
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                            color: Colors.grey[100]!,
                          ))),
                          padding: const EdgeInsets.all(3),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: FadeInImage.assetNetwork(placeholder: profileImagePlaceholder, image: userPublicProfile.urlToImage!,height: 50,
                                width: 50,
                                fit: BoxFit.fill,)
                            ),
                            title: Text(userPublicProfile.displayName!,
                                style: Theme.of(context).textTheme.subtitle1),
                            subtitle: (costObject.paid == false)
                                ? Text('Owe: \$${costObject.amountOwe!
                                .toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Cantata One',
                                        color: Colors.red))
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Paid',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Cantata One',
                                              color: Colors.green)),
                                      Text(
                                          TCFunctions().formatTimestamp(
                                              costObject.datePaid!,
                                              wTime: true),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2),
                                    ],
                                  ),
                            trailing: (splitObject.purchasedByUID ==
                                        userService.currentUserID ||
                                    costObject.uid ==
                                            userService.currentUserID &&
                                        costObject.paid == false)
                                ? ElevatedButton(
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ))),
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
      ),
    );
  }
}
