import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/trip_model/trip_model.dart';
import '../../../services/functions/cloud_functions.dart';

final CollectionReference<Object?> tripsCollectionUnordered =
    FirebaseFirestore.instance.collection('trips');

//// Get Trip Stream
Trip? _tripFromSnapshot(DocumentSnapshot<Object?> snapshot) {
  try {
    if (snapshot.exists) {
      return Trip.fromJson(snapshot as Map<String, Object>);
    }
  } catch (e) {
    CloudFunction().logError('Error retrieving current trip list:  $e');
    return Trip.mock();
  }
  return null;
}

const String tripDocID = '';
Stream<Trip?> get singleTripData {
  return tripsCollectionUnordered
      .doc(tripDocID)
      .snapshots()
      .map(_tripFromSnapshot);
}

List<Trip> getFilteredTrips(List<Trip> trips) {
  final DateTime yesterday = DateTime.now().add(const Duration(days: -1));
  return trips
      .where((Trip trip) => trip.endDateTimeStamp!.isAfter(yesterday))
      .toList();
}
