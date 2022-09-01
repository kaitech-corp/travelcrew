import 'package:cloud_firestore/cloud_firestore.dart';

///Model for trip details
class Trip {
  Trip(
      {this.tripGeoPoint,
      this.comment,
      this.dateCreatedTimeStamp,
      this.displayName,
      this.favorite,
      this.accessUsers,
      this.documentId,
      this.endDate,
      this.endDateTimeStamp,
      required this.ispublic,
      this.tripName,
      this.location,
      this.ownerID,
      this.startDate,
      this.startDateTimeStamp,
      this.travelType,
      this.urlToImage});

  Trip.fromData(Map<String, dynamic> data)
      : accessUsers = List<String>.from(data['accessUsers'] as List<String>),
        comment = data['comment'] as String,
        dateCreatedTimeStamp = data['dateCreatedTimeStamp'] as Timestamp,
        displayName = data['displayName'] as String,
        documentId = data['documentId'] as String,
        endDate = data['endDate'] as String,
        endDateTimeStamp = data['endDateTimeStamp'] as Timestamp,
        favorite = List<String>.from(data['favorite'] as List<String>),
        ispublic = data['ispublic'] as bool,
        tripGeoPoint = data['tripGeoPoint'] as GeoPoint,
        tripName = data['tripName'] as String,
        location = data['location'] as String,
        ownerID = data['ownerID'] as String,
        startDate = data['startDate'] as String,
        startDateTimeStamp = data['startDateTimeStamp'] as Timestamp,
        travelType = data['travelType'] as String,
        urlToImage = data['urlToImage'] as String;

  final List<String>? accessUsers;
  final String? comment;
  final Timestamp? dateCreatedTimeStamp;
  final String? displayName;
  final String? documentId;
  final String? endDate;
  final Timestamp? endDateTimeStamp;
  final List<String>? favorite;
  final bool ispublic;
  final GeoPoint? tripGeoPoint;
  final String? tripName;
  final String? location;
  final String? ownerID;
  final String? startDate;
  final Timestamp? startDateTimeStamp;
  final String? travelType;
  final String? urlToImage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'accessUsers': accessUsers,
      'comment': comment,
      'dateCreatedTimeStamp': dateCreatedTimeStamp,
      'displayName': displayName,
      'documentId': documentId,
      'endDate': endDate,
      'endDateTimeStamp': endDateTimeStamp,
      'favorite': favorite,
      'ispublic': ispublic,
      'tripGeoPoint': tripGeoPoint,
      'tripName': tripName,
      'location': location,
      'ownerID': ownerID,
      'startDate': startDate,
      'startDateTimeStamp': startDateTimeStamp,
      'travelType': travelType,
      'urlToImage': urlToImage,
    };
  }
}
