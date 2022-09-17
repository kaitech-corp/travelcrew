import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/functions/cloud_functions.dart';

///Model for activity data
class ActivityData {
  ActivityData(
      {required this.endTime,
      required this.endDateTimestamp,
      required this.startDateTimestamp,
      required this.dateTimestamp,
      required this.startTime,
      required this.comment,
      required this.displayName,
      required this.fieldID,
      required this.link,
      required this.location,
      required this.activityType,
      required this.uid,
      required this.voters});

  factory ActivityData.fromDocument(DocumentSnapshot<Object?> doc) {
    String activityType = '';
    String comment = '';
    String displayName = '';
    String endTime = '';
    Timestamp dateTimestamp = Timestamp.now();
    Timestamp endDateTimestamp = Timestamp.now();
    Timestamp startDateTimestamp = Timestamp.now();
    String fieldID = '';
    String link = '';
    String location = '';
    String startTime = '';
    String uid = '';
    List<String> voters = <String>[];
    try {
      activityType = doc.get('activityType') as String;
    } catch (e) {
      CloudFunction().logError('activityType error: ${e.toString()}');
    }
    try {
      comment = doc.get('comment') as String;
    } catch (e) {
      CloudFunction().logError('comment error: ${e.toString()}');
    }
    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      CloudFunction().logError('Display name error: ${e.toString()}');
    }
    try {
      endTime = doc.get('endTime') as String;
    } catch (e) {
      CloudFunction().logError('endTime error: ${e.toString()}');
    }
    try {
      dateTimestamp = doc.get('dateTimestamp') as Timestamp;
    } catch (e) {
      CloudFunction().logError('dateTimestamp error: ${e.toString()}');
    }
    try {
      endDateTimestamp = doc.get('endDateTimestamp') as Timestamp;
    } catch (e) {
      CloudFunction().logError('endDateTimestamp error: ${e.toString()}');
    }
    try {
      startDateTimestamp = doc.get('startDateTimestamp') as Timestamp;
    } catch (e) {
      CloudFunction().logError('startDateTimestamp error: ${e.toString()}');
    }
    try {
      fieldID = doc.get('fieldID') as String;
    } catch (e) {
      CloudFunction().logError('fieldID error: ${e.toString()}');
    }
    try {
      link = doc.get('link') as String;
    } catch (e) {
      CloudFunction().logError('link error: ${e.toString()}');
    }
    try {
      location = doc.get('location') as String;
    } catch (e) {
      CloudFunction().logError('location error: ${e.toString()}');
    }
    try {
      startTime = doc.get('startTime') as String;
    } catch (e) {
      CloudFunction().logError('startTime error: ${e.toString()}');
    }
    try {
      var votes = doc.get('voters') as List<dynamic>;
      votes.forEach((dynamic element) {voters.add(element.toString());});
    } catch (e) {
      CloudFunction().logError('voters error: ${e.toString()}');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      CloudFunction().logError('UID error: ${e.toString()}');
    }
    return ActivityData(
        endTime: endTime,
        endDateTimestamp: endDateTimestamp,
        startDateTimestamp: startDateTimestamp,
        dateTimestamp: dateTimestamp,
        startTime: startTime,
        comment: comment,
        displayName: displayName,
        fieldID: fieldID,
        link: link,
        location: location,
        activityType: activityType,
        uid: uid,
        voters: voters);
  }

  String activityType;
  String comment;
  String displayName;
  String endTime;
  Timestamp dateTimestamp;
  Timestamp endDateTimestamp;
  Timestamp startDateTimestamp;
  String fieldID;
  String link;
  String location;
  String startTime;
  String uid;
  List<String> voters;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'activityType': activityType,
      'comment': comment,
      'displayName': displayName,
      'endTime': endTime,
      'dateTimestamp': dateTimestamp,
      'endDateTimestamp': endDateTimestamp,
      'startDateTimestamp': startDateTimestamp,
      'fieldID': fieldID,
      'link': link,
      'location': location,
      'startTime': startTime,
      'uid': uid,
      'voters': voters,
    };
  }
}

ActivityData defaultActivityData = ActivityData(
    endTime: '',
    endDateTimestamp: Timestamp.now(),
    startDateTimestamp: Timestamp.now(),
    dateTimestamp: Timestamp.now(),
    startTime: '',
    comment: '',
    displayName: '',
    fieldID: '',
    link: '',
    location: '',
    activityType: '',
    uid: '',
    voters: <String>[]);
