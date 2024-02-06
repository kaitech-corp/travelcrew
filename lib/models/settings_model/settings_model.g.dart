// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SettingsModel _$$_SettingsModelFromJson(Map<String, dynamic> json) =>
    _$_SettingsModel(
      isTripChatOn: json['isTripChatOn'] as bool?,
      isPushNotificationsOn: json['isPushNotificationsOn'] as bool?,
      isTripChangeOn: json['isTripChangeOn'] as bool?,
      isDirectMessagingOn: json['isDirectMessagingOn'] as bool?,
      lastUpdated: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastUpdated'], const TimestampConverter().fromJson),
    );

Map<String, dynamic> _$$_SettingsModelToJson(_$_SettingsModel instance) =>
    <String, dynamic>{
      'isTripChatOn': instance.isTripChatOn,
      'isPushNotificationsOn': instance.isPushNotificationsOn,
      'isTripChangeOn': instance.isTripChangeOn,
      'isDirectMessagingOn': instance.isDirectMessagingOn,
      'lastUpdated': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastUpdated, const TimestampConverter().toJson),
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
