import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../blocs/generics/generic_bloc.dart';

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
          return Trip.fromDocument(doc);
        })
            .toList()
            .reversed
            .toList();
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving private trip list:  ${e.toString()}');
        return <Trip>[];
      }
    }

    return privateTripCollection
        .where('accessUsers', arrayContainsAny: <String>[userService.currentUserID])
        .snapshots()
        .map(privateTripListFromSnapshot);
  }
}
