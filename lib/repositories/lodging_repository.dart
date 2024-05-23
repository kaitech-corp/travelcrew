import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../blocs/generics/generic_bloc.dart';
import '../models/lodging_model/lodging_model.dart';
import '../services/functions/cloud_functions/admin_functions.dart';

/// Interface to our 'lodging' Firebase collection.
/// It contains the lodging options for the different locations.
///
/// Relies on a remote NoSQL document-oriented database.
class LodgingRepository extends GenericBlocRepository<LodgingModel> {
  LodgingRepository({required this.tripDocID});

  final String tripDocID;

  @override
  Stream<List<LodgingModel>> data() {
    final CollectionReference<Object> lodgingCollection =
        FirebaseFirestore.instance.collection('lodging');

    //Get Lodging items
    List<LodgingModel> lodgingListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final List<LodgingModel> lodgingList =
            snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return LodgingModel.fromJson(doc.data()! as Map<String, dynamic>);
        }).toList();
        
        return lodgingList;
      } catch (e) {
        AdminCloudFunction().logError('Error retrieving lodging list:  $e');
        if (kDebugMode) {
          print('Error Stream lodging items: $e');
        }
        return <LodgingModel>[];
      }
    }

    //Get Lodging List
    return lodgingCollection
        .doc(tripDocID)
        .collection('lodging')
        .snapshots()
        .map(lodgingListFromSnapshot);
  }
}
