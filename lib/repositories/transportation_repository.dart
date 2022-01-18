import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/transportation_model.dart';
import '../../../services/functions/cloud_functions.dart';

class TransportationRepository {

  final CollectionReference transportCollection =  FirebaseFirestore.instance.collection("transport");
  final _loadedData = StreamController<List<TransportationData>>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh(String tripDocID) {
    // Get all transportation items
    List<TransportationData> _transportListFromSnapshot(QuerySnapshot snapshot) {
      try {
        List<TransportationData> transportList =  snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return TransportationData.fromData(data);
        }).toList();

        return transportList;
      } catch (e) {
        CloudFunction().logError('Error retrieving transportation list:  ${e.toString()}');
        return null;
      }
    }

    Stream<List<TransportationData>> transportList = transportCollection
        .doc(tripDocID).collection('mode')
        .snapshots()
        .map(_transportListFromSnapshot);

    _loadedData.addStream(transportList);


  }

  Stream<List<TransportationData>> transportation() => _loadedData.stream;

}