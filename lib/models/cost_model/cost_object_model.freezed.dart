// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cost_object_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CostObjectModel _$CostObjectModelFromJson(Map<String, dynamic> json) {
  return _CostObjectModel.fromJson(json);
}

/// @nodoc
mixin _$CostObjectModel {
  int get amountOwe => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get datePaid => throw _privateConstructorUsedError;
  String get itemDocID => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  bool get paid => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  String get tripDocID => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CostObjectModelCopyWith<CostObjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CostObjectModelCopyWith<$Res> {
  factory $CostObjectModelCopyWith(
          CostObjectModel value, $Res Function(CostObjectModel) then) =
      _$CostObjectModelCopyWithImpl<$Res, CostObjectModel>;
  @useResult
  $Res call(
      {int amountOwe,
      @TimestampConverter() DateTime? datePaid,
      String itemDocID,
      @TimestampConverter() DateTime? lastUpdated,
      bool paid,
      String uid,
      String tripDocID});
}

/// @nodoc
class _$CostObjectModelCopyWithImpl<$Res, $Val extends CostObjectModel>
    implements $CostObjectModelCopyWith<$Res> {
  _$CostObjectModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amountOwe = null,
    Object? datePaid = freezed,
    Object? itemDocID = null,
    Object? lastUpdated = freezed,
    Object? paid = null,
    Object? uid = null,
    Object? tripDocID = null,
  }) {
    return _then(_value.copyWith(
      amountOwe: null == amountOwe
          ? _value.amountOwe
          : amountOwe // ignore: cast_nullable_to_non_nullable
              as int,
      datePaid: freezed == datePaid
          ? _value.datePaid
          : datePaid // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      itemDocID: null == itemDocID
          ? _value.itemDocID
          : itemDocID // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paid: null == paid
          ? _value.paid
          : paid // ignore: cast_nullable_to_non_nullable
              as bool,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      tripDocID: null == tripDocID
          ? _value.tripDocID
          : tripDocID // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CostObjectModelCopyWith<$Res>
    implements $CostObjectModelCopyWith<$Res> {
  factory _$$_CostObjectModelCopyWith(
          _$_CostObjectModel value, $Res Function(_$_CostObjectModel) then) =
      __$$_CostObjectModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int amountOwe,
      @TimestampConverter() DateTime? datePaid,
      String itemDocID,
      @TimestampConverter() DateTime? lastUpdated,
      bool paid,
      String uid,
      String tripDocID});
}

/// @nodoc
class __$$_CostObjectModelCopyWithImpl<$Res>
    extends _$CostObjectModelCopyWithImpl<$Res, _$_CostObjectModel>
    implements _$$_CostObjectModelCopyWith<$Res> {
  __$$_CostObjectModelCopyWithImpl(
      _$_CostObjectModel _value, $Res Function(_$_CostObjectModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amountOwe = null,
    Object? datePaid = freezed,
    Object? itemDocID = null,
    Object? lastUpdated = freezed,
    Object? paid = null,
    Object? uid = null,
    Object? tripDocID = null,
  }) {
    return _then(_$_CostObjectModel(
      amountOwe: null == amountOwe
          ? _value.amountOwe
          : amountOwe // ignore: cast_nullable_to_non_nullable
              as int,
      datePaid: freezed == datePaid
          ? _value.datePaid
          : datePaid // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      itemDocID: null == itemDocID
          ? _value.itemDocID
          : itemDocID // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paid: null == paid
          ? _value.paid
          : paid // ignore: cast_nullable_to_non_nullable
              as bool,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      tripDocID: null == tripDocID
          ? _value.tripDocID
          : tripDocID // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CostObjectModel implements _CostObjectModel {
  const _$_CostObjectModel(
      {required this.amountOwe,
      @TimestampConverter() this.datePaid,
      required this.itemDocID,
      @TimestampConverter() this.lastUpdated,
      required this.paid,
      required this.uid,
      required this.tripDocID});

  factory _$_CostObjectModel.fromJson(Map<String, dynamic> json) =>
      _$$_CostObjectModelFromJson(json);

  @override
  final int amountOwe;
  @override
  @TimestampConverter()
  final DateTime? datePaid;
  @override
  final String itemDocID;
  @override
  @TimestampConverter()
  final DateTime? lastUpdated;
  @override
  final bool paid;
  @override
  final String uid;
  @override
  final String tripDocID;

  @override
  String toString() {
    return 'CostObjectModel(amountOwe: $amountOwe, datePaid: $datePaid, itemDocID: $itemDocID, lastUpdated: $lastUpdated, paid: $paid, uid: $uid, tripDocID: $tripDocID)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CostObjectModel &&
            (identical(other.amountOwe, amountOwe) ||
                other.amountOwe == amountOwe) &&
            (identical(other.datePaid, datePaid) ||
                other.datePaid == datePaid) &&
            (identical(other.itemDocID, itemDocID) ||
                other.itemDocID == itemDocID) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.paid, paid) || other.paid == paid) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.tripDocID, tripDocID) ||
                other.tripDocID == tripDocID));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, amountOwe, datePaid, itemDocID,
      lastUpdated, paid, uid, tripDocID);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CostObjectModelCopyWith<_$_CostObjectModel> get copyWith =>
      __$$_CostObjectModelCopyWithImpl<_$_CostObjectModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CostObjectModelToJson(
      this,
    );
  }
}

abstract class _CostObjectModel implements CostObjectModel {
  const factory _CostObjectModel(
      {required final int amountOwe,
      @TimestampConverter() final DateTime? datePaid,
      required final String itemDocID,
      @TimestampConverter() final DateTime? lastUpdated,
      required final bool paid,
      required final String uid,
      required final String tripDocID}) = _$_CostObjectModel;

  factory _CostObjectModel.fromJson(Map<String, dynamic> json) =
      _$_CostObjectModel.fromJson;

  @override
  int get amountOwe;
  @override
  @TimestampConverter()
  DateTime? get datePaid;
  @override
  String get itemDocID;
  @override
  @TimestampConverter()
  DateTime? get lastUpdated;
  @override
  bool get paid;
  @override
  String get uid;
  @override
  String get tripDocID;
  @override
  @JsonKey(ignore: true)
  _$$_CostObjectModelCopyWith<_$_CostObjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}
