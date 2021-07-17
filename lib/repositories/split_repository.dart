import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/split_model.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class SplitRepository {

  final CollectionReference splitItemCollection = FirebaseFirestore.instance.collection('splitItem');
  final _loadedData = StreamController<List<SplitObject>>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh(String tripDocID) {
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

  Stream<List<SplitObject>> splitItemData = splitItemCollection.doc(tripDocID).collection('Item').snapshots().map(_splitItemDataFromSnapshot);


    _loadedData.addStream(splitItemData);


  }

  Stream<List<SplitObject>> splitData() => _loadedData.stream;

}