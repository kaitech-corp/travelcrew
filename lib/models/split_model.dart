import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/functions/cloud_functions.dart';

///Model for split object
class SplitObject {
  SplitObject(
      {required this.amountRemaining,
      required this.dateCreated,
      required this.details,
      required this.itemDescription,
      required this.itemDocID,
      required this.itemName,
      required this.itemTotal,
      required this.itemType,
      required this.lastUpdated,
      required this.purchasedByUID,
      required this.tripDocID,
      required this.users,
      required this.userSelectedList});

  factory SplitObject.fromDocument(DocumentSnapshot<Object?> doc) {
    double amountRemaining = 0;
    Timestamp dateCreated = Timestamp.now();
    String details = '';
    String itemDescription = '';
    String itemDocID = '';
    String itemName = '';
    double itemTotal = 0;
    String itemType = '';
    Timestamp lastUpdated = Timestamp.now();
    String purchasedByUID = '';
    String tripDocID = '';
    List<String> users = <String>[''];
    List<String> userSelectedList = <String>[''];

    try {
      amountRemaining = doc.get('amountRemaining') as double;
    } catch (e) {
      CloudFunction().logError('amountRemaining error: ${e.toString()}');
    }
    try {
      dateCreated = doc.get('dateCreated') as Timestamp;
    } catch (e) {
      CloudFunction().logError('dateCreated error: ${e.toString()}');
    }
    try {
      details = doc.get('details') as String;
    } catch (e) {
      CloudFunction().logError('details error: ${e.toString()}');
    }
    try {
      itemName = doc.get('itemName') as String;
    } catch (e) {
      CloudFunction().logError('itemName error: ${e.toString()}');
    }
    try {
      itemDescription = doc.get('itemDescription') as String;
    } catch (e) {
      CloudFunction().logError('itemDescription error: ${e.toString()}');
    }
    try {
      itemDocID = doc.get('itemDocID') as String;
    } catch (e) {
      CloudFunction().logError('itemDocID error: ${e.toString()}');
    }
    try {
      itemTotal = doc.get('itemTotal') as double;
    } catch (e) {
      CloudFunction().logError('itemTotal error: ${e.toString()}');
    }
    try {
      itemType = doc.get('itemType') as String;
    } catch (e) {
      CloudFunction().logError('itemType error: ${e.toString()}');
    }
    try {
      lastUpdated = doc.get('lastUpdated') as Timestamp;
    } catch (e) {
      CloudFunction().logError('lastUpdated error: ${e.toString()}');
    }
    try {
      purchasedByUID = doc.get('purchasedByUID') as String;
    } catch (e) {
      CloudFunction().logError('purchasedByUID error: ${e.toString()}');
    }
    try {
      tripDocID = doc.get('tripDocID') as String;
    } catch (e) {
      CloudFunction().logError('tripDocID error: ${e.toString()}');
    }
    try {
      var x = doc.get('users') as List<dynamic>;
      x.forEach((dynamic element) {users.add(element.toString());});
    } catch (e) {
      CloudFunction().logError('users error: ${e.toString()}');
    }
    try {
      var x = doc.get('userSelectedList') as List<dynamic>;
      x.forEach((dynamic element) {userSelectedList.add(element.toString());});
    } catch (e) {
      CloudFunction().logError('userSelectedList error: ${e.toString()}');
    }
    return SplitObject(
        amountRemaining: amountRemaining,
        dateCreated: dateCreated,
        details: details,
        itemDescription: itemDescription,
        itemDocID: itemDocID,
        itemName: itemName,
        itemTotal: itemTotal,
        itemType: itemType,
        lastUpdated: lastUpdated,
        purchasedByUID: purchasedByUID,
        tripDocID: tripDocID,
        users: users,
        userSelectedList: userSelectedList);
  }

  double amountRemaining;
  Timestamp dateCreated;
  String details;
  String itemDescription;
  String itemDocID;
  String itemName;
  double itemTotal;
  String itemType;
  Timestamp lastUpdated;
  String purchasedByUID;
  String tripDocID;
  List<String> users;
  List<String> userSelectedList;

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

SplitObject defaultSplitObject = SplitObject(
    itemDocID: '',
    tripDocID: '',
    users: <String>[''],
    itemName: '',
    itemDescription: '',
    details: '',
    itemType: 'Transportation',
    purchasedByUID: '',
    userSelectedList: <String>[],
    dateCreated: Timestamp.now(),
    lastUpdated: Timestamp.now(),
    itemTotal: 0,
    amountRemaining: 0);
