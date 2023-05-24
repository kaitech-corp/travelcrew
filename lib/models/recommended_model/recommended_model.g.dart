// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommended_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_RecommendedContentModel _$$_RecommendedContentModelFromJson(
        Map<String, dynamic> json) =>
    _$_RecommendedContentModel(
      name: json['name'] as String,
      clicks: json['clicks'] as int,
      dateCreated: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['dateCreated'], const TimestampConverter().fromJson),
      docID: json['docID'] as String,
      urlToImage: (json['urlToImage'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$_RecommendedContentModelToJson(
        _$_RecommendedContentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'clicks': instance.clicks,
      'dateCreated': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.dateCreated, const TimestampConverter().toJson),
      'docID': instance.docID,
      'urlToImage': instance.urlToImage,
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
