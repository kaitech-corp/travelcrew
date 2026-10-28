import 'dart:convert';

import 'package:travel_crew/utils/travel_time.dart';

class ActivityModel {
  static String? scheduleError(DateTime? start, DateTime? end) {
    if ((start == null) != (end == null)) {
      return 'Select both activity times or clear the schedule';
    }
    if (start != null && end!.isBefore(start)) {
      return 'End time must follow start time';
    }
    return null;
  }

  final Map<String, String> timeOffsets;
  ActivityModel({
    this.timeOffsets = const {},
    required this.likesCount,
    required this.title,
    this.id,
    this.createdBy = '',
    this.isDeleted = false,
    this.isLegacy = false,
    this.contentRevision = 1,
    this.likedBy = const [],
    required this.tripId,
    required this.description,
    this.startDateTime,
    this.endDateTime,
    this.location,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      timeOffsets: TravelTime.offsets(map, ['startDateTime', 'endDateTime']),
      likesCount: (map['likesCount'] as int?) ?? 0,
      likedBy: List<String>.from(
        (map['likedBy'] as List<dynamic>?) ?? <dynamic>[],
      ),
      title: (map['title'] as String?) ?? '',
      id: map['id'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      isDeleted: map['isDeleted'] == true,
      contentRevision: (map['contentRevision'] as num?)?.toInt() ?? 0,
      tripId: (map['tripId'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      startDateTime:
          map['startDateTime'] != null
              ? TravelTime.parse(map['startDateTime'] as String)
              : null,
      endDateTime:
          map['endDateTime'] != null
              ? TravelTime.parse(map['endDateTime'] as String)
              : null,
      location: map['location'] as String?,
    );
  }

  factory ActivityModel.fromJson(String source) =>
      ActivityModel.fromMap(json.decode(source) as Map<String, dynamic>);
  DateTime? get startInstant =>
      TravelTime.instant(startDateTime, timeOffsets['startDateTime']);
  DateTime? get endInstant =>
      TravelTime.instant(endDateTime, timeOffsets['endDateTime']);

  String title;
  String? id;
  String createdBy;
  bool isDeleted;
  bool isLegacy;
  int contentRevision;
  String tripId;
  String description;
  List<String> likedBy;
  int likesCount = 0;
  DateTime? startDateTime;
  DateTime? endDateTime;
  String? location;

  ActivityModel copyWith({
    String? title,
    String? id,
    String? createdBy,
    bool? isDeleted,
    bool? isLegacy,
    int? contentRevision,
    String? tripId,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
  }) {
    return ActivityModel(
      timeOffsets: timeOffsets,
      title: title ?? this.title,
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
      isLegacy: isLegacy ?? this.isLegacy,
      contentRevision: contentRevision ?? this.contentRevision,
      likedBy: likedBy,
      likesCount: likesCount,
      tripId: tripId ?? this.tripId,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'title': title});
    result.addAll({'id': id});
    if (createdBy.isNotEmpty) result['createdBy'] = createdBy;
    result['isDeleted'] = isDeleted;
    result['contentRevision'] = contentRevision;
    result.addAll({'likedBy': likedBy});
    result.addAll({'likesCount': likesCount});
    result.addAll({'tripId': tripId});
    result.addAll({'description': description});
    if (startDateTime != null) {
      // Preserve the venue clock and its original UTC offset.
      result.addAll({
        'startDateTime': TravelTime.serialize(
          startDateTime,
          timeOffsets['startDateTime'],
        ),
      });
    }
    if (endDateTime != null) {
      result.addAll({
        'endDateTime': TravelTime.serialize(
          endDateTime,
          timeOffsets['endDateTime'],
        ),
      });
    }
    if (location != null) {
      result.addAll({'location': location});
    }

    return result;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'ActivityModel(title: $title, id: $id, tripId: $tripId, description: $description, startDateTime: $startDateTime, endDateTime: $endDateTime, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ActivityModel &&
        other.title == title &&
        other.id == id &&
        other.createdBy == createdBy &&
        other.isDeleted == isDeleted &&
        other.isLegacy == isLegacy &&
        other.contentRevision == contentRevision &&
        other.tripId == tripId &&
        other.description == description &&
        other.startDateTime == startDateTime &&
        other.endDateTime == endDateTime &&
        other.timeOffsets['startDateTime'] == timeOffsets['startDateTime'] &&
        other.timeOffsets['endDateTime'] == timeOffsets['endDateTime'] &&
        other.location == location;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        id.hashCode ^
        createdBy.hashCode ^
        isDeleted.hashCode ^
        isLegacy.hashCode ^
        contentRevision.hashCode ^
        tripId.hashCode ^
        description.hashCode ^
        startDateTime.hashCode ^
        endDateTime.hashCode ^
        timeOffsets['startDateTime'].hashCode ^
        timeOffsets['endDateTime'].hashCode ^
        location.hashCode;
  }
}
