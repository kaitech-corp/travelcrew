import 'dart:convert';

class ActivityModel {
  String title;
  String? id;
  String tripId;
  String description;
  List<String> likedBy;
  int likesCount = 0;
  DateTime? startDateTime;
  DateTime? endDateTime;
  String? location;
  ActivityModel({
    required this.likesCount,
    required this.title,
    this.id,
    this.likedBy = const [],
    required this.tripId,
    required this.description,
    this.startDateTime,
    this.endDateTime,
    this.location,
  });

  ActivityModel copyWith({
    String? title,
    String? id,
    String? tripId,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
  }) {
    return ActivityModel(
      title: title ?? this.title,
      id: id ?? this.id,
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
    result.addAll({'likedBy': likedBy});
    result.addAll({'likesCount': likesCount});
    result.addAll({'tripId': tripId});
    result.addAll({'description': description});
    if (startDateTime != null) {
      result.addAll({'startDateTime': startDateTime!.toIso8601String()});
    }
    if (endDateTime != null) {
      result.addAll({'endDateTime': endDateTime!.toIso8601String()});
    }
    if (location != null) {
      result.addAll({'location': location});
    }

    return result;
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      likesCount: map['likesCount']?.toInt() ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      title: map['title'] ?? '',
      id: map['id'] ?? '',
      tripId: map['tripId'] ?? '',
      description: map['description'] ?? '',
      startDateTime:
          map['startDateTime'] != null
              ? DateTime.parse(map['startDateTime'])
              : null,
      endDateTime:
          map['endDateTime'] != null
              ? DateTime.parse(map['endDateTime'])
              : null,
      location: map['location'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivityModel.fromJson(String source) =>
      ActivityModel.fromMap(json.decode(source));

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
        other.tripId == tripId &&
        other.description == description &&
        other.startDateTime == startDateTime &&
        other.endDateTime == endDateTime &&
        other.location == location;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        id.hashCode ^
        tripId.hashCode ^
        description.hashCode ^
        startDateTime.hashCode ^
        endDateTime.hashCode ^
        location.hashCode;
  }
}
