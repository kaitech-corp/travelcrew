import 'package:cloud_firestore/cloud_firestore.dart';

///Model for chat data in trip group chat
class ChatData {

  ChatData.fromData(Map<String, dynamic> data)
      : _chatID = data['chatID'] as String,
        _displayName = data['displayName'] as String,
        _fieldID = data['fieldID'] as String,
        _message = data['message'] as String,
        _timestamp = data['timestamp'] as Timestamp,
        _tripDocID = data['tripDocID'] as String,
        _uid = data['uid']as String;

  final String _displayName;
  final String _fieldID;
  final String _message;
  final Timestamp _timestamp;
  final String _uid;
  final String _chatID;
  final String _tripDocID;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'chatID': _chatID,
      'displayName': _displayName,
      'fieldID': _fieldID,
      'message': _message,
      'timestamp': _timestamp,
      'tripDocID': _tripDocID,
      'uid': _uid,
    };
  }

  String get displayName => _displayName;
  String get fieldID => _fieldID;
  String get message => _message;
  Timestamp get timestamp => _timestamp;
  String get uid => _uid;
  String get chatID => _chatID;

}
class Status {
  Status({this.uid, this.status,});

  Status.fromMap(Map<String, dynamic> data) : uid = data['uid'] as String, status = data['read'] as bool;
  final String? uid;
  final bool? status;
}
