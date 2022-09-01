import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../blocs/generics/generic_bloc.dart';


class CurrentTripRepository extends GenericBlocRepository<Trip> {

  @override
  Stream<List<Trip>> data() {

    final Query<Object> tripCollection = FirebaseFirestore.instance
        .collection('trips')
        .orderBy('endDateTimeStamp')
        .where('ispublic', isEqualTo: true);

    List<Trip> _currentCrewTripListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final DateTime now = DateTime.now().toUtc();
        final DateTime past = DateTime(now.year, now.month, now.day - 2);
        final List<Trip> trips = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Trip.fromData(data);
        }).toList();
        final List<Trip> crewTrips = trips
            .where(
                (Trip trip) => trip.endDateTimeStamp!.toDate().compareTo(past) == 1)
            .toList();
        return crewTrips;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving current trip list:  ${e.toString()}');
        return [];
      }
    }

    return tripCollection
        .where('accessUsers', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_currentCrewTripListFromSnapshot);
  }
}
