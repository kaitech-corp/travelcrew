import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../blocs/generics/generic_bloc.dart';

class AllTripsSuggestionRepository extends GenericBlocRepository<Trip> {

  @override
  Stream<List<Trip>> data() {
    //Firebase Collection
    final Query<Object> tripCollection = FirebaseFirestore.instance
        .collection('trips')
        .where('ispublic', isEqualTo: true);

    // Get all trips
    List<Trip> _tripListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        List<Trip> trips = snapshot.docs.map((QueryDocumentSnapshot<Object> doc) {
          return Trip.fromDocument(doc);
        }).toList();
        trips = trips
            .where(
                (Trip trip) => (trip.location.length) < 20 && (trip.location.length) > 0)
            .toList();
        return trips;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving all trip list:  ${e.toString()}');
        return <Trip>[];
      }
    }

    // get trips stream
    return tripCollection
        .snapshots()
        .map(_tripListFromSnapshot);
  }
}
