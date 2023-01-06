import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../blocs/generics/generic_bloc.dart';

class FavoriteTripRepository extends GenericBlocRepository<Trip> {

  @override
  Stream<List<Trip>> data() {

    final Query<Object> tripCollection = FirebaseFirestore.instance
        .collection('trips')
        .orderBy('endDateTimeStamp')
        .where('ispublic', isEqualTo: true);


    List<Trip> tripListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final List<Trip> trips = snapshot.docs.map((QueryDocumentSnapshot<Object> doc) {
          return Trip.fromDocument(doc);
        }).toList();
        trips.sort(
            (Trip a, Trip b) => a.startDateTimeStamp.compareTo(b.startDateTimeStamp));

        return trips;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving favorites trip list:  ${e.toString()}');
        return <Trip>[];
      }
    }

    // get trips stream
    return tripCollection
        .where('favorite', arrayContainsAny: <String>[userService.currentUserID])
        .snapshots()
        .map(tripListFromSnapshot);
  }
}
