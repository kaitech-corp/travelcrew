import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/custom_objects.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';

/// Interface to our 'tripAds' Firebase collection.
///
/// Relies on a remote NoSQL document-oriented database.
class TripAdRepository extends GenericBlocRepository<TripAds> {

  @override
  Stream<List<TripAds>> data() {

    final CollectionReference<Object> adsCollection = FirebaseFirestore.instance.collection('tripAds');

// Get all Ads
    List<TripAds> _adListFromSnapshot(QuerySnapshot<Object> snapshot){

      try {
        return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc){
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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

