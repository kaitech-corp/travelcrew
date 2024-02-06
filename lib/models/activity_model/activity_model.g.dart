// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names, always_specify_types

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ActivityModel _$$_ActivityModelFromJson(Map<String, dynamic> json) =>
    _$_ActivityModel(
      endTime: json['endTime'] as String,
      endDateTimestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['endDateTimestamp'], const TimestampConverter().fromJson),
      startDateTimestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['startDateTimestamp'], const TimestampConverter().fromJson),
      dateTimestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['dateTimestamp'], const TimestampConverter().fromJson),
      startTime: json['startTime'] as String,
      comment: json['comment'] as String,
      displayName: json['displayName'] as String,
      fieldID: json['fieldID'] as String,
      link: json['link'] as String,
      location: json['location'] as String,
      activityType: json['activityType'] as String,
      uid: json['uid'] as String,
      voters:
          (json['voters'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_ActivityModelToJson(_$_ActivityModel instance) =>
    <String, dynamic>{
      'endTime': instance.endTime,
      'endDateTimestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.endDateTimestamp, const TimestampConverter().toJson),
      'startDateTimestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.startDateTimestamp, const TimestampConverter().toJson),
      'dateTimestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.dateTimestamp, const TimestampConverter().toJson),
      'startTime': instance.startTime,
      'comment': instance.comment,
      'displayName': instance.displayName,
      'fieldID': instance.fieldID,
      'link': instance.link,
      'location': instance.location,
      'activityType': instance.activityType,
      'uid': instance.uid,
      'voters': instance.voters,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
