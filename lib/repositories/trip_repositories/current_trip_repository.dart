import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../blocs/generics/generic_bloc.dart';
import '../../models/trip_model/trip_model.dart';

class CurrentTripRepository extends GenericBlocRepository<Trip> {
  @override
  Stream<List<Trip>> data() {
    final Query<Object> tripCollection = FirebaseFirestore.instance
        .collection('trips')
        .orderBy('endDateTimeStamp')
        .where('ispublic', isEqualTo: true);

    List<Trip> currentCrewTripListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final List<Trip> trips =
            snapshot.docs.map((QueryDocumentSnapshot<Object> doc) {
          return Trip.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        return trips;
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        CloudFunction().logError('Error retrieving current trip list:  $e');
        return <Trip>[];
      }
    }

    return tripCollection
        .where('accessUsers',
            arrayContainsAny: <String>[userService.currentUserID])
        .snapshots()
        .map(currentCrewTripListFromSnapshot);
  }
}
