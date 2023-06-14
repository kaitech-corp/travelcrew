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

List<Trip> getCurrentPrivateTrips(List<Trip> trips, bool past) {
  final DateTime today = DateTime.now();
  final List<Trip> output = <Trip>[];
  for (int i = 0; i < trips.length; i++) {
    if (past) {
      if (trips[i].endDateTimeStamp!.isBefore(today)) {
        output.add(trips[i]);
      }
    } else {
      if (trips[i].endDateTimeStamp!.isAfter(today)) {
        output.add(trips[i]);
      }
    }
  }
  return output;
}
