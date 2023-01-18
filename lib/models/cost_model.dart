import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/functions/cloud_functions.dart';

///Model for cost data when spliting items
class CostObject {
  CostObject(
      {required this.amountOwe,
        this.datePaid,
      required this.itemDocID,
      required this.lastUpdated,
      required this.paid,
      required this.uid,
      required this.tripDocID});

  factory CostObject.fromDocument(DocumentSnapshot<Object?> doc) {
    double amountOwe = 0;
    Timestamp datePaid = Timestamp.now();
    String itemDocID = '';
    Timestamp lastUpdated = Timestamp.now();
    bool paid = false;
    String uid = '';
    String tripDocID = '';

    try {
      amountOwe = doc.get('amountOwe') as double;
    } catch (e) {
      CloudFunction().logError('amountOwe error: ${e.toString()}');
    }
    try {
      datePaid = doc.get('datePaid') as Timestamp;
    } catch (e) {
      CloudFunction().logError('datePaid error: ${e.toString()}');
    }
    try {
      itemDocID = doc.get('itemDocID') as String;
    } catch (e) {
      CloudFunction().logError('itemDocID error: ${e.toString()}');
    }
    try {
      lastUpdated = doc.get('lastUpdated') as Timestamp;
    } catch (e) {
      CloudFunction().logError('lastUpdated error: ${e.toString()}');
    }
    try {
      paid = doc.get('paid') as bool;
    } catch (e) {
      CloudFunction().logError('paid error: ${e.toString()}');
    }
    try {
      tripDocID = doc.get('tripDocID') as String;
    } catch (e) {
      CloudFunction().logError('tripDocID error: ${e.toString()}');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      CloudFunction().logError('uid error: ${e.toString()}');
    }
    return CostObject(
        amountOwe: amountOwe,
        datePaid: datePaid,
        itemDocID: itemDocID,
        lastUpdated: lastUpdated,
        paid: paid,
        uid: uid,
        tripDocID: tripDocID);
  }

  double amountOwe;
  Timestamp? datePaid;
  String itemDocID;
  Timestamp lastUpdated;
  bool paid;
  String uid;
  String tripDocID;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'amountOwe': amountOwe,
      'datePaid': datePaid,
      'itemDocID': itemDocID,
      'lastUpdated': lastUpdated,
      'paid': paid,
      'tripDocID': tripDocID,
      'uid': uid,
    };
  }
}
