// // ignore_for_file: always_specify_types

// import 'package:flutter/material.dart';
// import 'package:multiple_stream_builder/multiple_stream_builder.dart';
// import 'package:nil/nil.dart';

// import '../../../services/database.dart';
// import '../../../services/functions/tc_functions.dart';
// import '../../../services/theme/text_styles.dart';
// import '../../../size_config/size_config.dart';
// import '../../models/public_profile_model/public_profile_model.dart';
// import '../../models/split_model/split_model.dart';
// import '../../models/trip_model/trip_model.dart';
// import 'details_bottom_sheet.dart';
// import 'split_package.dart';

// /// Details page for split items
// class SplitDetailsPage extends StatelessWidget {
//   const SplitDetailsPage(
//       {Key? key,
//       required this.splitObject,
//       required this.trip})
//       : super(key: key);
//   final SplitObject splitObject;
//   final Trip trip;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           splitObject.itemName,
//           style: headlineMedium(context),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//       body: StreamBuilder2(
//         streams: StreamTuple2(
//           costDataList,
//          getcrewList(trip.accessUsers),
//         ),
//         builder: (BuildContext context,
//             SnapshotTuple2<List<CostObject>, List<UserPublicProfile>>
//                 snapshots) {
//           if (snapshots.snapshot1.hasData && snapshots.snapshot2.hasData) {
//             final List<CostObject> userCostData = snapshots.snapshot1.data!;
//             final List<String> uidList = <String>[];
//             for (final CostObject element in userCostData) {
//               if (!uidList.contains(element.uid)) {
//                 uidList.add(element.uid);
//               }
//             }
//             final double amountRemaining =
//                 SplitPackage().sumRemainingBalance(userCostData);

//             ///Update remaining balance by checking if each
//             ///outstanding balance adds up correctly
//             if (amountRemaining != splitObject.amountRemaining) {
//               DatabaseService().updateRemainingBalance(
//                   splitObject, amountRemaining, uidList);
//             }
//             final List<UserPublicProfile> userPublicData =
//                 snapshots.snapshot2.data!;
//             return ListView.builder(
//                 itemCount: userCostData.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   final CostObject costObject = userCostData[index];
//                   UserPublicProfile userPublicProfile = defaultProfile;
//                   userPublicProfile = userPublicData.firstWhere(
//                       (UserPublicProfile element) =>
//                           element.uid == costObject.uid,
//                       orElse: () => defaultProfile);

//                   final UserPublicProfile purchasedByUser =
//                       userPublicData.firstWhere(
//                           (UserPublicProfile element) =>
//                               element.uid == splitObject.purchasedByUID,
//                           orElse: () => defaultProfile);
//                   if (userPublicProfile.uid != splitObject.purchasedByUID) {
//                     return InkWell(
//                       onTap: () {
//                         showModalBottomSheet(
//                           context: context,
//                           shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(20),
//                                   topRight: Radius.circular(20))),
//                           builder: (BuildContext context) =>
//                               UserSplitCostDetailsBottomSheet(
//                             user: userPublicProfile,
//                             costObject: costObject,
//                             purchasedByUser: purchasedByUser,
//                             splitObject: splitObject,
//                           ),
//                         );
//                       },
//                       child: Container(
//                         height: SizeConfig.screenHeight * .1,
//                         width: SizeConfig.screenWidth,
//                         // decoration: BoxDecoration(
//                         //     border: Border(
//                         //         top: BorderSide(
//                         //   color: Colors.grey[100]!,
//                         // ))),
//                         color: (costObject.paid)
//                             ? Colors.greenAccent
//                             : Colors.white,
//                         padding: const EdgeInsets.all(4),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             radius: 25,
//                             backgroundImage:
//                                 NetworkImage(userPublicProfile.urlToImage),
//                           ),
//                           title: Text(userPublicProfile.displayName,
//                               style: titleMedium(context)),
//                           subtitle: (costObject.paid == false)
//                               ? Text(
//                                   'Owe: \$${costObject.amountOwe.toStringAsFixed(2)}',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontFamily: 'Cantata One',
//                                       color: Colors.red))
//                               : Text(
//                                   TCFunctions().formatTimestamp(
//                                       costObject.datePaid!,
//                                       wTime: true),
//                                   style: titleSmall(context)),
//                           trailing: (splitObject.purchasedByUID ==
//                                       userService.currentUserID ||
//                                   costObject.uid == userService.currentUserID &&
//                                       costObject.paid == false)
//                               ? ElevatedButton(
//                                   onPressed: () {
//                                     DatabaseService()
//                                         .markAsPaid(costObject, splitObject);
//                                   },
//                                   child: const Text('Paid'),
//                                 )
//                               : nil,
//                         ),
//                       ),
//                     );
//                   } else {
//                     return nil;
//                   }
//                 });
//           } else {
//             return const Text('Empty');
//           }
//         },
//       ),
//     );
//   }
// }
