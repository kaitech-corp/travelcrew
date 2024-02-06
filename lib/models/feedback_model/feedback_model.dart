import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// required: associates our `feedback_model.dart` with the code generated by Freezed
part 'feedback_model.freezed.dart';
// optional: Since our feedbackModel class is serializable, we must add this line.
// But if feedbackModel was not serializable, we could skip it.
part 'feedback_model.g.dart';

///Model for database feedback

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
class FeedbackModel with _$FeedbackModel {
  const factory FeedbackModel(
      {required String fieldID,
      required String message,
      @TimestampConverter() DateTime? timestamp,
      required String uid}) = _FeedbackModel;

        factory FeedbackModel.fromJson(Map<String, Object?> json)
      => _$FeedbackModelFromJson(json);
}
