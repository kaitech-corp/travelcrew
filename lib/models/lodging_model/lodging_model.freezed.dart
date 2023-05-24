// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lodging_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LodgingModel _$LodgingModelFromJson(Map<String, dynamic> json) {
  return _LodgingModel.fromJson(json);
}

/// @nodoc
mixin _$LodgingModel {
  String get endTime => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get startDateTimestamp => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endDateTimestamp => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get fieldID => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  String get lodgingType => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  List<String> get voters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LodgingModelCopyWith<LodgingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LodgingModelCopyWith<$Res> {
  factory $LodgingModelCopyWith(
          LodgingModel value, $Res Function(LodgingModel) then) =
      _$LodgingModelCopyWithImpl<$Res, LodgingModel>;
  @useResult
  $Res call(
      {String endTime,
      String startTime,
      @TimestampConverter() DateTime? startDateTimestamp,
      @TimestampConverter() DateTime? endDateTimestamp,
      String location,
      String comment,
      String displayName,
      String fieldID,
      String link,
      String lodgingType,
      String uid,
      List<String> voters});
}

/// @nodoc
class _$LodgingModelCopyWithImpl<$Res, $Val extends LodgingModel>
    implements $LodgingModelCopyWith<$Res> {
  _$LodgingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? endTime = null,
    Object? startTime = null,
    Object? startDateTimestamp = freezed,
    Object? endDateTimestamp = freezed,
    Object? location = null,
    Object? comment = null,
    Object? displayName = null,
    Object? fieldID = null,
    Object? link = null,
    Object? lodgingType = null,
    Object? uid = null,
    Object? voters = null,
  }) {
    return _then(_value.copyWith(
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      startDateTimestamp: freezed == startDateTimestamp
          ? _value.startDateTimestamp
          : startDateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDateTimestamp: freezed == endDateTimestamp
          ? _value.endDateTimestamp
          : endDateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      fieldID: null == fieldID
          ? _value.fieldID
          : fieldID // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      lodgingType: null == lodgingType
          ? _value.lodgingType
          : lodgingType // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      voters: null == voters
          ? _value.voters
          : voters // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LodgingModelCopyWith<$Res>
    implements $LodgingModelCopyWith<$Res> {
  factory _$$_LodgingModelCopyWith(
          _$_LodgingModel value, $Res Function(_$_LodgingModel) then) =
      __$$_LodgingModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String endTime,
      String startTime,
      @TimestampConverter() DateTime? startDateTimestamp,
      @TimestampConverter() DateTime? endDateTimestamp,
      String location,
      String comment,
      String displayName,
      String fieldID,
      String link,
      String lodgingType,
      String uid,
      List<String> voters});
}

/// @nodoc
class __$$_LodgingModelCopyWithImpl<$Res>
    extends _$LodgingModelCopyWithImpl<$Res, _$_LodgingModel>
    implements _$$_LodgingModelCopyWith<$Res> {
  __$$_LodgingModelCopyWithImpl(
      _$_LodgingModel _value, $Res Function(_$_LodgingModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? endTime = null,
    Object? startTime = null,
    Object? startDateTimestamp = freezed,
    Object? endDateTimestamp = freezed,
    Object? location = null,
    Object? comment = null,
    Object? displayName = null,
    Object? fieldID = null,
    Object? link = null,
    Object? lodgingType = null,
    Object? uid = null,
    Object? voters = null,
  }) {
    return _then(_$_LodgingModel(
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      startDateTimestamp: freezed == startDateTimestamp
          ? _value.startDateTimestamp
          : startDateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDateTimestamp: freezed == endDateTimestamp
          ? _value.endDateTimestamp
          : endDateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      fieldID: null == fieldID
          ? _value.fieldID
          : fieldID // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      lodgingType: null == lodgingType
          ? _value.lodgingType
          : lodgingType // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      voters: null == voters
          ? _value._voters
          : voters // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LodgingModel implements _LodgingModel {
  const _$_LodgingModel(
      {required this.endTime,
      required this.startTime,
      @TimestampConverter() this.startDateTimestamp,
      @TimestampConverter() this.endDateTimestamp,
      required this.location,
      required this.comment,
      required this.displayName,
      required this.fieldID,
      required this.link,
      required this.lodgingType,
      required this.uid,
      required final List<String> voters})
      : _voters = voters;

  factory _$_LodgingModel.fromJson(Map<String, dynamic> json) =>
      _$$_LodgingModelFromJson(json);

  @override
  final String endTime;
  @override
  final String startTime;
  @override
  @TimestampConverter()
  final DateTime? startDateTimestamp;
  @override
  @TimestampConverter()
  final DateTime? endDateTimestamp;
  @override
  final String location;
  @override
  final String comment;
  @override
  final String displayName;
  @override
  final String fieldID;
  @override
  final String link;
  @override
  final String lodgingType;
  @override
  final String uid;
  final List<String> _voters;
  @override
  List<String> get voters {
    if (_voters is EqualUnmodifiableListView) return _voters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_voters);
  }

  @override
  String toString() {
    return 'LodgingModel(endTime: $endTime, startTime: $startTime, startDateTimestamp: $startDateTimestamp, endDateTimestamp: $endDateTimestamp, location: $location, comment: $comment, displayName: $displayName, fieldID: $fieldID, link: $link, lodgingType: $lodgingType, uid: $uid, voters: $voters)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LodgingModel &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.startDateTimestamp, startDateTimestamp) ||
                other.startDateTimestamp == startDateTimestamp) &&
            (identical(other.endDateTimestamp, endDateTimestamp) ||
                other.endDateTimestamp == endDateTimestamp) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.fieldID, fieldID) || other.fieldID == fieldID) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.lodgingType, lodgingType) ||
                other.lodgingType == lodgingType) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            const DeepCollectionEquality().equals(other._voters, _voters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      endTime,
      startTime,
      startDateTimestamp,
      endDateTimestamp,
      location,
      comment,
      displayName,
      fieldID,
      link,
      lodgingType,
      uid,
      const DeepCollectionEquality().hash(_voters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LodgingModelCopyWith<_$_LodgingModel> get copyWith =>
      __$$_LodgingModelCopyWithImpl<_$_LodgingModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LodgingModelToJson(
      this,
    );
  }
}

abstract class _LodgingModel implements LodgingModel {
  const factory _LodgingModel(
      {required final String endTime,
      required final String startTime,
      @TimestampConverter() final DateTime? startDateTimestamp,
      @TimestampConverter() final DateTime? endDateTimestamp,
      required final String location,
      required final String comment,
      required final String displayName,
      required final String fieldID,
      required final String link,
      required final String lodgingType,
      required final String uid,
      required final List<String> voters}) = _$_LodgingModel;

  factory _LodgingModel.fromJson(Map<String, dynamic> json) =
      _$_LodgingModel.fromJson;

  @override
  String get endTime;
  @override
  String get startTime;
  @override
  @TimestampConverter()
  DateTime? get startDateTimestamp;
  @override
  @TimestampConverter()
  DateTime? get endDateTimestamp;
  @override
  String get location;
  @override
  String get comment;
  @override
  String get displayName;
  @override
  String get fieldID;
  @override
  String get link;
  @override
  String get lodgingType;
  @override
  String get uid;
  @override
  List<String> get voters;
  @override
  @JsonKey(ignore: true)
  _$$_LodgingModelCopyWith<_$_LodgingModel> get copyWith =>
      throw _privateConstructorUsedError;
}
