// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

FeedModel _$FeedModelFromJson(Map<String, dynamic> json) {
  return _FeedModel.fromJson(json);
}

/// @nodoc
mixin _$FeedModel {
  @TimestampConverter()
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  String get docID => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get tripID => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FeedModelCopyWith<FeedModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedModelCopyWith<$Res> {
  factory $FeedModelCopyWith(FeedModel value, $Res Function(FeedModel) then) =
      _$FeedModelCopyWithImpl<$Res, FeedModel>;
  @useResult
  $Res call(
      {@TimestampConverter() DateTime? dateCreated,
      String docID,
      String message,
      String tripID});
}

/// @nodoc
class _$FeedModelCopyWithImpl<$Res, $Val extends FeedModel>
    implements $FeedModelCopyWith<$Res> {
  _$FeedModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateCreated = freezed,
    Object? docID = null,
    Object? message = null,
    Object? tripID = null,
  }) {
    return _then(_value.copyWith(
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      docID: null == docID
          ? _value.docID
          : docID // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      tripID: null == tripID
          ? _value.tripID
          : tripID // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_FeedModelCopyWith<$Res> implements $FeedModelCopyWith<$Res> {
  factory _$$_FeedModelCopyWith(
          _$_FeedModel value, $Res Function(_$_FeedModel) then) =
      __$$_FeedModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@TimestampConverter() DateTime? dateCreated,
      String docID,
      String message,
      String tripID});
}

/// @nodoc
class __$$_FeedModelCopyWithImpl<$Res>
    extends _$FeedModelCopyWithImpl<$Res, _$_FeedModel>
    implements _$$_FeedModelCopyWith<$Res> {
  __$$_FeedModelCopyWithImpl(
      _$_FeedModel _value, $Res Function(_$_FeedModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateCreated = freezed,
    Object? docID = null,
    Object? message = null,
    Object? tripID = null,
  }) {
    return _then(_$_FeedModel(
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      docID: null == docID
          ? _value.docID
          : docID // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      tripID: null == tripID
          ? _value.tripID
          : tripID // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_FeedModel implements _FeedModel {
  const _$_FeedModel(
      {@TimestampConverter() this.dateCreated,
      required this.docID,
      required this.message,
      required this.tripID});

  factory _$_FeedModel.fromJson(Map<String, dynamic> json) =>
      _$$_FeedModelFromJson(json);

  @override
  @TimestampConverter()
  final DateTime? dateCreated;
  @override
  final String docID;
  @override
  final String message;
  @override
  final String tripID;

  @override
  String toString() {
    return 'FeedModel(dateCreated: $dateCreated, docID: $docID, message: $message, tripID: $tripID)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_FeedModel &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.docID, docID) || other.docID == docID) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.tripID, tripID) || other.tripID == tripID));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, dateCreated, docID, message, tripID);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_FeedModelCopyWith<_$_FeedModel> get copyWith =>
      __$$_FeedModelCopyWithImpl<_$_FeedModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FeedModelToJson(
      this,
    );
  }
}

abstract class _FeedModel implements FeedModel {
  const factory _FeedModel(
      {@TimestampConverter() final DateTime? dateCreated,
      required final String docID,
      required final String message,
      required final String tripID}) = _$_FeedModel;

  factory _FeedModel.fromJson(Map<String, dynamic> json) =
      _$_FeedModel.fromJson;

  @override
  @TimestampConverter()
  DateTime? get dateCreated;
  @override
  String get docID;
  @override
  String get message;
  @override
  String get tripID;
  @override
  @JsonKey(ignore: true)
  _$$_FeedModelCopyWith<_$_FeedModel> get copyWith =>
      throw _privateConstructorUsedError;
}
