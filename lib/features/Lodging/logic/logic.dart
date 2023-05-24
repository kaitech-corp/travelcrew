

  import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/lodging_model/lodging_model.dart';
import '../../../services/functions/cloud_functions.dart';

final CollectionReference<Object?> lodgingCollection =
      FirebaseFirestore.instance.collection('lodging');
            const String tripDocID = '';
      const String fieldID = '';
  //// Add new lodging
  Future<void> addNewLodging(String documentID, LodgingModel lodging) async {
    final String key = lodgingCollection.doc().id;

    try {
      final String action = 'Add new lodging for $documentID';
      CloudFunction().logEvent(action);
      final DocumentReference<Map<String, dynamic>> addNewLodgingRef =
          lodgingCollection.doc(documentID).collection('lodging').doc(key);
      addNewLodgingRef.set(lodging.toJson());
      addNewLodgingRef.update(<String, dynamic>{
        'fieldID': key,
      });
    } catch (e) {
      CloudFunction().logError('Error adding new lodging data:  $e');
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
      CloudFunction().logEvent(action);
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
      CloudFunction().logError('Error editing lodging:  $e');
    }
  }



  ////Get Lodging item
  LodgingModel _lodgingFromSnapshot(DocumentSnapshot<Object?> snapshot) {
    if (snapshot.exists) {
      try {
        return LodgingModel.fromJson(snapshot as Map<String, Object>);
      } catch (e) {
        CloudFunction().logError('Error retrieving lodging list:  $e');
        return LodgingModel.mock();
      }
    } else {
      return LodgingModel.mock();
    }
  }

  ////Get specific Lodging
  Stream<LodgingModel> get lodging {
    return lodgingCollection
        .doc(tripDocID)
        .collection('lodging')
        .doc(fieldID)
        .snapshots()
        .map(_lodgingFromSnapshot);
  }
