import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../blocs/generics/generic_bloc.dart';
import '../../models/trip_model/trip_model.dart';

class PrivateTripRepository extends GenericBlocRepository<Trip> {

  @override
  Stream<List<Trip>> data() {

    final Query<Object> privateTripCollection = FirebaseFirestore.instance
        .collection('privateTrips')
        .orderBy('endDateTimeStamp');

    List<Trip> privateTripListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        return snapshot.docs
            .map((QueryDocumentSnapshot<Object> doc) {
          return Trip.fromJson(doc.data() as Map<String, dynamic>);
        })
            .toList()
            .reversed
            .toList();
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving private trip list:  $e');
        return <Trip>[];
      }
    }

    return privateTripCollection
        .where('accessUsers', arrayContainsAny: <String>[userService.currentUserID])
        .snapshots()
        .map(privateTripListFromSnapshot);
  }
}
