// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) {
  return _ActivityModel.fromJson(json);
}

/// @nodoc
mixin _$ActivityModel {
  String get endTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get endDateTimestamp => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get startDateTimestamp => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get dateTimestamp => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get fieldID => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get activityType => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  List<String> get voters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ActivityModelCopyWith<ActivityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityModelCopyWith<$Res> {
  factory $ActivityModelCopyWith(
          ActivityModel value, $Res Function(ActivityModel) then) =
      _$ActivityModelCopyWithImpl<$Res, ActivityModel>;
  @useResult
  $Res call(
      {String endTime,
      @TimestampConverter() DateTime? endDateTimestamp,
      @TimestampConverter() DateTime? startDateTimestamp,
      @TimestampConverter() DateTime? dateTimestamp,
      String startTime,
      String comment,
      String displayName,
      String fieldID,
      String link,
      String location,
      String activityType,
      String uid,
      List<String> voters});
}

/// @nodoc
class _$ActivityModelCopyWithImpl<$Res, $Val extends ActivityModel>
    implements $ActivityModelCopyWith<$Res> {
  _$ActivityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? endTime = null,
    Object? endDateTimestamp = freezed,
    Object? startDateTimestamp = freezed,
    Object? dateTimestamp = freezed,
    Object? startTime = null,
    Object? comment = null,
    Object? displayName = null,
    Object? fieldID = null,
    Object? link = null,
    Object? location = null,
    Object? activityType = null,
    Object? uid = null,
    Object? voters = null,
  }) {
    return _then(_value.copyWith(
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      endDateTimestamp: freezed == endDateTimestamp
          ? _value.endDateTimestamp
          : endDateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startDateTimestamp: freezed == startDateTimestamp
          ? _value.startDateTimestamp
          : startDateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateTimestamp: freezed == dateTimestamp
          ? _value.dateTimestamp
          : dateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
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
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
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
abstract class _$$_ActivityModelCopyWith<$Res>
    implements $ActivityModelCopyWith<$Res> {
  factory _$$_ActivityModelCopyWith(
          _$_ActivityModel value, $Res Function(_$_ActivityModel) then) =
      __$$_ActivityModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String endTime,
      @TimestampConverter() DateTime? endDateTimestamp,
      @TimestampConverter() DateTime? startDateTimestamp,
      @TimestampConverter() DateTime? dateTimestamp,
      String startTime,
      String comment,
      String displayName,
      String fieldID,
      String link,
      String location,
      String activityType,
      String uid,
      List<String> voters});
}

/// @nodoc
class __$$_ActivityModelCopyWithImpl<$Res>
    extends _$ActivityModelCopyWithImpl<$Res, _$_ActivityModel>
    implements _$$_ActivityModelCopyWith<$Res> {
  __$$_ActivityModelCopyWithImpl(
      _$_ActivityModel _value, $Res Function(_$_ActivityModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? endTime = null,
    Object? endDateTimestamp = freezed,
    Object? startDateTimestamp = freezed,
    Object? dateTimestamp = freezed,
    Object? startTime = null,
    Object? comment = null,
    Object? displayName = null,
    Object? fieldID = null,
    Object? link = null,
    Object? location = null,
    Object? activityType = null,
    Object? uid = null,
    Object? voters = null,
  }) {
    return _then(_$_ActivityModel(
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      endDateTimestamp: freezed == endDateTimestamp
          ? _value.endDateTimestamp
          : endDateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startDateTimestamp: freezed == startDateTimestamp
          ? _value.startDateTimestamp
          : startDateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateTimestamp: freezed == dateTimestamp
          ? _value.dateTimestamp
          : dateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
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
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
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
class _$_ActivityModel implements _ActivityModel {
  const _$_ActivityModel(
      {required this.endTime,
      @TimestampConverter() this.endDateTimestamp,
      @TimestampConverter() this.startDateTimestamp,
      @TimestampConverter() this.dateTimestamp,
      required this.startTime,
      required this.comment,
      required this.displayName,
      required this.fieldID,
      required this.link,
      required this.location,
      required this.activityType,
      required this.uid,
      required final List<String> voters})
      : _voters = voters;

  factory _$_ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$$_ActivityModelFromJson(json);

  @override
  final String endTime;
  @override
  @TimestampConverter()
  final DateTime? endDateTimestamp;
  @override
  @TimestampConverter()
  final DateTime? startDateTimestamp;
  @override
  @TimestampConverter()
  final DateTime? dateTimestamp;
  @override
  final String startTime;
  @override
  final String comment;
  @override
  final String displayName;
  @override
  final String fieldID;
  @override
  final String link;
  @override
  final String location;
  @override
  final String activityType;
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
    return 'ActivityModel(endTime: $endTime, endDateTimestamp: $endDateTimestamp, startDateTimestamp: $startDateTimestamp, dateTimestamp: $dateTimestamp, startTime: $startTime, comment: $comment, displayName: $displayName, fieldID: $fieldID, link: $link, location: $location, activityType: $activityType, uid: $uid, voters: $voters)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ActivityModel &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.endDateTimestamp, endDateTimestamp) ||
                other.endDateTimestamp == endDateTimestamp) &&
            (identical(other.startDateTimestamp, startDateTimestamp) ||
                other.startDateTimestamp == startDateTimestamp) &&
            (identical(other.dateTimestamp, dateTimestamp) ||
                other.dateTimestamp == dateTimestamp) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.fieldID, fieldID) || other.fieldID == fieldID) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            const DeepCollectionEquality().equals(other._voters, _voters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      endTime,
      endDateTimestamp,
      startDateTimestamp,
      dateTimestamp,
      startTime,
      comment,
      displayName,
      fieldID,
      link,
      location,
      activityType,
      uid,
      const DeepCollectionEquality().hash(_voters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ActivityModelCopyWith<_$_ActivityModel> get copyWith =>
      __$$_ActivityModelCopyWithImpl<_$_ActivityModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ActivityModelToJson(
      this,
    );
  }
}

abstract class _ActivityModel implements ActivityModel {
  const factory _ActivityModel(
      {required final String endTime,
      @TimestampConverter() final DateTime? endDateTimestamp,
      @TimestampConverter() final DateTime? startDateTimestamp,
      @TimestampConverter() final DateTime? dateTimestamp,
      required final String startTime,
      required final String comment,
      required final String displayName,
      required final String fieldID,
      required final String link,
      required final String location,
      required final String activityType,
      required final String uid,
      required final List<String> voters}) = _$_ActivityModel;

  factory _ActivityModel.fromJson(Map<String, dynamic> json) =
      _$_ActivityModel.fromJson;

  @override
  String get endTime;
  @override
  @TimestampConverter()
  DateTime? get endDateTimestamp;
  @override
  @TimestampConverter()
  DateTime? get startDateTimestamp;
  @override
  @TimestampConverter()
  DateTime? get dateTimestamp;
  @override
  String get startTime;
  @override
  String get comment;
  @override
  String get displayName;
  @override
  String get fieldID;
  @override
  String get link;
  @override
  String get location;
  @override
  String get activityType;
  @override
  String get uid;
  @override
  List<String> get voters;
  @override
  @JsonKey(ignore: true)
  _$$_ActivityModelCopyWith<_$_ActivityModel> get copyWith =>
      throw _privateConstructorUsedError;
}
