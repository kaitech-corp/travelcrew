import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/activity_model/activity_model.dart';
import '../../../services/functions/cloud_functions.dart';

final CollectionReference<Object?> activitiesCollection =
    FirebaseFirestore.instance.collection('activities');

//// Add new activity
Future<void> addNewActivity(
    ActivityModel model, String documentID) async {
  final String key = activitiesCollection.doc().id;

  final DocumentReference<Map<String, dynamic>> addNewActivityRef =
      activitiesCollection.doc(documentID).collection('activity').doc(key);

  try {
    final String action = 'Add new activity for $documentID';
    CloudFunction().logEvent(action);
    addNewActivityRef.set(model.toJson());
    addNewActivityRef.update(<String, dynamic>{
      'fieldID': key,
      'dateTimestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    CloudFunction().logError('Error adding new activity:  $e');
  }
}

//// Edit activity
Future<void> editActivityModel(
    {String? comment,
    required String displayName,
    required String documentID,
    String? link,
    String? activityType,
    required String fieldID,
    String? location,
    DateTime? dateTimestamp,
    DateTime? endDateTimestamp,
    DateTime? startDateTimestamp,
    String? startTime,
    String? endTime}) async {
  final DocumentReference<Map<String, dynamic>> addNewActivityRef =
      activitiesCollection.doc(documentID).collection('activity').doc(fieldID);

  try {
    final String action = 'Editing activity for $documentID';
    CloudFunction().logEvent(action);
    addNewActivityRef.update(<String, dynamic>{
      'comment': comment,
      'displayName': displayName,
      'link': link,
      'activityType': activityType,
      'urlToImage': '',
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'endDateTimestamp': endDateTimestamp,
      'startDateTimestamp': startDateTimestamp,
    });
  } catch (e) {
    CloudFunction().logError('Error editing activity:  $e');
  }
}

///Get Activity item
ActivityModel _activityFromSnapshot(DocumentSnapshot<Object?> snapshot) {
  if (snapshot.exists) {
    try {
      return ActivityModel.fromJson(snapshot.data()! as Map<String, dynamic>);
    } catch (e) {
      CloudFunction().logError('Error retrieving single activity:  $e');
      return ActivityModel.mock();
    }
  } else {
    return ActivityModel.mock();
  }
}

Stream<ActivityModel> getActivity(String tripDocID, String fieldID) {
  return activitiesCollection
      .doc(tripDocID)
      .collection('activity')
      .doc(fieldID)
      .snapshots()
      .map((DocumentSnapshot<Map<String, dynamic>> snapshot) => _activityFromSnapshot(snapshot));
}
