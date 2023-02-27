import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../blocs/generics/generic_bloc.dart';

class PastTripRepository extends GenericBlocRepository<Trip> {

  @override
  Stream<List<Trip>> data() {

    final Query<Object> tripCollection = FirebaseFirestore.instance
        .collection('trips')
        .orderBy('endDateTimeStamp')
        .where('ispublic', isEqualTo: true);


    List<Trip> pastCrewTripListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final DateTime now = DateTime.now().toUtc();
        final DateTime past = DateTime(now.year, now.month, now.day - 1);
        final List<Trip> trips = snapshot.docs.map((QueryDocumentSnapshot<Object> doc) {
          return Trip.fromDocument(doc);
        }).toList();
        final List<Trip> crewTrips = trips
            .where(
                (Trip trip) => trip.endDateTimeStamp.toDate().compareTo(past) == -1)
            .toList()
            .reversed
            .toList();
        return crewTrips;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving past trip list:  $e');
        return <Trip>[];
      }
    }

    return tripCollection
        .where('accessUsers', arrayContainsAny: <String>[userService.currentUserID])
        .snapshots()
        .map(pastCrewTripListFromSnapshot);
  }
}
