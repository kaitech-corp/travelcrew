import 'package:cloud_firestore/cloud_firestore.dart';


///Model for trip details
class Trip {

  final List<String> accessUsers;
  final String comment;
  final Timestamp dateCreatedTimeStamp;
  final String displayName;
  final String documentId;
  final String endDate;
  final Timestamp endDateTimeStamp;
  final List<String> favorite;
  final bool ispublic;
  final GeoPoint tripGeoPoint;
  final String tripName;
  final String location;
  final String ownerID;
  final String startDate;
  final Timestamp startDateTimeStamp;
  final String travelType;
  final String urlToImage;

  Trip({
    this.tripGeoPoint,
    this.comment,
    this.dateCreatedTimeStamp,
    this.displayName,
    this.favorite,
    this.accessUsers,
    this.documentId,
    this.endDate,
    this.endDateTimeStamp,
    this.ispublic,
    this.tripName,
    this.location,
    this.ownerID,
    this.startDate,
    this.startDateTimeStamp,
    this.travelType,
    this.urlToImage});

  Trip.fromData(Map<String, dynamic> data)
      : accessUsers = List<String>.from(data['accessUsers']),
        comment = data['comment'],
        dateCreatedTimeStamp = data['dateCreatedTimeStamp'],
        displayName = data['displayName'],
        documentId = data['documentId'],
        endDate = data['endDate'],
        endDateTimeStamp = data['endDateTimeStamp'],
        favorite = List<String>.from(data['favorite']),
        ispublic = data['ispublic'],
        tripGeoPoint = data['tripGeoPoint'],
        tripName = data['tripName'],
        location = data['location'],
        ownerID = data['ownerID'],
        startDate = data['startDate'],
        startDateTimeStamp = data['startDateTimeStamp'],
        travelType = data['travelType'],
        urlToImage = data['urlToImage'];

  Map<String, dynamic> toJson() {
    return {
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