import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class AllTripRepository {
  final Query tripCollection = FirebaseFirestore.instance
      .collection("trips")
      .orderBy('endDateTimeStamp')
      .where('ispublic', isEqualTo: true);

  final _loadedDataAllTrips = StreamController<List<Trip>>.broadcast();

  void dispose() {
    _loadedDataAllTrips.close();
  }

  void refresh() {
    // Get all trips
    List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {
      try {
        List<Trip> trips = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList();
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
    Stream<List<Trip>> allTrips =
        tripCollection.snapshots().map(_tripListFromSnapshot);
    _loadedDataAllTrips.addStream(allTrips);
  }

  Stream<List<Trip>> trips() => _loadedDataAllTrips.stream;
}
