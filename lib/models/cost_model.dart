import 'package:cloud_firestore/cloud_firestore.dart';

///Model for cost data when spliting items
class CostObject {
  double? amountOwe;
  Timestamp? datePaid;
  String? itemDocID;
  Timestamp? lastUpdated;
  bool? paid;
  String? uid;
  String? tripDocID;

  CostObject({
    this.amountOwe,
    this.datePaid,
    this.itemDocID,
    this.lastUpdated,
    this.paid,
    this.uid,
    this.tripDocID});


  CostObject.fromData(Map<String, dynamic> data):
        amountOwe = data['amountOwe'] ?? '',
        datePaid = data['datePaid'] ?? null,
        itemDocID = data['itemDocID'] ?? '',
        lastUpdated = data['lastUpdated'] ?? null,
        paid = data['paid'] ?? '',
        tripDocID = data['tripDocID'] ?? '',
        uid = data['uid'] ?? '';

  Map<String, dynamic> toJson() {
    return {
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