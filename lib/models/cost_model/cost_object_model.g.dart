// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_object_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CostObjectModel _$$_CostObjectModelFromJson(Map<String, dynamic> json) =>
    _$_CostObjectModel(
      amountOwe: json['amountOwe'] as int,
      datePaid: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['datePaid'], const TimestampConverter().fromJson),
      itemDocID: json['itemDocID'] as String,
      lastUpdated: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastUpdated'], const TimestampConverter().fromJson),
      paid: json['paid'] as bool,
      uid: json['uid'] as String,
      tripDocID: json['tripDocID'] as String,
    );

Map<String, dynamic> _$$_CostObjectModelToJson(_$_CostObjectModel instance) =>
    <String, dynamic>{
      'amountOwe': instance.amountOwe,
      'datePaid': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.datePaid, const TimestampConverter().toJson),
      'itemDocID': instance.itemDocID,
      'lastUpdated': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastUpdated, const TimestampConverter().toJson),
      'paid': instance.paid,
      'uid': instance.uid,
      'tripDocID': instance.tripDocID,
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
