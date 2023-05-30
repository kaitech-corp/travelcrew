// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DMChatModel _$$_DMChatModelFromJson(Map<String, dynamic> json) =>
    _$_DMChatModel(
      timestamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['timestamp'], const TimestampConverter().fromJson),
      fieldID: json['fieldID'] as String,
      message: json['message'] as String,
      senderID: json['senderID'] as String,
      receiverID: json['receiverID'] as String,
      readBy:
          (json['readBy'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_DMChatModelToJson(_$_DMChatModel instance) =>
    <String, dynamic>{
      'timestamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.timestamp, const TimestampConverter().toJson),
      'fieldID': instance.fieldID,
      'message': instance.message,
      'senderID': instance.senderID,
      'receiverID': instance.receiverID,
      'readBy': instance.readBy,
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
