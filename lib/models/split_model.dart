import 'package:cloud_firestore/cloud_firestore.dart';

///Model for split object
class SplitObject {
  SplitObject(
      {this.amountRemaining,
      this.dateCreated,
      this.details,
      this.itemDescription,
      this.itemDocID,
      this.itemName,
      this.itemTotal,
      this.itemType,
      this.lastUpdated,
      this.purchasedByUID,
      this.tripDocID,
      this.users,
      this.userSelectedList});

  SplitObject.fromData(Map<String, dynamic> data)
      : amountRemaining = data['amountRemaining'] as double,
        dateCreated = data['dateCreated'] as Timestamp,
        details = data['details'] as String,
        itemDescription = data['itemDescription'] as String,
        itemDocID = data['itemDocID'] as String,
        itemName = data['itemName'] as String,
        itemTotal = data['itemTotal'] as double,
        itemType = data['itemType'] as String,
        lastUpdated = data['lastUpdated'] as Timestamp,
        purchasedByUID = data['purchasedByUID'] as String,
        users = List<String>.from(data['users'] as List<String>),
        userSelectedList =
            List<String>.from(data['userSelectedList'] as List<String>),
        tripDocID = data['tripDocID'] as String;

  double? amountRemaining;
  Timestamp? dateCreated;
  String? details;
  String? itemDescription;
  String? itemDocID;
  String? itemName;
  double? itemTotal;
  String? itemType;
  Timestamp? lastUpdated;
  String? purchasedByUID;
  String? tripDocID;
  List<String>? users;
  List<String>? userSelectedList;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'amountRemaining': amountRemaining,
      'dateCreated': dateCreated,
      'details': details,
      'itemDescription': itemDescription,
      'itemDocID': itemDocID,
      'itemName': itemName,
      'itemTotal': itemTotal,
      'itemType': itemType,
      'lastUpdated': lastUpdated,
      'purchasedByUID': purchasedByUID,
      'tripDocID': tripDocID,
      'users': users,
      'userSelectedList': userSelectedList
    };
  }
}
