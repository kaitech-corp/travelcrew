// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_NotificationModel _$$_NotificationModelFromJson(Map<String, dynamic> json) =>
    _$_NotificationModel(
      type: json['type'] as String,
      ownerID: json['ownerID'] as String,
      ispublic: json['ispublic'] as bool,
      timestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['timestamp'], const TimestampConverter().fromJson),
      message: json['message'] as String,
      documentID: json['documentID'] as String,
      displayName: json['displayName'] as String,
      fieldID: json['fieldID'] as String,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      uid: json['uid'] as String,
      ownerDisplayName: json['ownerDisplayName'] as String,
    );

Map<String, dynamic> _$$_NotificationModelToJson(
        _$_NotificationModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'ownerID': instance.ownerID,
      'ispublic': instance.ispublic,
      'timestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.timestamp, const TimestampConverter().toJson),
      'message': instance.message,
      'documentID': instance.documentID,
      'displayName': instance.displayName,
      'fieldID': instance.fieldID,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'uid': instance.uid,
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
