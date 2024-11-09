import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/cost_model/cost_object_model.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../models/split_model/split_model.dart';

import '../../../services/functions/cloud_functions/admin_functions.dart';
import '../../Profile/logic/logic.dart';
import '../split_package.dart';

final CollectionReference<Object?> splitItemCollection =
    FirebaseFirestore.instance.collection('splitItem');
final CollectionReference<Object?> costDetailsCollection =
    FirebaseFirestore.instance.collection('costDetails');

class UserPurchase {
  UserPurchase({required this.total, this.userId});

  String? userId;
  double total;
}

double getTotalCost(List<SplitObject> items) {
  return items.fold(
      0.0, (double total, SplitObject item) => total + item.itemTotal);
}

List<String> getUserIds(List<SplitObject> items) {
  final List<String> uids = <String>[];
  return items
      .where((SplitObject item) => !uids.contains(item.purchasedByUID))
      .map((SplitObject item) => item.purchasedByUID)
      .toList();
}

Stream<List<UserPublicProfile>> fetchCrewList(List<String> accessUsers) async* {
  try {
    final List<UserPublicProfile> users = await usersList();
    yield users
        .where((UserPublicProfile user) => accessUsers.contains(user.uid))
        .toList();
  } catch (e) {
    AdminCloudFunction()
        .logError('Error in getcrewList for members layout: $e');
  }
}

void removeSplitObject(SplitObject splitObject) {
  final DocumentReference<Map<String, dynamic>> ref2 = splitItemCollection
      .doc(splitObject.tripDocID)
      .collection('Item')
      .doc(splitObject.itemDocID);
  try {
    for (final String element in splitObject.userSelectedList) {
      costDetailsCollection
          .doc(splitObject.itemDocID)
          .collection('Users')
          .doc(element)
          .delete();
    }
    ref2.delete();
  } catch (e) {
    AdminCloudFunction().logError('Error deleting split object: $e');
  }
}

class SplitService {
  SplitService({this.tripDocID, this.itemDocID, this.itemDocIDs});

  final String? tripDocID;
  final String? itemDocID;
  final List<String>? itemDocIDs;

  Future<bool> doesSplitItemExist() async {
    if (itemDocID != null) {
      final DocumentSnapshot<Map<String, dynamic>> ref =
          await splitItemCollection
              .doc(tripDocID)
              .collection('Item')
              .doc(itemDocID)
              .get();
      return ref.exists;
    }
    return false;
  }

  List<SplitObject> splitItemDataFromSnapshot(QuerySnapshot<Object?> snapshot) {
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return SplitObject.fromJson(doc as Map<String, Object>);
      }).toList();
    } catch (e) {
      AdminCloudFunction().logError('Error retrieving split list:  $e');
      return <SplitObject>[];
    }
  }

  Stream<List<SplitObject>> get splitItemData {
    return splitItemCollection
        .doc(tripDocID)
        .collection('Item')
        .snapshots()
        .map(splitItemDataFromSnapshot);
  }

  List<CostObjectModel> costObjectDataFromSnapshot(
      QuerySnapshot<Object?> snapshot) {
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return CostObjectModel.fromJson(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      AdminCloudFunction().logError('Error in streaming cost details: $e');
      return <CostObjectModel>[];
    }
  }

  Stream<List<CostObjectModel>> get costDataList {
    return costDetailsCollection
        .doc(itemDocID)
        .collection('Users')
        .snapshots()
        .map(costObjectDataFromSnapshot);
  }

  Stream<List<CostObjectModel>> get costDataCompleteList {
    print('ItemDocIDs: $itemDocIDs');
    return Stream<String>.fromIterable(itemDocIDs!).asyncMap((String docID) {
      return costDetailsCollection
          .doc(docID)
          .collection('Users')
          .snapshots()
          .map(costObjectDataFromSnapshot);
    }).asyncExpand((Stream<List<CostObjectModel>> stream) => stream);
  }
}

Future<void> createSplitItemCostDetailsPerUser(
    SplitObject splitObject, String userUID) async {
  final bool paid = userUID == splitObject.purchasedByUID;
  final CostObjectModel costObject = CostObjectModel(
    tripDocID: splitObject.tripDocID,
    itemDocID: splitObject.itemDocID,
    lastUpdated: DateTime.now(),
    paid: paid,
    uid: userUID,
    amountOwe: SplitPackage().standardSplit(
        splitObject.userSelectedList.length, splitObject.itemTotal),
  );

  final DocumentReference<Map<String, dynamic>> ref = costDetailsCollection
      .doc(costObject.itemDocID)
      .collection('Users')
      .doc(costObject.uid);

  try {
    return ref.set(costObject.toJson());
  } catch (e) {
    AdminCloudFunction().logError('Error creating split item cost details: $e');
  }
}

void markAsPaid(CostObjectModel costObject, SplitObject splitObject) {
  final DocumentReference<Map<String, dynamic>> ref = costDetailsCollection
      .doc(costObject.itemDocID)
      .collection('Users')
      .doc(costObject.uid);
  final DocumentReference<Map<String, dynamic>> ref2 = splitItemCollection
      .doc(splitObject.tripDocID)
      .collection('Item')
      .doc(splitObject.itemDocID);

  try {
    ref.update(<String, dynamic>{
      'paid': costObject.paid,
      'datePaid': FieldValue.serverTimestamp(),
    });
    ref2.update(<String, dynamic>{
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    AdminCloudFunction().logError('Error marking cost data as paid: $e');
  }
}

void updateRemainingBalance(
    SplitObject splitObject, double amountRemaining, List<String> uidList) {
  final DocumentReference<Map<String, dynamic>> ref = splitItemCollection
      .doc(splitObject.tripDocID)
      .collection('Item')
      .doc(splitObject.itemDocID);
  try {
    ref.update(<String, dynamic>{
      'amountRemaining': amountRemaining,
      'lastUpdated': FieldValue.serverTimestamp(),
      'userSelectedList': uidList,
    });
  } catch (e) {
    AdminCloudFunction().logError('Error updating remaining balance: $e');
  }
}

void removeCostObjectModel(
    CostObjectModel costObject, SplitObject splitObject) {
  final DocumentReference<Map<String, dynamic>> ref = costDetailsCollection
      .doc(costObject.itemDocID)
      .collection('Users')
      .doc(costObject.uid);
  final DocumentReference<Map<String, dynamic>> ref2 = splitItemCollection
      .doc(splitObject.tripDocID)
      .collection('Item')
      .doc(splitObject.itemDocID);
  try {
    splitObject.userSelectedList.remove(costObject.uid);
    ref.delete();
    ref2.update(<String, dynamic>{
      'userSelectedList': FieldValue.arrayRemove(<String?>[costObject.uid])
    });
    createSplitItem(splitObject);
  } catch (e) {
    AdminCloudFunction().logError('Error removing cost object model: $e');
  }
}

Future<void> createSplitItem(SplitObject splitObject) async {
  final DocumentReference<Map<String, dynamic>> ref = splitItemCollection
      .doc(splitObject.tripDocID)
      .collection('Item')
      .doc(splitObject.itemDocID);
  final DocumentSnapshot<Map<String, dynamic>> ref2 = await ref.get();
  try {
    for (final String element in splitObject.userSelectedList) {
      createSplitItemCostDetailsPerUser(splitObject, element);
    }
    if (!ref2.exists) {
      return await ref.set(splitObject.toJson());
    } else {
      return await ref.update(splitObject.toJson());
    }
  } catch (e) {
    AdminCloudFunction().logError('Error creating split item: $e');
  }
}

UserPurchase calculateTotalForUser(String uid, List<CostObjectModel> items) {
  double total = 0.0;
  print(items);
  for (final CostObjectModel item in items) {
    if (item.paid || item.uid != uid) {
      continue;
    }
    total += item.amountOwe;
  }

  return UserPurchase(userId: uid, total: total);
}
