import 'package:cloud_firestore/cloud_firestore.dart';

///Model for activity data
class ActivityData {

  ActivityData({this.endTime,this.endDateTimestamp, this.startDateTimestamp,this.dateTimestamp, this.startTime, this.comment, this.displayName, this.fieldID, this.link, this.location, this.activityType, this.uid, this.voters});

  ActivityData.fromData(Map<String, dynamic> data)
      : activityType = data['activityType'] as String,
        comment = data['comment'] as String,
        displayName = data['displayName'] as String,
        endTime = data['endTime'] as String,
        dateTimestamp = data['endDateTimestamp'] as Timestamp,
        endDateTimestamp = data['endDateTimestamp'] as Timestamp,
        startDateTimestamp = data['startDateTimestamp'] as Timestamp,
        fieldID = data['fieldID'] as String,
        link = data['link'] as String,
        location = data['location'] as String,
        startTime = data['startTime'] as String,
        uid = data['uid'] as String,
        voters = List<String>.from(data['voters'] as List<String>);

  final String? activityType;
  final String? comment;
  final String? displayName;
  final String? endTime;
  final Timestamp? dateTimestamp;
  final Timestamp? endDateTimestamp;
  final Timestamp? startDateTimestamp;
  final String? fieldID;
  final String? link;
  final String? location;
  final String? startTime;
  final String? uid;
  final List<String>? voters;

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
