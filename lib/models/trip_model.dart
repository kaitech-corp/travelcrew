import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final List<String> _accessUsers;
  final String _comment;
  final Timestamp _dateCreatedTimeStamp;
  final String _displayName;
  final String _documentId;
  final String _endDate;
  final Timestamp _endDateTimeStamp;
  final List<String> _favorite;
  final bool _ispublic;
  final GeoPoint _tripGeoPoint;
  final String _tripName;
  final String _location;
  final String _ownerID;
  final String _startDate;
  final Timestamp _startDateTimeStamp;
  final String _travelType;
  final String _urlToImage;

  // Trip({this.tripGeoPoint, this.comment, this.dateCreatedTimeStamp, this.displayName, this.favorite, this.accessUsers, this.documentId, this.endDate, this.endDateTimeStamp, this.ispublic,this.tripName, this.location, this.ownerID, this.startDate, this.startDateTimeStamp, this.travelType, this.urlToImage});

  Trip.fromData(Map<String, dynamic> data)
      : _accessUsers = List<String>.from(data['accessUsers']),
        _comment = data['comment'],
        _dateCreatedTimeStamp = data['dateCreatedTimeStamp'],
        _displayName = data['displayName'],
        _documentId = data['documentId'],
        _endDate = data['endDate'],
        _endDateTimeStamp = data['endDateTimeStamp'],
        _favorite = List<String>.from(data['favorite']),
        _ispublic = data['ispublic'],
        _tripGeoPoint = data['tripGeoPoint'],
        _tripName = data['tripName'],
        _location = data['location'],
        _ownerID = data['ownerID'],
        _startDate = data['startDate'],
        _startDateTimeStamp = data['startDateTimeStamp'],
        _travelType = data['travelType'],
        _urlToImage = data['urlToImage'];

  Map<String, dynamic> toJson() {
    return {
      'accessUsers': _accessUsers,
      'comment': _comment,
      'dateCreatedTimeStamp': _dateCreatedTimeStamp,
      'displayName': _displayName,
      'documentId': _documentId,
      'endDate': _endDate,
      'endDateTimeStamp': _endDateTimeStamp,
      'favorite': _favorite,
      'ispublic': _ispublic,
      'tripGeoPoint': _tripGeoPoint,
      'tripName': _tripName,
      'location': _location,
      'ownerID': _ownerID,
      'startDate': _startDate,
      'startDateTimeStamp': _startDateTimeStamp,
      'travelType': _travelType,
      'urlToImage': _urlToImage,
    };
  }

  List<String> get accessUsers => _accessUsers;
  String get comment => _comment;
  Timestamp get dateCreatedTimeStamp => _dateCreatedTimeStamp;
  String get displayName => _displayName;
  String get documentId => _documentId;
  String get endDate => _endDate;
  Timestamp get endDateTimeStamp => _endDateTimeStamp;
  List<String> get favorite => _favorite;
  bool get ispublic => _ispublic;
  GeoPoint get tripGeoPoint => _tripGeoPoint;
  String get tripName => _tripName;
  String get location => _location;
  String get ownerID => _ownerID;
  String get startDate => _startDate;
  Timestamp get startDateTimeStamp => _startDateTimeStamp;
  String get travelType => _travelType;
  String get urlToImage => _urlToImage;


}