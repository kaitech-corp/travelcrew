import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityData {
  final String activityType;
  final String comment;
  final String displayName;
  final String endTime;
  final Timestamp dateTimestamp;
  final String fieldID;
  final String link;
  final String location;
  final String startTime;
  final String uid;
  final List<String> voters;

  ActivityData({this.endTime, this.dateTimestamp, this.startTime, this.comment, this.displayName, this.fieldID, this.link, this.location, this.activityType, this.uid, this.voters});

  ActivityData.fromData(Map<String, dynamic> data)
      : activityType = data['activityType'],
        comment = data['comment'],
        displayName = data['displayName'],
        endTime = data['endTime'],
        dateTimestamp = data['dateTimestamp'] ?? null,
        fieldID = data['fieldID'],
        link = data['link'],
        location = data['location'] ?? '',
        startTime = data['startTime'],
        uid = data['uid'],
        voters = List<String>.from(data['voters']);

  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'comment': comment,
      'displayName': displayName,
      'endTime': endTime,
      'dateTimestamp': dateTimestamp,
      'fieldID': fieldID,
      'link': link,
      'location': location,
      'startTime': startTime,
      'uid': uid,
      'voters': voters,
    };
  }

}