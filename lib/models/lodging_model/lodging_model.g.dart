// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names, always_specify_types

part of 'lodging_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LodgingModel _$$_LodgingModelFromJson(Map<String, dynamic> json) =>
    _$_LodgingModel(
      endTime: json['endTime'] as String,
      startTime: json['startTime'] as String,
      startDateTimestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['startDateTimestamp'], const TimestampConverter().fromJson),
      endDateTimestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['endDateTimestamp'], const TimestampConverter().fromJson),
      location: json['location'] as String,
      comment: json['comment'] as String,
      displayName: json['displayName'] as String,
      fieldID: json['fieldID'] as String,
      link: json['link'] as String,
      lodgingType: json['lodgingType'] as String,
      uid: json['uid'] as String,
      voters:
          (json['voters'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_LodgingModelToJson(_$_LodgingModel instance) =>
    <String, dynamic>{
      'endTime': instance.endTime,
      'startTime': instance.startTime,
      'startDateTimestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.startDateTimestamp, const TimestampConverter().toJson),
      'endDateTimestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.endDateTimestamp, const TimestampConverter().toJson),
      'location': instance.location,
      'comment': instance.comment,
      'displayName': instance.displayName,
      'fieldID': instance.fieldID,
      'link': instance.link,
      'lodgingType': instance.lodgingType,
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
