// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SplitObjectImpl _$$SplitObjectImplFromJson(Map<String, dynamic> json) =>
    _$SplitObjectImpl(
      amountRemaining: (json['amountRemaining'] as num).toDouble(),
      dateCreated: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['dateCreated'], const TimestampConverter().fromJson),
      details: json['details'] as String,
      itemDescription: json['itemDescription'] as String,
      itemDocID: json['itemDocID'] as String,
      itemName: json['itemName'] as String,
      itemTotal: (json['itemTotal'] as num).toDouble(),
      itemType: json['itemType'] as String,
      lastUpdated: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastUpdated'], const TimestampConverter().fromJson),
      purchasedByUID: json['purchasedByUID'] as String,
      tripDocID: json['tripDocID'] as String,
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      userSelectedList: (json['userSelectedList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$SplitObjectImplToJson(_$SplitObjectImpl instance) =>
    <String, dynamic>{
      'amountRemaining': instance.amountRemaining,
      'dateCreated': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.dateCreated, const TimestampConverter().toJson),
      'details': instance.details,
      'itemDescription': instance.itemDescription,
      'itemDocID': instance.itemDocID,
      'itemName': instance.itemName,
      'itemTotal': instance.itemTotal,
      'itemType': instance.itemType,
      'lastUpdated': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastUpdated, const TimestampConverter().toJson),
      'purchasedByUID': instance.purchasedByUID,
      'tripDocID': instance.tripDocID,
      'users': instance.users,
      'userSelectedList': instance.userSelectedList,
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
