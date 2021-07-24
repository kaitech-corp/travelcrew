import 'package:cloud_firestore/cloud_firestore.dart';

class ChatData {
  final String _displayName;
  final String _fieldID;
  final String _message;
  final Timestamp _timestamp;
  final String _uid;
  final String _chatID;



  ChatData.fromData(Map<String, dynamic> data)
      : _chatID = data['chatID'] ?? '',
        _displayName = data['displayName'] ?? '',
        _fieldID = data['fieldID'] ?? '',
        _message = data['message'] ?? '',
        _timestamp = data['timestamp'] ?? null,
        _uid = data['uid'];

  Map<String, dynamic> toJson() {
    return {
      'chatID': _chatID,
      'displayName': _displayName,
      'fieldID': _fieldID,
      'message': _message,
      'timestamp': _timestamp,
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
  final String uid;
  final bool status;

  Status.fromMap(Map<String, dynamic> data) : uid = data["uid"], status = data["read"];
  Status({this.uid, this.status,});
}