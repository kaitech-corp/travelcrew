import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';


class CurrentTripRepository {

  Stream<List<Trip>> currentTripDataStream() {

    final Query tripCollection = FirebaseFirestore.instance
        .collection("trips")
        .orderBy('endDateTimeStamp')
        .where('ispublic', isEqualTo: true);

    List<Trip> _currentCrewTripListFromSnapshot(QuerySnapshot snapshot) {
      try {
        final now = DateTime.now().toUtc();
        var past = DateTime(now.year, now.month, now.day - 2);
        List<Trip> trips = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList();
        List<Trip> crewTrips = trips
            .where(
                (trip) => trip.endDateTimeStamp.toDate().compareTo(past) == 1)
            .toList();
        return crewTrips;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving current trip list:  ${e.toString()}');
        return null;
      }
    }

    return tripCollection
        .where('accessUsers', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_currentCrewTripListFromSnapshot);
  }
}
