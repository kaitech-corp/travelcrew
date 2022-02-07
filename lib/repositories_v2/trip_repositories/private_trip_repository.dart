import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

class PrivateTripRepository {

  Stream<List<Trip>> privateTripDataStream() {

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
