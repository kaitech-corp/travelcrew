import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/cost_model/cost_object_model.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../models/split_model/split_model.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../Profile/logic/logic.dart';

final CollectionReference<Object?> splitItemCollection =
    FirebaseFirestore.instance.collection('splitItem');
final CollectionReference<Object?> costDetailsCollection =
    FirebaseFirestore.instance.collection('costDetails');

double calculateTotal(List<SplitObject> items) {
  double total = 0.00;

  for (final SplitObject item in items) {
    total += item.itemTotal;
  }

  return total;
}

List<String> listOfUserID(List<SplitObject> items) {
  final List<String> uids = <String>[];
  if (items.isNotEmpty) {
    for (final SplitObject item in items) {
      if (!uids.contains(item.purchasedByUID)) {
        uids.add(item.purchasedByUID);
      }
    }
  }
  return uids;
}

Stream<List<UserPublicProfile>> getcrewList(List<String> accessUsers) async* {
  try {
    final List<UserPublicProfile> users = await usersList();
    yield users
        .where((UserPublicProfile user) => accessUsers.contains(user.uid))
        .toList();
  } catch (e) {
    CloudFunction().logError('Error in getcrewList for members layout: $e');
  }
}

//// delete SplitObject
void deleteSplitObject(SplitObject splitObject) {
  final DocumentReference<Map<String, dynamic>> ref2 = splitItemCollection
      .doc(splitObject.tripDocID)
      .collection('Item')
      .doc(splitObject.itemDocID);
  try {
    try {
      for (final String element in splitObject.userSelectedList) {
        costDetailsCollection
            .doc(splitObject.itemDocID)
            .collection('Users')
            .doc(element)
            .delete();
      }
    } catch (e) {
      CloudFunction().logError('Error deleting user cost details documents: '
          '$e');
    }
    ref2.delete();
  } catch (e) {
    CloudFunction().logError('Error marking cost data as paid: $e');
  }
}

class SplitFunctions {
  SplitFunctions({this.tripDocID, this.itemDocID});

  final String? tripDocID;
  final String? itemDocID;
  //// Check Split Item exists
  Future<bool> checkSplitItemExist(String itemDocID) async {
    final DocumentSnapshot<Map<String, dynamic>> ref = await splitItemCollection
        .doc(tripDocID)
        .collection('Item')
        .doc(itemDocID)
        .get();
    if (ref.exists) {
      return true;
    } else {
      return false;
    }
  }

//// Stream in split item
  List<SplitObject> _splitItemDataFromSnapshot(
      QuerySnapshot<Object?> snapshot) {
    try {
      final List<SplitObject> splitItemData =
          snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return SplitObject.fromJson(doc as Map<String, Object>);
      }).toList();

      return splitItemData;
    } catch (e) {
      CloudFunction().logError('Error retrieving split list:  $e');
      return <SplitObject>[];
    }
  }

//// Stream in split item
  Stream<List<SplitObject>> get splitItemData {
    return splitItemCollection
        .doc(tripDocID)
        .collection('Item')
        .snapshots()
        .map(_splitItemDataFromSnapshot);
  }

  //// Stream in Cost Details
  List<CostObjectModel> _costObjectDataFromSnapshot(
      QuerySnapshot<Object?> snapshot) {
    try {
      final List<CostObjectModel> costObjectData =
          snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return CostObjectModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return costObjectData;
    } catch (e) {
      CloudFunction().logError('Error in streaming cost details: $e');
      return <CostObjectModel>[];
    }
  }

////Stream cost data
  Stream<List<CostObjectModel>> get costDataList {
    return costDetailsCollection
        .doc(itemDocID)
        .collection('Users')
        .snapshots()
        .map(_costObjectDataFromSnapshot);
  }
}

//// Create split item cost details
Future<void> createSplitItemCostDetailsPerUser(
    SplitObject splitObject, String userUID) async {
  late bool paid;
  if (userUID == splitObject.purchasedByUID) {
    paid = true;
  } else {
    paid = false;
  }
  final CostObjectModel costObject = CostObjectModel(
      tripDocID: splitObject.tripDocID,
      itemDocID: splitObject.itemDocID,
      lastUpdated: DateTime.now(),
      paid: paid,
      uid: userUID,
      amountOwe: 0
      // amountOwe: SplitPackage().standardSplit(
      //     splitObject.userSelectedList.length, splitObject.itemTotal),
      );

  final DocumentReference<Map<String, dynamic>> ref = costDetailsCollection
      .doc(costObject.itemDocID)
      .collection('Users')
      .doc(costObject.uid);

  /// var ref2 = await ref.get();
  /// if(!ref2.exists) {
  try {
    return ref.set(costObject.toJson());
  } catch (e) {
    CloudFunction().logError('Error from create split item function: $e');
  }

  /// }
}

//// Mark as paid
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
    CloudFunction().logError('Error marking cost data as paid: $e');
  }
}

//// Update remaining balance
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
    CloudFunction().logError('Error marking cost data as paid: $e');
  }
}

//// deleteCostObjectModel and recreate the split object with remaining members
void deleteCostObjectModel(
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
    CloudFunction().logError('Error marking cost data as paid: $e');
  }

  /// }
}

///Creates Firestore document files for newly created split item.
Future<void> createSplitItem(SplitObject splitObject) async {
  final DocumentReference<Map<String, dynamic>> ref = splitItemCollection
      .doc(splitObject.tripDocID)
      .collection('Item')
      .doc(splitObject.itemDocID);
  final DocumentSnapshot<Map<String, dynamic>> ref2 = await ref.get();
  if (!ref2.exists) {
    try {
      for (final String element in splitObject.userSelectedList) {
        createSplitItemCostDetailsPerUser(splitObject, element);
      }
      return await ref.set(splitObject.toJson());
    } catch (e) {
      CloudFunction().logError('Error from create split item function: $e');
    }
  } else {
    try {
      for (final String element in splitObject.userSelectedList) {
        createSplitItemCostDetailsPerUser(splitObject, element);
      }
      return await ref.update(splitObject.toJson());
    } catch (e) {
      CloudFunction().logError('Error from create split item function: $e');
    }
  }
}