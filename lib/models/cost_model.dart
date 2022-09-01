import 'package:cloud_firestore/cloud_firestore.dart';

///Model for cost data when spliting items
class CostObject {

  CostObject({
    this.amountOwe,
    this.datePaid,
    this.itemDocID,
    this.lastUpdated,
    this.paid,
    this.uid,
    this.tripDocID});


  CostObject.fromData(Map<String, dynamic> data):
        amountOwe = data['amountOwe'] as double,
        datePaid = data['datePaid'] as Timestamp,
        itemDocID = data['itemDocID'] as String,
        lastUpdated = data['lastUpdated'] as Timestamp,
        paid = data['paid'] as bool,
        tripDocID = data['tripDocID'] as String,
        uid = data['uid'] as String;

  double? amountOwe;
  Timestamp? datePaid;
  String? itemDocID;
  Timestamp? lastUpdated;
  bool? paid;
  String? uid;
  String? tripDocID;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'amountOwe': amountOwe,
      'datePaid': datePaid,
      'itemDocID': itemDocID,
      'lastUpdated':lastUpdated,
      'paid': paid,
      'tripDocID': tripDocID,
      'uid': uid,
    };
  }
}
