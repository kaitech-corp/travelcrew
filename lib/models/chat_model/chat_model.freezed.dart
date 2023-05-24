// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) {
  return _ChatModel.fromJson(json);
}

/// @nodoc
mixin _$ChatModel {
  @TimestampConverter()
  DateTime? get timestamp => throw _privateConstructorUsedError;
  String get fieldID => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  String get tripDocID => throw _privateConstructorUsedError;
  String get chatID => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatModelCopyWith<ChatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatModelCopyWith<$Res> {
  factory $ChatModelCopyWith(ChatModel value, $Res Function(ChatModel) then) =
      _$ChatModelCopyWithImpl<$Res, ChatModel>;
  @useResult
  $Res call(
      {@TimestampConverter() DateTime? timestamp,
      String fieldID,
      String displayName,
      String message,
      String uid,
      String tripDocID,
      String chatID});
}

/// @nodoc
class _$ChatModelCopyWithImpl<$Res, $Val extends ChatModel>
    implements $ChatModelCopyWith<$Res> {
  _$ChatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = freezed,
    Object? fieldID = null,
    Object? displayName = null,
    Object? message = null,
    Object? uid = null,
    Object? tripDocID = null,
    Object? chatID = null,
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
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      tripDocID: null == tripDocID
          ? _value.tripDocID
          : tripDocID // ignore: cast_nullable_to_non_nullable
              as String,
      chatID: null == chatID
          ? _value.chatID
          : chatID // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ChatModelCopyWith<$Res> implements $ChatModelCopyWith<$Res> {
  factory _$$_ChatModelCopyWith(
          _$_ChatModel value, $Res Function(_$_ChatModel) then) =
      __$$_ChatModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@TimestampConverter() DateTime? timestamp,
      String fieldID,
      String displayName,
      String message,
      String uid,
      String tripDocID,
      String chatID});
}

/// @nodoc
class __$$_ChatModelCopyWithImpl<$Res>
    extends _$ChatModelCopyWithImpl<$Res, _$_ChatModel>
    implements _$$_ChatModelCopyWith<$Res> {
  __$$_ChatModelCopyWithImpl(
      _$_ChatModel _value, $Res Function(_$_ChatModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = freezed,
    Object? fieldID = null,
    Object? displayName = null,
    Object? message = null,
    Object? uid = null,
    Object? tripDocID = null,
    Object? chatID = null,
  }) {
    return _then(_$_ChatModel(
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fieldID: null == fieldID
          ? _value.fieldID
          : fieldID // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      tripDocID: null == tripDocID
          ? _value.tripDocID
          : tripDocID // ignore: cast_nullable_to_non_nullable
              as String,
      chatID: null == chatID
          ? _value.chatID
          : chatID // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ChatModel implements _ChatModel {
  const _$_ChatModel(
      {@TimestampConverter() this.timestamp,
      required this.fieldID,
      required this.displayName,
      required this.message,
      required this.uid,
      required this.tripDocID,
      required this.chatID});

  factory _$_ChatModel.fromJson(Map<String, dynamic> json) =>
      _$$_ChatModelFromJson(json);

  @override
  @TimestampConverter()
  final DateTime? timestamp;
  @override
  final String fieldID;
  @override
  final String displayName;
  @override
  final String message;
  @override
  final String uid;
  @override
  final String tripDocID;
  @override
  final String chatID;

  @override
  String toString() {
    return 'ChatModel(timestamp: $timestamp, fieldID: $fieldID, displayName: $displayName, message: $message, uid: $uid, tripDocID: $tripDocID, chatID: $chatID)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ChatModel &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.fieldID, fieldID) || other.fieldID == fieldID) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.tripDocID, tripDocID) ||
                other.tripDocID == tripDocID) &&
            (identical(other.chatID, chatID) || other.chatID == chatID));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, fieldID, displayName,
      message, uid, tripDocID, chatID);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ChatModelCopyWith<_$_ChatModel> get copyWith =>
      __$$_ChatModelCopyWithImpl<_$_ChatModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ChatModelToJson(
      this,
    );
  }
}

abstract class _ChatModel implements ChatModel {
  const factory _ChatModel(
      {@TimestampConverter() final DateTime? timestamp,
      required final String fieldID,
      required final String displayName,
      required final String message,
      required final String uid,
      required final String tripDocID,
      required final String chatID}) = _$_ChatModel;

  factory _ChatModel.fromJson(Map<String, dynamic> json) =
      _$_ChatModel.fromJson;

  @override
  @TimestampConverter()
  DateTime? get timestamp;
  @override
  String get fieldID;
  @override
  String get displayName;
  @override
  String get message;
  @override
  String get uid;
  @override
  String get tripDocID;
  @override
  String get chatID;
  @override
  @JsonKey(ignore: true)
  _$$_ChatModelCopyWith<_$_ChatModel> get copyWith =>
      throw _privateConstructorUsedError;
}
