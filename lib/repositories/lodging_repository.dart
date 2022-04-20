import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/blocs/generics/generic_bloc.dart';

import '../../../../models/lodging_model.dart';
import '../../../../services/functions/cloud_functions.dart';

/// Interface to our 'lodging' Firebase collection.
/// It contains the lodging options for the different locations.
///
/// Relies on a remote NoSQL document-oriented database.
class LodgingRepository extends GenericBlocRepository<LodgingData> {

  final String tripDocID;

  LodgingRepository({this.tripDocID});

  Stream<List<LodgingData>> data() {

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
        return [];
      }
    }
    //Get Lodging List
    return lodgingCollection.doc(tripDocID)
        .collection('lodging')
        .snapshots()
        .map(_lodgingListFromSnapshot);
  }

}
