import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `split_model.dart` with the code generated by Freezed
part 'split_model.freezed.dart';
// optional: Since our ComparisonModel class is serializable, we must add this line.
// But if ComparisonModel was not serializable, we could skip it.
part 'split_model.g.dart';

///Model for database split

///Model for comparsion data
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp json) => json.toDate();

  @override
  Timestamp toJson(DateTime object) => Timestamp.fromDate(object);
}

class TimestampNullableConverter
    implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampNullableConverter();

  @override
  DateTime? fromJson(Timestamp? json) => json?.toDate();

  @override
  Timestamp? toJson(DateTime? object) =>
      object == null ? null : Timestamp.fromDate(object);
}

@freezed
class SplitObject with _$SplitObject {
  const factory SplitObject(
      {required int amountRemaining,
      @TimestampConverter() DateTime? dateCreated,
      required String details,
      required String itemDescription,
      required String itemDocID,
      required String itemName,
      required int itemTotal,
      required String itemType,
      @TimestampConverter() DateTime? lastUpdated,
      required String purchasedByUID,
      required String tripDocID,
      required List<String> users,
      required List<String> userSelectedList}) = _SplitObject;

        factory SplitObject.fromJson(Map<String, Object?> json)
      => _$SplitObjectFromJson(json);
}
