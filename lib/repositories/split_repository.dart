import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';
import '../models/split_model/split_model.dart';

class SplitRepository extends GenericBlocRepository<SplitObject> {

  SplitRepository({required this.tripDocID});

  final String tripDocID;

  @override
  Stream<List<SplitObject>> data() {

    final CollectionReference<Object> splitItemCollection = FirebaseFirestore.instance.collection('splitItem');

    /// Stream in split item data
    List<SplitObject> splitItemDataFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final List<SplitObject> splitItemData =  snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return SplitObject.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        return splitItemData;
      } catch (e) {
        CloudFunction().logError('Error retrieving split list:  $e');
        return <SplitObject>[];
      }
    }

    return splitItemCollection.doc(tripDocID)
        .collection('Item')
        .snapshots()
        .map(splitItemDataFromSnapshot);

  }

}
