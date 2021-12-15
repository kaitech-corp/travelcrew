import 'package:cloud_firestore/cloud_firestore.dart';

///Model for notifications
class NotificationData {
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

  NotificationData.fromData(Map<String, dynamic> data)
      : _documentID = data['documentID'],
        _displayName = data['displayName'],
        _ownerID = data['ownerID'],
        _ownerDisplayName = data['ownerDisplayName'],
        _fieldID = data['fieldID'],
        _firstname = data['firstname'],
        _ispublic = data['ispublic'],
        _lastname = data['lastname'],
        _message = data['message'],
        _timestamp = data['timestamp'],
        _type = data['type'],
        _uid = data['uid'];

  Map<String, dynamic> toJson() {
    return {
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