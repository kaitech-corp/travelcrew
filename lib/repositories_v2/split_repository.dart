import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../blocs/generics/generic_bloc.dart';

import '../../../../models/split_model.dart';
import '../../../../services/functions/cloud_functions.dart';

class SplitRepository extends GenericBlocRepository<SplitObject> {

  final String tripDocID;

  SplitRepository({this.tripDocID});

  Stream<List<SplitObject>> data() {

    final CollectionReference splitItemCollection = FirebaseFirestore.instance.collection('splitItem');

    /// Stream in split item data
    List<SplitObject> _splitItemDataFromSnapshot(QuerySnapshot snapshot) {
      try {
        List<SplitObject> splitItemData =  snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return SplitObject.fromData(data);
        }).toList();

        return splitItemData;
      } catch (e) {
        CloudFunction().logError('Error retrieving split list:  ${e.toString()}');
        return null;
      }
    }

    return splitItemCollection.doc(tripDocID)
        .collection('Item')
        .snapshots()
        .map(_splitItemDataFromSnapshot);

  }

}