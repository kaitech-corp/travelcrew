import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../models/lodging_model/lodging_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions/admin_functions.dart';

final CollectionReference<Object?> lodgingCollection =
    FirebaseFirestore.instance.collection('lodging');
Future<void> addNewLodging(String documentID, LodgingModel lodging) async {
  final String key = lodgingCollection.doc().id;

  try {
    final String action = 'Add new lodging for $documentID';
    AdminCloudFunction().logEvent(action);
    final DocumentReference<Map<String, dynamic>> addNewLodgingRef =
        lodgingCollection.doc(documentID).collection('lodging').doc(key);
    addNewLodgingRef.set(lodging.toJson());
    addNewLodgingRef.update(<String, dynamic>{
      'fieldID': key,
    });
  } catch (e) {
    AdminCloudFunction().logError('Error adding new lodging data:  $e');
  }
}

void updateLodgingVote(String documentID, String fieldID, bool addVote) {
  final DocumentReference<Map<String, dynamic>> addVoteToLodgingRef =
      lodgingCollection.doc(documentID).collection('lodging').doc(fieldID);
  final String uid = userService.currentUserID;
  final FieldValue fieldValue = addVote
      ? FieldValue.arrayUnion(<String>[uid])
      : FieldValue.arrayRemove(<String>[uid]);
  try {
    addVoteToLodgingRef.update(<String, dynamic>{'voters': fieldValue});
  } catch (e) {
    AdminCloudFunction().logError('Error adding vote to lodging:  $e');
  }
}

//// Edit Lodging
Future<void> editLodging(
    {String? comment,
    required String documentID,
    String? link,
    String? lodgingType,
    required String fieldID,
    String? location,
    DateTime? endDateTimestamp,
    DateTime? startDateTimestamp,
    String? startTime,
    String? endTime}) async {
  final DocumentReference<Map<String, dynamic>> editLodgingRef =
      lodgingCollection.doc(documentID).collection('lodging').doc(fieldID);

  try {
    final String action = 'Editing lodging for $documentID';
    AdminCloudFunction().logEvent(action);
    editLodgingRef.update(<String, dynamic>{
      'comment': comment,
      'link': link,
      'lodgingType': lodgingType,
      'startTime': startTime,
      'endTime': endTime,
      'startDateTimestamp': startDateTimestamp,
      'endDateTimestamp': endDateTimestamp,
      'location': location
    });
  } catch (e) {
    AdminCloudFunction().logError('Error editing lodging:  $e');
  }
}

class StreamLodging {
  StreamLodging({required this.tripDocID, required this.fieldID});

  final String tripDocID;
  final String fieldID;
  ////Get Lodging item
  LodgingModel _lodgingFromSnapshot(DocumentSnapshot<Object?> snapshot) {
    if (snapshot.exists) {
      try {
        return LodgingModel.fromJson(snapshot.data()! as Map<String, dynamic>);
      } catch (e) {
        AdminCloudFunction().logError('Error retrieving lodging list:  $e');
        if (kDebugMode) {
          print('Error Stream lodging items: $e');
        }
        return LodgingModel.mock();
      }
    } else {
      return LodgingModel.mock();
    }
  }

  ////Get specific Lodging
  Stream<LodgingModel>? get lodging {
    try {
      return lodgingCollection
          .doc(tripDocID)
          .collection('lodging')
          .doc(fieldID)
          .snapshots()
          .map(_lodgingFromSnapshot);
    } catch (e) {
      if (kDebugMode) {
        print('Error Stream lodging items: $e');
      }
      return null;
    }
  }
}
