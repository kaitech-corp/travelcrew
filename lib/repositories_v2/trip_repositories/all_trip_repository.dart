import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

class AllTripsRepository {

  Stream<List<Trip>> allTripsDataStream() {
    //Firebase Collection
    final Query tripCollection = FirebaseFirestore.instance
        .collection("trips")
        .orderBy('endDateTimeStamp')
        .where('ispublic', isEqualTo: true);

    // Get all trips
    List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {
      try {
        List<Trip> trips = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList();
        // trips.where((trip) => {
        //   trip.
        // })
        trips.sort(
            (a, b) => a.startDateTimeStamp.compareTo(b.startDateTimeStamp));
        trips = trips
            .where(
                (trip) => !trip.accessUsers.contains(userService.currentUserID))
            .toList()
            .where((trip) =>
                trip.endDateTimeStamp.toDate().isAfter(DateTime.now()))
            .toList();
        return trips;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving all trip list:  ${e.toString()}');
        return null;
      }
    }

    // get trips stream
    return tripCollection
        .snapshots()
        .map(_tripListFromSnapshot);
  }
}
