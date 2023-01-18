import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/transportation_model.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';

class TransportationRepository extends GenericBlocRepository<TransportationData> {

  TransportationRepository({required this.tripDocID});

  final String tripDocID;

  @override
  Stream<List<TransportationData>> data() {
    final CollectionReference<Object> transportCollection = FirebaseFirestore.instance
        .collection('transport');

    // Get all transportation items
    List<TransportationData> transportListFromSnapshot(
        QuerySnapshot<Object> snapshot) {
      try {
        final List<TransportationData> transportList = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return TransportationData.fromDocument(doc);
        }).toList();

        return transportList;
      } catch (e) {
        CloudFunction().logError(
            'Error retrieving transportation list:  ${e.toString()}');
        return <TransportationData>[];
      }
    }

    return transportCollection
        .doc(tripDocID).collection('mode')
        .snapshots()
        .map(transportListFromSnapshot);
  }
}
