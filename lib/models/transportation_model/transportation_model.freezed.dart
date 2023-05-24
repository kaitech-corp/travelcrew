// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transportation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TransportationModel _$TransportationModelFromJson(Map<String, dynamic> json) {
  return _TransportationModel.fromJson(json);
}

/// @nodoc
mixin _$TransportationModel {
  String get mode => throw _privateConstructorUsedError;
  String get airline => throw _privateConstructorUsedError;
  String get airportCode => throw _privateConstructorUsedError;
  bool get canCarpool => throw _privateConstructorUsedError;
  List<String> get carpoolingWith => throw _privateConstructorUsedError;
  String get comment => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get departureDate => throw _privateConstructorUsedError;
  String get departureDateArrivalTime => throw _privateConstructorUsedError;
  String get departureDateDepartTime => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get fieldID => throw _privateConstructorUsedError;
  int get flightNumber => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get returnDateArrivalTime => throw _privateConstructorUsedError;
  String get returnDateDepartTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get returnDate => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  String get tripDocID => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransportationModelCopyWith<TransportationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransportationModelCopyWith<$Res> {
  factory $TransportationModelCopyWith(
          TransportationModel value, $Res Function(TransportationModel) then) =
      _$TransportationModelCopyWithImpl<$Res, TransportationModel>;
  @useResult
  $Res call(
      {String mode,
      String airline,
      String airportCode,
      bool canCarpool,
      List<String> carpoolingWith,
      String comment,
      @TimestampConverter() DateTime? departureDate,
      String departureDateArrivalTime,
      String departureDateDepartTime,
      String displayName,
      String fieldID,
      int flightNumber,
      String location,
      String returnDateArrivalTime,
      String returnDateDepartTime,
      @TimestampConverter() DateTime? returnDate,
      String uid,
      String tripDocID});
}

/// @nodoc
class _$TransportationModelCopyWithImpl<$Res, $Val extends TransportationModel>
    implements $TransportationModelCopyWith<$Res> {
  _$TransportationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? airline = null,
    Object? airportCode = null,
    Object? canCarpool = null,
    Object? carpoolingWith = null,
    Object? comment = null,
    Object? departureDate = freezed,
    Object? departureDateArrivalTime = null,
    Object? departureDateDepartTime = null,
    Object? displayName = null,
    Object? fieldID = null,
    Object? flightNumber = null,
    Object? location = null,
    Object? returnDateArrivalTime = null,
    Object? returnDateDepartTime = null,
    Object? returnDate = freezed,
    Object? uid = null,
    Object? tripDocID = null,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      airline: null == airline
          ? _value.airline
          : airline // ignore: cast_nullable_to_non_nullable
              as String,
      airportCode: null == airportCode
          ? _value.airportCode
          : airportCode // ignore: cast_nullable_to_non_nullable
              as String,
      canCarpool: null == canCarpool
          ? _value.canCarpool
          : canCarpool // ignore: cast_nullable_to_non_nullable
              as bool,
      carpoolingWith: null == carpoolingWith
          ? _value.carpoolingWith
          : carpoolingWith // ignore: cast_nullable_to_non_nullable
              as List<String>,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      departureDate: freezed == departureDate
          ? _value.departureDate
          : departureDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      departureDateArrivalTime: null == departureDateArrivalTime
          ? _value.departureDateArrivalTime
          : departureDateArrivalTime // ignore: cast_nullable_to_non_nullable
              as String,
      departureDateDepartTime: null == departureDateDepartTime
          ? _value.departureDateDepartTime
          : departureDateDepartTime // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      fieldID: null == fieldID
          ? _value.fieldID
          : fieldID // ignore: cast_nullable_to_non_nullable
              as String,
      flightNumber: null == flightNumber
          ? _value.flightNumber
          : flightNumber // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      returnDateArrivalTime: null == returnDateArrivalTime
          ? _value.returnDateArrivalTime
          : returnDateArrivalTime // ignore: cast_nullable_to_non_nullable
              as String,
      returnDateDepartTime: null == returnDateDepartTime
          ? _value.returnDateDepartTime
          : returnDateDepartTime // ignore: cast_nullable_to_non_nullable
              as String,
      returnDate: freezed == returnDate
          ? _value.returnDate
          : returnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$_TransportationModelCopyWith<$Res>
    implements $TransportationModelCopyWith<$Res> {
  factory _$$_TransportationModelCopyWith(_$_TransportationModel value,
          $Res Function(_$_TransportationModel) then) =
      __$$_TransportationModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String mode,
      String airline,
      String airportCode,
      bool canCarpool,
      List<String> carpoolingWith,
      String comment,
      @TimestampConverter() DateTime? departureDate,
      String departureDateArrivalTime,
      String departureDateDepartTime,
      String displayName,
      String fieldID,
      int flightNumber,
      String location,
      String returnDateArrivalTime,
      String returnDateDepartTime,
      @TimestampConverter() DateTime? returnDate,
      String uid,
      String tripDocID});
}

/// @nodoc
class __$$_TransportationModelCopyWithImpl<$Res>
    extends _$TransportationModelCopyWithImpl<$Res, _$_TransportationModel>
    implements _$$_TransportationModelCopyWith<$Res> {
  __$$_TransportationModelCopyWithImpl(_$_TransportationModel _value,
      $Res Function(_$_TransportationModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? airline = null,
    Object? airportCode = null,
    Object? canCarpool = null,
    Object? carpoolingWith = null,
    Object? comment = null,
    Object? departureDate = freezed,
    Object? departureDateArrivalTime = null,
    Object? departureDateDepartTime = null,
    Object? displayName = null,
    Object? fieldID = null,
    Object? flightNumber = null,
    Object? location = null,
    Object? returnDateArrivalTime = null,
    Object? returnDateDepartTime = null,
    Object? returnDate = freezed,
    Object? uid = null,
    Object? tripDocID = null,
  }) {
    return _then(_$_TransportationModel(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      airline: null == airline
          ? _value.airline
          : airline // ignore: cast_nullable_to_non_nullable
              as String,
      airportCode: null == airportCode
          ? _value.airportCode
          : airportCode // ignore: cast_nullable_to_non_nullable
              as String,
      canCarpool: null == canCarpool
          ? _value.canCarpool
          : canCarpool // ignore: cast_nullable_to_non_nullable
              as bool,
      carpoolingWith: null == carpoolingWith
          ? _value._carpoolingWith
          : carpoolingWith // ignore: cast_nullable_to_non_nullable
              as List<String>,
      comment: null == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String,
      departureDate: freezed == departureDate
          ? _value.departureDate
          : departureDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      departureDateArrivalTime: null == departureDateArrivalTime
          ? _value.departureDateArrivalTime
          : departureDateArrivalTime // ignore: cast_nullable_to_non_nullable
              as String,
      departureDateDepartTime: null == departureDateDepartTime
          ? _value.departureDateDepartTime
          : departureDateDepartTime // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      fieldID: null == fieldID
          ? _value.fieldID
          : fieldID // ignore: cast_nullable_to_non_nullable
              as String,
      flightNumber: null == flightNumber
          ? _value.flightNumber
          : flightNumber // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      returnDateArrivalTime: null == returnDateArrivalTime
          ? _value.returnDateArrivalTime
          : returnDateArrivalTime // ignore: cast_nullable_to_non_nullable
              as String,
      returnDateDepartTime: null == returnDateDepartTime
          ? _value.returnDateDepartTime
          : returnDateDepartTime // ignore: cast_nullable_to_non_nullable
              as String,
      returnDate: freezed == returnDate
          ? _value.returnDate
          : returnDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$_TransportationModel implements _TransportationModel {
  const _$_TransportationModel(
      {required this.mode,
      required this.airline,
      required this.airportCode,
      required this.canCarpool,
      required final List<String> carpoolingWith,
      required this.comment,
      @TimestampConverter() this.departureDate,
      required this.departureDateArrivalTime,
      required this.departureDateDepartTime,
      required this.displayName,
      required this.fieldID,
      required this.flightNumber,
      required this.location,
      required this.returnDateArrivalTime,
      required this.returnDateDepartTime,
      @TimestampConverter() this.returnDate,
      required this.uid,
      required this.tripDocID})
      : _carpoolingWith = carpoolingWith;

  factory _$_TransportationModel.fromJson(Map<String, dynamic> json) =>
      _$$_TransportationModelFromJson(json);

  @override
  final String mode;
  @override
  final String airline;
  @override
  final String airportCode;
  @override
  final bool canCarpool;
  final List<String> _carpoolingWith;
  @override
  List<String> get carpoolingWith {
    if (_carpoolingWith is EqualUnmodifiableListView) return _carpoolingWith;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_carpoolingWith);
  }

  @override
  final String comment;
  @override
  @TimestampConverter()
  final DateTime? departureDate;
  @override
  final String departureDateArrivalTime;
  @override
  final String departureDateDepartTime;
  @override
  final String displayName;
  @override
  final String fieldID;
  @override
  final int flightNumber;
  @override
  final String location;
  @override
  final String returnDateArrivalTime;
  @override
  final String returnDateDepartTime;
  @override
  @TimestampConverter()
  final DateTime? returnDate;
  @override
  final String uid;
  @override
  final String tripDocID;

  @override
  String toString() {
    return 'TransportationModel(mode: $mode, airline: $airline, airportCode: $airportCode, canCarpool: $canCarpool, carpoolingWith: $carpoolingWith, comment: $comment, departureDate: $departureDate, departureDateArrivalTime: $departureDateArrivalTime, departureDateDepartTime: $departureDateDepartTime, displayName: $displayName, fieldID: $fieldID, flightNumber: $flightNumber, location: $location, returnDateArrivalTime: $returnDateArrivalTime, returnDateDepartTime: $returnDateDepartTime, returnDate: $returnDate, uid: $uid, tripDocID: $tripDocID)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TransportationModel &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.airline, airline) || other.airline == airline) &&
            (identical(other.airportCode, airportCode) ||
                other.airportCode == airportCode) &&
            (identical(other.canCarpool, canCarpool) ||
                other.canCarpool == canCarpool) &&
            const DeepCollectionEquality()
                .equals(other._carpoolingWith, _carpoolingWith) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.departureDate, departureDate) ||
                other.departureDate == departureDate) &&
            (identical(
                    other.departureDateArrivalTime, departureDateArrivalTime) ||
                other.departureDateArrivalTime == departureDateArrivalTime) &&
            (identical(
                    other.departureDateDepartTime, departureDateDepartTime) ||
                other.departureDateDepartTime == departureDateDepartTime) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.fieldID, fieldID) || other.fieldID == fieldID) &&
            (identical(other.flightNumber, flightNumber) ||
                other.flightNumber == flightNumber) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.returnDateArrivalTime, returnDateArrivalTime) ||
                other.returnDateArrivalTime == returnDateArrivalTime) &&
            (identical(other.returnDateDepartTime, returnDateDepartTime) ||
                other.returnDateDepartTime == returnDateDepartTime) &&
            (identical(other.returnDate, returnDate) ||
                other.returnDate == returnDate) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.tripDocID, tripDocID) ||
                other.tripDocID == tripDocID));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mode,
      airline,
      airportCode,
      canCarpool,
      const DeepCollectionEquality().hash(_carpoolingWith),
      comment,
      departureDate,
      departureDateArrivalTime,
      departureDateDepartTime,
      displayName,
      fieldID,
      flightNumber,
      location,
      returnDateArrivalTime,
      returnDateDepartTime,
      returnDate,
      uid,
      tripDocID);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TransportationModelCopyWith<_$_TransportationModel> get copyWith =>
      __$$_TransportationModelCopyWithImpl<_$_TransportationModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TransportationModelToJson(
      this,
    );
  }
}

abstract class _TransportationModel implements TransportationModel {
  const factory _TransportationModel(
      {required final String mode,
      required final String airline,
      required final String airportCode,
      required final bool canCarpool,
      required final List<String> carpoolingWith,
      required final String comment,
      @TimestampConverter() final DateTime? departureDate,
      required final String departureDateArrivalTime,
      required final String departureDateDepartTime,
      required final String displayName,
      required final String fieldID,
      required final int flightNumber,
      required final String location,
      required final String returnDateArrivalTime,
      required final String returnDateDepartTime,
      @TimestampConverter() final DateTime? returnDate,
      required final String uid,
      required final String tripDocID}) = _$_TransportationModel;

  factory _TransportationModel.fromJson(Map<String, dynamic> json) =
      _$_TransportationModel.fromJson;

  @override
  String get mode;
  @override
  String get airline;
  @override
  String get airportCode;
  @override
  bool get canCarpool;
  @override
  List<String> get carpoolingWith;
  @override
  String get comment;
  @override
  @TimestampConverter()
  DateTime? get departureDate;
  @override
  String get departureDateArrivalTime;
  @override
  String get departureDateDepartTime;
  @override
  String get displayName;
  @override
  String get fieldID;
  @override
  int get flightNumber;
  @override
  String get location;
  @override
  String get returnDateArrivalTime;
  @override
  String get returnDateDepartTime;
  @override
  @TimestampConverter()
  DateTime? get returnDate;
  @override
  String get uid;
  @override
  String get tripDocID;
  @override
  @JsonKey(ignore: true)
  _$$_TransportationModelCopyWith<_$_TransportationModel> get copyWith =>
      throw _privateConstructorUsedError;
}
