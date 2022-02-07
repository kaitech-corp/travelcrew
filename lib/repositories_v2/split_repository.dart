import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/split_model.dart';
import '../../../../services/functions/cloud_functions.dart';

class SplitRepository {

  Stream<List<SplitObject>> splitDataStream(String tripDocID) {

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