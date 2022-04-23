import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/blocs/generics/generic_bloc.dart';

import '../../../../models/custom_objects.dart';
import '../../../../services/functions/cloud_functions.dart';

/// Interface to our 'tripAds' Firebase collection.
///
/// Relies on a remote NoSQL document-oriented database.
class TripAdRepository extends GenericBlocRepository<TripAds> {

  Stream<List<TripAds>> data() {

    final CollectionReference adsCollection = FirebaseFirestore.instance.collection('tripAds');

// Get all Ads
    List<TripAds> _adListFromSnapshot(QuerySnapshot snapshot){

      try {
        return snapshot.docs.map((doc){
          Map<String, dynamic> data = doc.data();
          return TripAds.fromData(data);
        }).toList().reversed.toList();
      } catch (e) {
        CloudFunction().logError('Error retrieving ad list:  ${e.toString()}');
        return [];
      }

    }
    return adsCollection.snapshots().map(_adListFromSnapshot);
  }
}

