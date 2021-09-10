import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class PrivateTripRepository {
  final Query privateTripCollection = FirebaseFirestore.instance
      .collection("privateTrips")
      .orderBy('endDateTimeStamp');

  final _loadedDataPrivateTrips = StreamController<List<Trip>>.broadcast();

  void dispose() {
    _loadedDataPrivateTrips.close();
  }

  void refresh() {
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

    Stream<List<Trip>> privateTrips = privateTripCollection
        .where('accessUsers', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_privateTripListFromSnapshot);
    _loadedDataPrivateTrips.addStream(privateTrips);
  }

  Stream<List<Trip>> trips() => _loadedDataPrivateTrips.stream;
}
