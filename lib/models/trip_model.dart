import 'package:cloud_firestore/cloud_firestore.dart';

///Model for trip details
class Trip {
  Trip(
      {required this.tripGeoPoint,
      required this.comment,
      required this.dateCreatedTimeStamp,
      required this.displayName,
      required this.favorite,
      required this.accessUsers,
      required this.documentId,
      required this.endDate,
      required this.endDateTimeStamp,
      required this.ispublic,
      required this.tripName,
      required this.location,
      required this.ownerID,
      required this.startDate,
      required this.startDateTimeStamp,
      required this.travelType,
      required this.urlToImage});

  factory Trip.fromDocument(DocumentSnapshot<Object?> doc) {
    List<String> accessUsers = <String>[];
    String comment = '';
    Timestamp dateCreatedTimeStamp = Timestamp.now();
    String displayName = '';
    String documentId = '';
    String endDate = '';
    Timestamp endDateTimeStamp = Timestamp.now();
    List<String> favorite = <String>[];
    bool ispublic = false;
    GeoPoint tripGeoPoint = const GeoPoint(0, 0);
    String tripName = '';
    String location = '';
    String ownerID = '';
    String startDate = '';
    Timestamp startDateTimeStamp = Timestamp.now();
    String travelType = '';
    String urlToImage = '';

    try {
      var userList = doc.get('accessUsers') as List<dynamic>;
      userList.forEach((element) {accessUsers.add(element.toString());});
    } catch (e) {
      // CloudFunction().logError('accessUsers error: ${e.toString()}');
    }
    try {
      comment = doc.get('comment') as String;
    } catch (e) {
      // CloudFunction().logError('comment error: ${e.toString()}');
    }
    try {
      dateCreatedTimeStamp = doc.get('dateCreatedTimeStamp') as Timestamp;
    } catch (e) {
      // CloudFunction().logError('dateCreatedTimeStamp error: ${e.toString()}');
    }
    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      // CloudFunction().logError('displayName error: ${e.toString()}');
    }
    try {
      documentId = doc.get('documentId') as String;
    } catch (e) {
      // CloudFunction().logError('documentId error: ${e.toString()}');
    }
    try {
      endDate = doc.get('endDate') as String;
    } catch (e) {
      // CloudFunction().logError('endDate error: ${e.toString()}');
    }
    try {
      endDateTimeStamp = doc.get('endDateTimeStamp') as Timestamp;
    } catch (e) {
      // CloudFunction().logError('endDateTimeStamp error: ${e.toString()}');
    }
    try {
      var fav = doc.get('favorite') as List<dynamic>;
      fav.forEach((element) {favorite.add(element.toString());});
    } catch (e) {
      // CloudFunction().logError('favorite error: ${e.toString()}');
    }
    try {
      ispublic = doc.get('ispublic') as bool;
    } catch (e) {
      // CloudFunction().logError('Iispublic error: ${e.toString()}');
    }
    try {
      location = doc.get('location') as String;
    } catch (e) {
      // CloudFunction().logError('location error: ${e.toString()}');
    }
    try {
      ownerID = doc.get('ownerID') as String;
    } catch (e) {
      // CloudFunction().logError('ownerID error: ${e.toString()}');
    }
    try {
      startDate = doc.get('startDate') as String;
    } catch (e) {
      // CloudFunction().logError('startDate error: ${e.toString()}');
    }
    try {
      startDateTimeStamp = doc.get('startDateTimeStamp') as Timestamp;
    } catch (e) {
      // CloudFunction().logError('startDateTimeStamp error: ${e.toString()}');
    }
    try {
      travelType = doc.get('travelType') as String;
    } catch (e) {
      // CloudFunction().logError('travelType error: ${e.toString()}');
    }
    try {
      tripGeoPoint = doc.get('tripGeoPoint') as GeoPoint;
    } catch (e) {
      // CloudFunction().logError('tripGeoPoint error: ${e.toString()}');
    }
    try {
      tripName = doc.get('tripName') as String;
    } catch (e) {
      // CloudFunction().logError('tripName error: ${e.toString()}');
    }
    try {
      urlToImage = doc.get('urlToImage') as String;
    } catch (e) {
      // CloudFunction().logError('Image url error: ${e.toString()}');
    }
    return Trip(
        tripGeoPoint: tripGeoPoint,
        comment: comment,
        dateCreatedTimeStamp: dateCreatedTimeStamp,
        displayName: displayName,
        favorite: favorite,
        accessUsers: accessUsers as List<String>,
        documentId: documentId,
        endDate: endDate,
        endDateTimeStamp: endDateTimeStamp,
        ispublic: ispublic,
        tripName: tripName,
        location: location,
        ownerID: ownerID,
        startDate: startDate,
        startDateTimeStamp: startDateTimeStamp,
        travelType: travelType,
        urlToImage: urlToImage);
  }
  List<String> accessUsers;
  String comment;
  Timestamp dateCreatedTimeStamp;
  String displayName;
  String documentId;
  String endDate;
  Timestamp endDateTimeStamp;
  List<String> favorite;
  bool ispublic;
  GeoPoint tripGeoPoint;
  String tripName;
  String location;
  String ownerID;
  String startDate;
  Timestamp startDateTimeStamp;
  String travelType;
  String urlToImage;

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

Trip defaultTrip = Trip(
    tripGeoPoint: const GeoPoint(0, 0),
    comment: '',
    dateCreatedTimeStamp: Timestamp.now(),
    displayName: '',
    favorite: <String>[],
    accessUsers: <String>[],
    documentId: '',
    endDate: '',
    endDateTimeStamp: Timestamp.now(),
    ispublic: false,
    tripName: '',
    location: '',
    ownerID: '',
    startDate: '',
    startDateTimeStamp: Timestamp.now(),
    travelType: '',
    urlToImage: '');
