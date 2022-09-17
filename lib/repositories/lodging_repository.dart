import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/lodging_model.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';

/// Interface to our 'lodging' Firebase collection.
/// It contains the lodging options for the different locations.
///
/// Relies on a remote NoSQL document-oriented database.
class LodgingRepository extends GenericBlocRepository<LodgingData> {

  LodgingRepository({required this.tripDocID});

  final String tripDocID;

  @override
  Stream<List<LodgingData>> data() {

    final CollectionReference<Object> lodgingCollection =  FirebaseFirestore.instance.collection('lodging');

    //Get Lodging items
    List<LodgingData> _lodgingListFromSnapshot(QuerySnapshot<Object> snapshot){
      try {
        final List<LodgingData> lodgingList = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return LodgingData.fromDocument(doc);
        }).toList();
        lodgingList.sort((LodgingData a, LodgingData b) => b.voters.length.compareTo(a.voters.length));
        return lodgingList;
      } catch (e) {
        CloudFunction().logError('Error retrieving lodging list:  ${e.toString()}');
        return <LodgingData>[];
      }
    }
    //Get Lodging List
    return lodgingCollection.doc(tripDocID)
        .collection('lodging')
        .snapshots()
        .map(_lodgingListFromSnapshot);
  }

}
