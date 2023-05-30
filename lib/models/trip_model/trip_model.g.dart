// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Trip _$$_TripFromJson(Map<String, dynamic> json) => _$_Trip(
      tripGeoPoint:
          GeoPointConverter.fromJson(json['tripGeoPoint'] as GeoPoint?),
      comment: json['comment'] as String?,
      dateCreatedTimeStamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['dateCreatedTimeStamp'], const TimestampConverter().fromJson),
      displayName: json['displayName'] as String?,
      favorite: (json['favorite'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      accessUsers: (json['accessUsers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      documentId: json['documentId'] as String,
      endDate: json['endDate'] as String?,
      endDateTimeStamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['endDateTimeStamp'], const TimestampConverter().fromJson),
      ispublic: json['ispublic'] as bool,
      tripName: json['tripName'] as String,
      location: json['location'] as String?,
      ownerID: json['ownerID'] as String,
      startDate: json['startDate'] as String?,
      startDateTimeStamp: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['startDateTimeStamp'], const TimestampConverter().fromJson),
      travelType: json['travelType'] as String?,
      urlToImage: json['urlToImage'] as String?,
    );

Map<String, dynamic> _$$_TripToJson(_$_Trip instance) => <String, dynamic>{
      'tripGeoPoint': GeoPointConverter.toJson(instance.tripGeoPoint),
      'comment': instance.comment,
      'dateCreatedTimeStamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.dateCreatedTimeStamp, const TimestampConverter().toJson),
      'displayName': instance.displayName,
      'favorite': instance.favorite,
      'accessUsers': instance.accessUsers,
      'documentId': instance.documentId,
      'endDate': instance.endDate,
      'endDateTimeStamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.endDateTimeStamp, const TimestampConverter().toJson),
      'ispublic': instance.ispublic,
      'tripName': instance.tripName,
      'location': instance.location,
      'ownerID': instance.ownerID,
      'startDate': instance.startDate,
      'startDateTimeStamp': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.startDateTimeStamp, const TimestampConverter().toJson),
      'travelType': instance.travelType,
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
