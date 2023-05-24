import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';
import '../models/transportation_model/transportation_model.dart';

class TransportationRepository extends GenericBlocRepository<TransportationModel> {

  TransportationRepository({required this.tripDocID});

  final String tripDocID;

  @override
  Stream<List<TransportationModel>> data() {
    final CollectionReference<Object> transportCollection = FirebaseFirestore.instance
        .collection('transport');

    // Get all transportation items
    List<TransportationModel> transportListFromSnapshot(
        QuerySnapshot<Object> snapshot) {
      try {
        final List<TransportationModel> transportList = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return TransportationModel.fromJson(doc as Map<String, Object>);
        }).toList();

        return transportList;
      } catch (e) {
        CloudFunction().logError(
            'Error retrieving transportation list:  $e');
        return <TransportationModel>[];
      }
    }

    return transportCollection
        .doc(tripDocID).collection('mode')
        .snapshots()
        .map(transportListFromSnapshot);
  }
}
