import 'package:cloud_firestore/cloud_firestore.dart';

///Model for lodging data
class LodgingData {
  
  final String comment;
  final Timestamp startDateTimestamp;
  final Timestamp endDateTimestamp;
  final String displayName;
  final String endTime;
  final String fieldID;
  final String link;
  final String location;
  final String lodgingType;
  final String startTime;
  final String uid;
  final List<String> voters;

  LodgingData({
    this.endTime,
    this.startTime,
    this.startDateTimestamp,
    this.endDateTimestamp,
    this.location,
    this.comment,
    this.displayName,
    this.fieldID,
    this.link,
    this.lodgingType,
    this.uid,
    this.voters,
  });

  LodgingData.fromData(Map<String, dynamic> data)
      : comment = data['comment'],
        startDateTimestamp = data['startDateTimestamp'] ?? Timestamp.now(),
        endDateTimestamp = data['endDateTimestamp'] ?? Timestamp.now(),
        displayName = data['displayName'],
        endTime = data['endTime'] ?? '',
        fieldID = data['fieldID'],
        link = data['link'],
        location = data['location'] ?? '',
        lodgingType = data['lodgingType'],
        startTime = data['startTime'] ?? '',
        uid = data['uid'],
        voters = List<String>.from(data['voters']);

  Map<String, dynamic> toJson() {
    return {
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