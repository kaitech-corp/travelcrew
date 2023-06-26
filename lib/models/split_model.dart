// ignore_for_file: prefer_final_locals, always_specify_types

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
  dynamic getFieldValue(String fieldName, dynamic defaultValue) {
    try {
      return doc.get(fieldName);
    } catch (e) {
      CloudFunction().logError('$fieldName error: $e');
      return defaultValue;
    }
  }

  return SplitObject(
    amountRemaining: getFieldValue('amountRemaining', 0.0) as double,
    dateCreated: getFieldValue('dateCreated', Timestamp.now()) as Timestamp,
    details: getFieldValue('details', '') as String,
    itemDescription: getFieldValue('itemDescription', '') as String,
    itemDocID: getFieldValue('itemDocID', '') as String,
    itemName: getFieldValue('itemName', '') as String,
    itemTotal: getFieldValue('itemTotal', 0.0) as double,
    itemType: getFieldValue('itemType', '') as String,
    lastUpdated: getFieldValue('lastUpdated', Timestamp.now()) as Timestamp,
    purchasedByUID: getFieldValue('purchasedByUID', '') as String,
    tripDocID: getFieldValue('tripDocID', '') as String,
    users: (getFieldValue('users', <dynamic>[]) as List<dynamic>)
        .map((element) => element.toString())
        .toList(),
    userSelectedList: (getFieldValue('userSelectedList', <dynamic>[]) as List<dynamic>)
        .map((element) => element.toString())
        .toList(),
  );
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
