import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/functions/cloud_functions.dart';

///Model for notifications
class NotificationData {
  NotificationData({
    required this.type,
    required this.ownerID,
    required this.ispublic,
    required this.timestamp,
    required this.message,
    required this.documentID,
    required this.displayName,
    required this.fieldID,
    required this.firstname,
    required this.lastname,
    required this.uid,
    required this.ownerDisplayName,
  });

  factory NotificationData.fromDocument(DocumentSnapshot<Object?> doc) {
    String documentID = '';
    String ownerID = '';
    String displayName = '';
    String ownerDisplayName = '';
    String fieldID = '';
    String firstname = '';
    bool ispublic = false;
    String lastname = '';
    String message = '';
    Timestamp timestamp = Timestamp.now();
    String type = '';
    String uid = '';
    try {
      documentID = doc.get('documentID') as String;
    } catch (e) {
      CloudFunction().logError('documentID error: $e');
    }
    try {
      ownerID = doc.get('ownerID') as String;
    } catch (e) {
      CloudFunction().logError('ownerID error: $e');
    }
    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      CloudFunction().logError('Display name error: $e');
    }
    try {
      ownerDisplayName = doc.get('ownerDisplayName') as String;
    } catch (e) {
      CloudFunction().logError('ownerDisplayName error: $e');
    }
    try {
      timestamp = doc.get('timestamp') as Timestamp;
    } catch (e) {
      CloudFunction().logError('timestamp error: $e');
    }
    try {
      fieldID = doc.get('fieldID') as String;
    } catch (e) {
      CloudFunction().logError('fieldID error: $e');
    }
    try {
      firstname = doc.get('firstname') as String;
    } catch (e) {
      CloudFunction().logError('firstname error: $e');
    }
    try {
      ispublic = doc.get('ispublic') as bool;
    } catch (e) {
      CloudFunction().logError('ispublic error: $e');
    }
    try {
      lastname = doc.get('lastname') as String;
    } catch (e) {
      CloudFunction().logError('lastname error: $e');
    }
    try {
      message = doc.get('message') as String;
    } catch (e) {
      CloudFunction().logError('message error: $e');
    }
    try {
      type = doc.get('type') as String;
    } catch (e) {
      CloudFunction().logError('type error: $e');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      CloudFunction().logError('UID error: $e');
    }
    return NotificationData(type: type,
        ownerID: ownerID,
        ispublic: ispublic,
        timestamp: timestamp,
        message: message,
        documentID: documentID,
        displayName: displayName,
        fieldID: fieldID,
        firstname: firstname,
        lastname: lastname,
        uid: uid,
        ownerDisplayName: ownerDisplayName);
  }

  String documentID;
  String displayName;
  String ownerID;
  String ownerDisplayName;
  String fieldID;
  String firstname;
  bool ispublic;
  String lastname;
  String message;
  Timestamp timestamp;
  String type;
  String uid;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'documentID': documentID,
      'displayName': displayName,
      'ownerID': ownerID,
      'ownerDisplayName': ownerDisplayName,
      'fieldID': fieldID,
      'firstname': firstname,
      'ispublic': ispublic,
      'lastname': lastname,
      'message': message,
      'timestamp': timestamp,
      'type': type,
      'uid': uid,
    };
  }

}
