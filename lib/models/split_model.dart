import 'package:cloud_firestore/cloud_firestore.dart';

///Model for split object
class SplitObject {
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

  SplitObject({
    this.amountRemaining,
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



  SplitObject.fromData(Map<String, dynamic> data):
        amountRemaining = data['amountRemaining'] ?? '',
        dateCreated = data['dateCreated'] ?? '',
        details = data['details'] ?? '',
        itemDescription = data['itemDescription'] ?? '',
        itemDocID = data['itemDocID'] ?? '',
        itemName = data['itemName'] ?? '',
        itemTotal = data['itemTotal'] ?? '',
        itemType = data['itemType'] ?? '',
        lastUpdated = data['lastUpdated'] ?? '',
        purchasedByUID = data['purchasedByUID'] ?? '',
        users = List.from(data['users']),
        userSelectedList = List.from(data['userSelectedList']),
        tripDocID = data['tripDocID'] ?? '';

  Map<String, dynamic> toJson(){
    return {
      'amountRemaining':amountRemaining,
      'dateCreated':dateCreated,
      'details':details,
      'itemDescription':itemDescription,
      'itemDocID':itemDocID,
      'itemName':itemName,
      'itemTotal':itemTotal,
      'itemType':itemType,
      'lastUpdated':lastUpdated,
      'purchasedByUID':purchasedByUID,
      'tripDocID':tripDocID,
      'users':users,
      'userSelectedList':userSelectedList
    };
  }
}