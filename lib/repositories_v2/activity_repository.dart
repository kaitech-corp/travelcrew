import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/activity_model.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class ActivityRepository {
  Stream<List<ActivityData>> activityDataStream(String tripDocID) {

    final CollectionReference activitiesCollection =  FirebaseFirestore.instance.collection("activities");

    // Get all Activities
    List<ActivityData> _activitiesListFromSnapshot(QuerySnapshot snapshot){
      try {
        List<ActivityData> activityList = snapshot.docs.map((doc){
          Map<String, dynamic> data = doc.data();
          return ActivityData.fromData(data);
        }).toList();
        // activityList.sort((a,b) => b.voters.length.compareTo(a.voters.length));
        return activityList;
      } catch (e) {
        CloudFunction().logError('Error retrieving activity list:  ${e.toString()}');
        return null;
      }
    }

    return activitiesCollection
        .doc(tripDocID).collection('activity')
        .snapshots().map(_activitiesListFromSnapshot);
  }
}