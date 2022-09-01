import 'package:cloud_firestore/cloud_firestore.dart';

///Model for notifications
class NotificationData {

  NotificationData.fromData(Map<String, dynamic> data)
      : _documentID = data['documentID'] as String,
        _displayName = data['displayName'] as String,
        _ownerID = data['ownerID'] as String,
        _ownerDisplayName = data['ownerDisplayName'] as String,
        _fieldID = data['fieldID'] as String,
        _firstname = data['firstname'] as String,
        _ispublic = data['ispublic'] as bool,
        _lastname = data['lastname'] as String,
        _message = data['message'] as String,
        _timestamp = data['timestamp'] as Timestamp,
        _type = data['type'] as String,
        _uid = data['uid'] as String;

  final String _documentID;
  final String _displayName;
  final String _ownerID;
  final String _ownerDisplayName;
  final String _fieldID;
  final String _firstname;
  final bool _ispublic;
  final String _lastname;
  final String _message;
  final Timestamp _timestamp;
  final String _type;
  final String _uid;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'documentID': _documentID,
      'displayName': _displayName,
      'ownerID': _ownerID,
      'ownerDisplayName': _ownerDisplayName,
      'fieldID': _fieldID,
      'firstname': _firstname,
      'ispublic': _ispublic,
      'lastname': _lastname,
      'message': _message,
      'timestamp': _timestamp,
      'type': _type,
      'uid': _uid,
    };
  }

  String get documentID => _documentID;
  String get displayName => _displayName;
  String get ownerID => _ownerID;
  String get ownerDisplayName => _ownerDisplayName;
  String get fieldID => _fieldID;
  String get firstname => _firstname;
  bool get ispublic => _ispublic;
  String get lastname => _lastname;
  String get message => _message;
  Timestamp get timestamp => _timestamp;
  String get type => _type;
  String get uid => _uid;

}
