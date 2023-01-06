import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/functions/cloud_functions.dart';

///Model for lodging data
class LodgingData {
  LodgingData({
    required this.endTime,
    required this.startTime,
    required this.startDateTimestamp,
    required this.endDateTimestamp,
    required this.location,
    required this.comment,
    required this.displayName,
    required this.fieldID,
    required this.link,
    required this.lodgingType,
    required this.uid,
    required this.voters,
  });

  factory LodgingData.fromDocument(DocumentSnapshot<Object?> doc) {
    String lodgingType = '';
    String comment = '';
    String displayName = '';
    String endTime = '';
    Timestamp endDateTimestamp = Timestamp.now();
    Timestamp startDateTimestamp = Timestamp.now();
    String fieldID = '';
    String link = '';
    String location = '';
    String startTime = '';
    String uid = '';
    List<String> voters = <String>[];
    try {
      lodgingType = doc.get('lodgingType') as String;
    } catch (e) {
      // CloudFunction().logError('activityType error: ${e.toString()}');
    }
    try {
      comment = doc.get('comment') as String;
    } catch (e) {
      // CloudFunction().logError('comment error: ${e.toString()}');
    }
    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      // CloudFunction().logError('Display name error: ${e.toString()}');
    }
    try {
      endTime = doc.get('endTime') as String;
    } catch (e) {
      // CloudFunction().logError('endTime error: ${e.toString()}');
    }
    try {
      endDateTimestamp = doc.get('endDateTimestamp') as Timestamp;
    } catch (e) {
      // CloudFunction().logError('endDateTimestamp error: ${e.toString()}');
    }
    try {
      startDateTimestamp = doc.get('startDateTimestamp') as Timestamp;
    } catch (e) {
      // CloudFunction().logError('startDateTimestamp error: ${e.toString()}');
    }
    try {
      fieldID = doc.get('fieldID') as String;
    } catch (e) {
      // CloudFunction().logError('fieldID error: ${e.toString()}');
    }
    try {
      link = doc.get('link') as String;
    } catch (e) {
      // CloudFunction().logError('link error: ${e.toString()}');
    }
    try {
      location = doc.get('location') as String;
    } catch (e) {
      // CloudFunction().logError('location error: ${e.toString()}');
    }
    try {
      startTime = doc.get('startTime') as String;
    } catch (e) {
      // CloudFunction().logError('startTime error: ${e.toString()}');
    }
    try {
      var votes = doc.get('voters') as List<dynamic>;
      votes.forEach((dynamic element) {voters.add(element.toString());});
    } catch (e) {
      // CloudFunction().logError('voters error: ${e.toString()}');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      // CloudFunction().logError('UID error: ${e.toString()}');
    }
    return LodgingData(
        endTime: endTime,
        endDateTimestamp: endDateTimestamp,
        startDateTimestamp: startDateTimestamp,
        startTime: startTime,
        comment: comment,
        displayName: displayName,
        fieldID: fieldID,
        link: link,
        location: location,
        lodgingType: lodgingType,
        uid: uid,
        voters: voters);
  }

  String comment;
  Timestamp startDateTimestamp;
  Timestamp endDateTimestamp;
  String displayName;
  String endTime;
  String fieldID;
  String link;
  String location;
  String lodgingType;
  String startTime;
  String uid;
  List<String> voters;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'comment': comment,
      'startDateTimestamp': startDateTimestamp,
      'endDateTimestamp': endDateTimestamp,
      'displayName': displayName,
      'endTime': endTime,
      'fieldID': fieldID,
      'link': link,
      'location': location,
      'lodgingType': lodgingType,
      'startTime': startTime,
      'uid': uid,
      'voters': voters,
    };
  }
}

LodgingData defaultLodgingData = LodgingData(
    endTime: '',
    startTime: '',
    startDateTimestamp: Timestamp.now(),
    endDateTimestamp: Timestamp.now(),
    location: '',
    comment: '',
    displayName: '',
    fieldID: '',
    link: '',
    lodgingType: '',
    uid: '',
    voters: <String>[]);
