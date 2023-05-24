import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../models/activity_model/activity_model.dart';
import '../../../services/functions/cloud_functions.dart';


class ActivityRepository extends GenericBlocRepository<ActivityModel> {
  ActivityRepository({required this.tripDocID});

  final String tripDocID;

  @override
  Stream<List<ActivityModel>> data() {
    final CollectionReference<dynamic> activitiesCollection =
        FirebaseFirestore.instance.collection('activities');

    // Get all Activities
    List<ActivityModel> activitiesListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final List<ActivityModel> activityList =
            snapshot.docs.map((QueryDocumentSnapshot<Object> doc) {
          return ActivityModel.fromJson(doc as Map<String,Object>);
        }).toList();
        return activityList;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving activity list:  $e');
        return <ActivityModel>[];
      }
    }

    return activitiesCollection
        .doc(tripDocID)
        .collection('activity')
        .snapshots()
        .map(activitiesListFromSnapshot);
  }
}
