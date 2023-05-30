// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dm_chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DMChatModel _$DMChatModelFromJson(Map<String, dynamic> json) {
  return _DMChatModel.fromJson(json);
}

/// @nodoc
mixin _$DMChatModel {
  @TimestampConverter()
  DateTime? get timestamp => throw _privateConstructorUsedError;
  String get fieldID => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get senderID => throw _privateConstructorUsedError;
  String get receiverID => throw _privateConstructorUsedError;
  List<String> get readBy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DMChatModelCopyWith<DMChatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DMChatModelCopyWith<$Res> {
  factory $DMChatModelCopyWith(
          DMChatModel value, $Res Function(DMChatModel) then) =
      _$DMChatModelCopyWithImpl<$Res, DMChatModel>;
  @useResult
  $Res call(
      {@TimestampConverter() DateTime? timestamp,
      String fieldID,
      String message,
      String senderID,
      String receiverID,
      List<String> readBy});
}

/// @nodoc
class _$DMChatModelCopyWithImpl<$Res, $Val extends DMChatModel>
    implements $DMChatModelCopyWith<$Res> {
  _$DMChatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = freezed,
    Object? fieldID = null,
    Object? message = null,
    Object? senderID = null,
    Object? receiverID = null,
    Object? readBy = null,
  }) {
    return _then(_value.copyWith(
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fieldID: null == fieldID
          ? _value.fieldID
          : fieldID // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      senderID: null == senderID
          ? _value.senderID
          : senderID // ignore: cast_nullable_to_non_nullable
              as String,
      receiverID: null == receiverID
          ? _value.receiverID
          : receiverID // ignore: cast_nullable_to_non_nullable
              as String,
      readBy: null == readBy
          ? _value.readBy
          : readBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DMChatModelCopyWith<$Res>
    implements $DMChatModelCopyWith<$Res> {
  factory _$$_DMChatModelCopyWith(
          _$_DMChatModel value, $Res Function(_$_DMChatModel) then) =
      __$$_DMChatModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@TimestampConverter() DateTime? timestamp,
      String fieldID,
      String message,
      String senderID,
      String receiverID,
      List<String> readBy});
}

/// @nodoc
class __$$_DMChatModelCopyWithImpl<$Res>
    extends _$DMChatModelCopyWithImpl<$Res, _$_DMChatModel>
    implements _$$_DMChatModelCopyWith<$Res> {
  __$$_DMChatModelCopyWithImpl(
      _$_DMChatModel _value, $Res Function(_$_DMChatModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = freezed,
    Object? fieldID = null,
    Object? message = null,
    Object? senderID = null,
    Object? receiverID = null,
    Object? readBy = null,
  }) {
    return _then(_$_DMChatModel(
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fieldID: null == fieldID
          ? _value.fieldID
          : fieldID // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      senderID: null == senderID
          ? _value.senderID
          : senderID // ignore: cast_nullable_to_non_nullable
              as String,
      receiverID: null == receiverID
          ? _value.receiverID
          : receiverID // ignore: cast_nullable_to_non_nullable
              as String,
      readBy: null == readBy
          ? _value._readBy
          : readBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DMChatModel implements _DMChatModel {
  const _$_DMChatModel(
      {@TimestampConverter() this.timestamp,
      required this.fieldID,
      required this.message,
      required this.senderID,
      required this.receiverID,
      required final List<String> readBy})
      : _readBy = readBy;

  factory _$_DMChatModel.fromJson(Map<String, dynamic> json) =>
      _$$_DMChatModelFromJson(json);

  @override
  @TimestampConverter()
  final DateTime? timestamp;
  @override
  final String fieldID;
  @override
  final String message;
  @override
  final String senderID;
  @override
  final String receiverID;
  final List<String> _readBy;
  @override
  List<String> get readBy {
    if (_readBy is EqualUnmodifiableListView) return _readBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_readBy);
  }

  @override
  String toString() {
    return 'DMChatModel(timestamp: $timestamp, fieldID: $fieldID, message: $message, senderID: $senderID, receiverID: $receiverID, readBy: $readBy)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DMChatModel &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.fieldID, fieldID) || other.fieldID == fieldID) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.senderID, senderID) ||
                other.senderID == senderID) &&
            (identical(other.receiverID, receiverID) ||
                other.receiverID == receiverID) &&
            const DeepCollectionEquality().equals(other._readBy, _readBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, fieldID, message,
      senderID, receiverID, const DeepCollectionEquality().hash(_readBy));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DMChatModelCopyWith<_$_DMChatModel> get copyWith =>
      __$$_DMChatModelCopyWithImpl<_$_DMChatModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DMChatModelToJson(
      this,
    );
  }
}

abstract class _DMChatModel implements DMChatModel {
  const factory _DMChatModel(
      {@TimestampConverter() final DateTime? timestamp,
      required final String fieldID,
      required final String message,
      required final String senderID,
      required final String receiverID,
      required final List<String> readBy}) = _$_DMChatModel;

  factory _DMChatModel.fromJson(Map<String, dynamic> json) =
      _$_DMChatModel.fromJson;

  @override
  @TimestampConverter()
  DateTime? get timestamp;
  @override
  String get fieldID;
  @override
  String get message;
  @override
  String get senderID;
  @override
  String get receiverID;
  @override
  List<String> get readBy;
  @override
  @JsonKey(ignore: true)
  _$$_DMChatModelCopyWith<_$_DMChatModel> get copyWith =>
      throw _privateConstructorUsedError;
}
