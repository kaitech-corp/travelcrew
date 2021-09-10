import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class CurrentTripRepository {
  final Query tripCollection = FirebaseFirestore.instance
      .collection("trips")
      .orderBy('endDateTimeStamp')
      .where('ispublic', isEqualTo: true);

  final _loadedDataCurrentTrips = StreamController<List<Trip>>.broadcast();

  void dispose() {
    _loadedDataCurrentTrips.close();
  }

  void refresh() {
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

    Stream<List<Trip>> currentCrewTrips = tripCollection
        .where('accessUsers', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_currentCrewTripListFromSnapshot);
    if(!_loadedDataCurrentTrips.isClosed){
      _loadedDataCurrentTrips.addStream(currentCrewTrips);
    }

  }

  Stream<List<Trip>> trips() => _loadedDataCurrentTrips.stream;
}
