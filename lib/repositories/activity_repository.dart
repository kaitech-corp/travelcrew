import 'package:cloud_firestore/cloud_firestore.dart';
import '../blocs/generics/generic_bloc.dart';
import '../models/activity_model.dart';
import '../services/functions/cloud_functions.dart';

class ActivityRepository extends GenericBlocRepository<ActivityData> {
  ActivityRepository({required this.tripDocID});

  final String tripDocID;

  @override
  Stream<List<ActivityData>> data() {
    final CollectionReference<dynamic> activitiesCollection =
        FirebaseFirestore.instance.collection('activities');

    // Get all Activities
    List<ActivityData> activitiesListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final List<ActivityData> activityList =
            snapshot.docs.map((QueryDocumentSnapshot<Object> doc) {
          return ActivityData.fromDocument(doc);
        }).toList();
        return activityList;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving activity list:  $e');
        return <ActivityData>[];
      }
    }

    return activitiesCollection
        .doc(tripDocID)
        .collection('activity')
        .snapshots()
        .map(activitiesListFromSnapshot);
  }
}
