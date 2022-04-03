import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../blocs/generics/generic_bloc.dart';

class PrivateTripRepository extends GenericBlocRepository<Trip> {

  Stream<List<Trip>> data() {

    final Query privateTripCollection = FirebaseFirestore.instance
        .collection("privateTrips")
        .orderBy('endDateTimeStamp');

    List<Trip> _privateTripListFromSnapshot(QuerySnapshot snapshot) {
      try {
        return snapshot.docs
            .map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        })
            .toList()
            .reversed
            .toList();
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving private trip list:  ${e.toString()}');
        return null;
      }
    }

    return privateTripCollection
        .where('accessUsers', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_privateTripListFromSnapshot);
  }
}