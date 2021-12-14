import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

class FavoriteTripRepository {
  final Query tripCollection = FirebaseFirestore.instance
      .collection("trips")
      .orderBy('endDateTimeStamp')
      .where('ispublic', isEqualTo: true);

  final _loadedDataFavoriteTrips = StreamController<List<Trip>>.broadcast();

  void dispose() {
    _loadedDataFavoriteTrips.close();
  }

  void refresh() {
    List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {
      try {
        List<Trip> trips = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList();
        trips.sort(
            (a, b) => a.startDateTimeStamp.compareTo(b.startDateTimeStamp));

        return trips;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving favorites trip list:  ${e.toString()}');
        return null;
      }
    }

    // get trips stream
    Stream<List<Trip>> favoriteTrips = tripCollection
        .where('favorite', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_tripListFromSnapshot);
    _loadedDataFavoriteTrips.addStream(favoriteTrips);
  }

  Stream<List<Trip>> trips() => _loadedDataFavoriteTrips.stream;
}
