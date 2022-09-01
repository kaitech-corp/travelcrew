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


    List<Trip> _tripListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final List<Trip> trips = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Trip.fromData(data);
        }).toList();
        trips.sort(
            (Trip a, Trip b) => a.startDateTimeStamp!.compareTo(b.startDateTimeStamp!));

        return trips;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving favorites trip list:  ${e.toString()}');
        return [];
      }
    }

    // get trips stream
    return tripCollection
        .where('favorite', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_tripListFromSnapshot);
  }
}
