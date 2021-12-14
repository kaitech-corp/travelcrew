import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/lodging_model.dart';
import '../../../services/functions/cloud_functions.dart';

class LodgingRepository {

  final CollectionReference lodgingCollection =  FirebaseFirestore.instance.collection("lodging");
  final _loadedData = StreamController<List<LodgingData>>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh(String tripDocID) {
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
    Stream<List<LodgingData>> lodgingList = lodgingCollection.doc(tripDocID).collection('lodging').snapshots().map(_lodgingListFromSnapshot);



    _loadedData.addStream(lodgingList);


  }

  Stream<List<LodgingData>> lodging() => _loadedData.stream;

}