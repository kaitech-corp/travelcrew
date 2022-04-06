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
  final Trip tripDetails;

  SplitPage({this.tripDetails,});

  @override
  _SplitPageState createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {

  @override
  Widget build(BuildContext context) {
    return SplitBlocBuilder(
      trip: widget.tripDetails,
    );
  }

  Widget costDetailsStream(SplitObject splitObject, String purchasedByUID) {
    return SingleChildScrollView(
      child: SizedBox(
        height: SizeConfig.screenHeight * .4,
        width: SizeConfig.screenWidth,
        child: StreamBuilder2(
          streams: Tuple2(
            DatabaseService(
                    itemDocID: splitObject.itemDocID,
                    tripDocID: splitObject.tripDocID)
                .costDataList,
            DatabaseService().getcrewList(widget.tripDetails.accessUsers),
          ),
          builder: (context, snapshots) {
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

              ///Update remaining balance by checking if each outstanding balance adds up correctly
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
                            builder: (context) =>
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
                            color: Colors.grey[100],
                          ))),
                          padding: const EdgeInsets.all(3),
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
                            title: Text(userPublicProfile.displayName,
                                style: Theme.of(context).textTheme.subtitle1),
                            subtitle: (costObject.paid == false)
                                ? Text('Owe: \$${costObject.amountOwe
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
                                              costObject.datePaid,
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
