import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/transportation_model.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';

class TransportationRepository extends GenericBlocRepository<TransportationData> {

  final String tripDocID;

  TransportationRepository({this.tripDocID});

  Stream<List<TransportationData>> data() {
    final CollectionReference transportCollection = FirebaseFirestore.instance
        .collection("transport");

    // Get all transportation items
    List<TransportationData> _transportListFromSnapshot(
        QuerySnapshot snapshot) {
      try {
        List<TransportationData> transportList = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return TransportationData.fromData(data);
        }).toList();

        return transportList;
      } catch (e) {
        CloudFunction().logError(
            'Error retrieving transportation list:  ${e.toString()}');
        return [];
      }
    }

    return transportCollection
        .doc(tripDocID).collection('mode')
        .snapshots()
        .map(_transportListFromSnapshot);
  }
}