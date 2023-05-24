// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transportation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TransportationModel _$$_TransportationModelFromJson(
        Map<String, dynamic> json) =>
    _$_TransportationModel(
      mode: json['mode'] as String,
      airline: json['airline'] as String,
      airportCode: json['airportCode'] as String,
      canCarpool: json['canCarpool'] as bool,
      carpoolingWith: (json['carpoolingWith'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      comment: json['comment'] as String,
      departureDate: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['departureDate'], const TimestampConverter().fromJson),
      departureDateArrivalTime: json['departureDateArrivalTime'] as String,
      departureDateDepartTime: json['departureDateDepartTime'] as String,
      displayName: json['displayName'] as String,
      fieldID: json['fieldID'] as String,
      flightNumber: json['flightNumber'] as int,
      location: json['location'] as String,
      returnDateArrivalTime: json['returnDateArrivalTime'] as String,
      returnDateDepartTime: json['returnDateDepartTime'] as String,
      returnDate: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['returnDate'], const TimestampConverter().fromJson),
      uid: json['uid'] as String,
      tripDocID: json['tripDocID'] as String,
    );

Map<String, dynamic> _$$_TransportationModelToJson(
        _$_TransportationModel instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'airline': instance.airline,
      'airportCode': instance.airportCode,
      'canCarpool': instance.canCarpool,
      'carpoolingWith': instance.carpoolingWith,
      'comment': instance.comment,
      'departureDate': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.departureDate, const TimestampConverter().toJson),
      'departureDateArrivalTime': instance.departureDateArrivalTime,
      'departureDateDepartTime': instance.departureDateDepartTime,
      'displayName': instance.displayName,
      'fieldID': instance.fieldID,
      'flightNumber': instance.flightNumber,
      'location': instance.location,
      'returnDateArrivalTime': instance.returnDateArrivalTime,
      'returnDateDepartTime': instance.returnDateDepartTime,
      'returnDate': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.returnDate, const TimestampConverter().toJson),
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
