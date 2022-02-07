import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/lodging_model.dart';
import '../../../../services/functions/cloud_functions.dart';

/// Interface to our 'lodging' Firebase collection.
/// It contains the lodging options for the different locations.
///
/// Relies on a remote NoSQL document-oriented database.
class LodgingRepository {

  Stream<List<LodgingData>> lodgingDataStream(String tripDocID) {

    final CollectionReference lodgingCollection =  FirebaseFirestore.instance.collection("lodging");

    //Get Lodging items
    List<LodgingData> _lodgingListFromSnapshot(QuerySnapshot snapshot){
      try {
        List<LodgingData> lodgingList = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return LodgingData.fromData(data);
        }).toList();
        lodgingList.sort((a, b) => b.voters.length.compareTo(a.voters.length));
        return lodgingList;
      } catch (e) {
        CloudFunction().logError('Error retrieving lodging list:  ${e.toString()}');
        return null;
      }
    }
    //Get Lodging List
    return lodgingCollection.doc(tripDocID)
        .collection('lodging')
        .snapshots()
        .map(_lodgingListFromSnapshot);
  }

}
