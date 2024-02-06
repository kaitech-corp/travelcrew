// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'feed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_FeedModel _$$_FeedModelFromJson(Map<String, dynamic> json) => _$_FeedModel(
      dateCreated: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['dateCreated'], const TimestampConverter().fromJson),
      docID: json['docID'] as String,
      message: json['message'] as String,
      tripID: json['tripID'] as String,
    );

Map<String, dynamic> _$$_FeedModelToJson(_$_FeedModel instance) =>
    <String, dynamic>{
      'dateCreated': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.dateCreated, const TimestampConverter().toJson),
      'docID': instance.docID,
      'message': instance.message,
      'tripID': instance.tripID,
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
