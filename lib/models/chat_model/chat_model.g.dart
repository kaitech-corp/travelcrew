// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ChatModel _$$_ChatModelFromJson(Map<String, dynamic> json) => _$_ChatModel(
      timestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['timestamp'], const TimestampConverter().fromJson),
      fieldID: json['fieldID'] as String,
      displayName: json['displayName'] as String,
      message: json['message'] as String,
      uid: json['uid'] as String,
      tripDocID: json['tripDocID'] as String,
      status: Map<String, bool>.from(json['status'] as Map),
    );

Map<String, dynamic> _$$_ChatModelToJson(_$_ChatModel instance) =>
    <String, dynamic>{
      'timestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.timestamp, const TimestampConverter().toJson),
      'fieldID': instance.fieldID,
      'displayName': instance.displayName,
      'message': instance.message,
      'uid': instance.uid,
      'tripDocID': instance.tripDocID,
      'status': instance.status,
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
