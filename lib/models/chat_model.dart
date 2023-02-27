import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/functions/cloud_functions.dart';

///Model for chat data in trip group chat
class ChatData {
  ChatData(
      {required this.timestamp,
      required this.fieldID,
      required this.displayName,
      required this.message,
      required this.uid,
      required this.tripDocID,
      required this.chatID});

  factory ChatData.fromDocument(DocumentSnapshot<Object?> doc) {
    String displayName = '';
    String fieldID = '';
    String message = '';
    Timestamp timestamp = Timestamp.now();
    String chatID = '';
    String tripDocID = '';
    String uid = '';
    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      CloudFunction().logError('displayName error: $e');
    }
    try {
      fieldID = doc.get('fieldID') as String;
    } catch (e) {
      CloudFunction().logError('fieldID error: $e');
    }
    try {
      message = doc.get('message') as String;
    } catch (e) {
      CloudFunction().logError('message error: $e');
    }
    try {
      timestamp = doc.get('timestamp') as Timestamp;
    } catch (e) {
      CloudFunction().logError('timestamp error: $e');
    }
    try {
      chatID = doc.get('chatID') as String;
    } catch (e) {
      CloudFunction().logError('chatID error: $e');
    }
    try {
      tripDocID = doc.get('tripDocID') as String;
    } catch (e) {
      CloudFunction().logError('tripDocID error: $e');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      CloudFunction().logError('uid error: $e');
    }
    return ChatData(
        timestamp: timestamp,
        fieldID: fieldID,
        displayName: displayName,
        message: message,
        uid: uid,
        tripDocID: tripDocID,
        chatID: chatID);
  }

  String displayName;
  String fieldID;
  String message;
  Timestamp timestamp;
  String uid;
  String chatID;
  String tripDocID;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'chatID': chatID,
      'displayName': displayName,
      'fieldID': fieldID,
      'message': message,
      'timestamp': timestamp,
      'tripDocID': tripDocID,
      'uid': uid,
    };
  }
}

ChatData defaultChatData = ChatData(timestamp: Timestamp.now(), fieldID: '', displayName: '', message: '', uid: '', tripDocID: '', chatID: '');
class Status {
  Status({
    this.uid,
    this.status,
  });

  Status.fromMap(Map<String, dynamic> data)
      : uid = data['uid'] as String,
        status = data['read'] as bool;
  String? uid;
  bool? status;
}
