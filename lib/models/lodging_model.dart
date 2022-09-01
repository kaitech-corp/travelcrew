import 'package:cloud_firestore/cloud_firestore.dart';

///Model for lodging data
class LodgingData {

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
      : comment = data['comment'] as String,
        startDateTimestamp = data['startDateTimestamp'] as Timestamp,
        endDateTimestamp = data['endDateTimestamp'] as Timestamp,
        displayName = data['displayName'] as String,
        endTime = data['endTime'] as String,
        fieldID = data['fieldID'] as String,
        link = data['link'] as String,
        location = data['location'] as String,
        lodgingType = data['lodgingType'] as String,
        startTime = data['startTime'] as String,
        uid = data['uid'] as String,
        voters = List<String>.from(data['voters'] as List<String>);
  
  final String? comment;
  final Timestamp? startDateTimestamp;
  final Timestamp? endDateTimestamp;
  final String? displayName;
  final String? endTime;
  final String? fieldID;
  final String? link;
  final String? location;
  final String? lodgingType;
  final String? startTime;
  final String? uid;
  final List<String>? voters;

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
