import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/split_model.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';

class SplitRepository extends GenericBlocRepository<SplitObject> {

  SplitRepository({required this.tripDocID});

  final String tripDocID;

  @override
  Stream<List<SplitObject>> data() {

    final CollectionReference<Object> splitItemCollection = FirebaseFirestore.instance.collection('splitItem');

    /// Stream in split item data
    List<SplitObject> _splitItemDataFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        final List<SplitObject> splitItemData =  snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return SplitObject.fromData(data);
        }).toList();

        return splitItemData;
      } catch (e) {
        CloudFunction().logError('Error retrieving split list:  ${e.toString()}');
        return [];
      }
    }

    return splitItemCollection.doc(tripDocID)
        .collection('Item')
        .snapshots()
        .map(_splitItemDataFromSnapshot);

  }

}