// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_NotificationModel _$$_NotificationModelFromJson(Map<String, dynamic> json) =>
    _$_NotificationModel(
      type: json['type'] as String,
      message: json['message'] as String,
      fieldID: json['fieldID'] as String,
      uid: json['uid'] as String,
      documentID: json['documentID'] as String?,
      ownerID: json['ownerID'] as String?,
      ispublic: json['ispublic'] as bool?,
      timestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['timestamp'], const TimestampConverter().fromJson),
      displayName: json['displayName'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      ownerDisplayName: json['ownerDisplayName'] as String?,
    );

Map<String, dynamic> _$$_NotificationModelToJson(
        _$_NotificationModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'fieldID': instance.fieldID,
      'uid': instance.uid,
      'documentID': instance.documentID,
      'ownerID': instance.ownerID,
      'ispublic': instance.ispublic,
      'timestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.timestamp, const TimestampConverter().toJson),
      'displayName': instance.displayName,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'ownerDisplayName': instance.ownerDisplayName,
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
