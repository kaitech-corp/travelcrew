import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `location_model.dart` with the code generated by Freezed
part 'location_model.freezed.dart';
// optional: Since our locationModel class is serializable, we must add this line.
// But if locationModel was not serializable, we could skip it.
part 'location_model.g.dart';

///Model for database location
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp json) => json.toDate();

  @override
  Timestamp toJson(DateTime object) => Timestamp.fromDate(object);
}

class TimestampNullableConverter implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampNullableConverter();

  @override
  DateTime? fromJson(Timestamp? json) => json?.toDate();

  @override
  Timestamp? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}
@freezed
class LocationModel with _$LocationModel {
  const factory LocationModel(
      {String? city,
      String? country,
      String? documentID,
      String? geoPoint,
      @TimestampConverter() DateTime? timestamp,
      String? uid,
      String? zipcode}) = _LocationModel;

        factory LocationModel.fromJson(Map<String, Object?> json)
      => _$LocationModelFromJson(json);
}
