import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/transportation_model.dart';
import '../../../../services/functions/cloud_functions.dart';

class TransportationRepository {

  Stream<List<TransportationData>> transportationDataStream(String tripDocID) {
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
        return null;
      }
    }

    return transportCollection
        .doc(tripDocID).collection('mode')
        .snapshots()
        .map(_transportListFromSnapshot);
  }
}