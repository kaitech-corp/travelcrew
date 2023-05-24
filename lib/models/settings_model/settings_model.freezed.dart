// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) {
  return _SettingsModel.fromJson(json);
}

/// @nodoc
mixin _$SettingsModel {
  bool? get isTripChatOn => throw _privateConstructorUsedError;
  bool? get isPushNotificationsOn => throw _privateConstructorUsedError;
  bool? get isTripChangeOn => throw _privateConstructorUsedError;
  bool? get isDirectMessagingOn => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SettingsModelCopyWith<SettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsModelCopyWith<$Res> {
  factory $SettingsModelCopyWith(
          SettingsModel value, $Res Function(SettingsModel) then) =
      _$SettingsModelCopyWithImpl<$Res, SettingsModel>;
  @useResult
  $Res call(
      {bool? isTripChatOn,
      bool? isPushNotificationsOn,
      bool? isTripChangeOn,
      bool? isDirectMessagingOn,
      @TimestampConverter() DateTime? lastUpdated});
}

/// @nodoc
class _$SettingsModelCopyWithImpl<$Res, $Val extends SettingsModel>
    implements $SettingsModelCopyWith<$Res> {
  _$SettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isTripChatOn = freezed,
    Object? isPushNotificationsOn = freezed,
    Object? isTripChangeOn = freezed,
    Object? isDirectMessagingOn = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      isTripChatOn: freezed == isTripChatOn
          ? _value.isTripChatOn
          : isTripChatOn // ignore: cast_nullable_to_non_nullable
              as bool?,
      isPushNotificationsOn: freezed == isPushNotificationsOn
          ? _value.isPushNotificationsOn
          : isPushNotificationsOn // ignore: cast_nullable_to_non_nullable
              as bool?,
      isTripChangeOn: freezed == isTripChangeOn
          ? _value.isTripChangeOn
          : isTripChangeOn // ignore: cast_nullable_to_non_nullable
              as bool?,
      isDirectMessagingOn: freezed == isDirectMessagingOn
          ? _value.isDirectMessagingOn
          : isDirectMessagingOn // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SettingsModelCopyWith<$Res>
    implements $SettingsModelCopyWith<$Res> {
  factory _$$_SettingsModelCopyWith(
          _$_SettingsModel value, $Res Function(_$_SettingsModel) then) =
      __$$_SettingsModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? isTripChatOn,
      bool? isPushNotificationsOn,
      bool? isTripChangeOn,
      bool? isDirectMessagingOn,
      @TimestampConverter() DateTime? lastUpdated});
}

/// @nodoc
class __$$_SettingsModelCopyWithImpl<$Res>
    extends _$SettingsModelCopyWithImpl<$Res, _$_SettingsModel>
    implements _$$_SettingsModelCopyWith<$Res> {
  __$$_SettingsModelCopyWithImpl(
      _$_SettingsModel _value, $Res Function(_$_SettingsModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isTripChatOn = freezed,
    Object? isPushNotificationsOn = freezed,
    Object? isTripChangeOn = freezed,
    Object? isDirectMessagingOn = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$_SettingsModel(
      isTripChatOn: freezed == isTripChatOn
          ? _value.isTripChatOn
          : isTripChatOn // ignore: cast_nullable_to_non_nullable
              as bool?,
      isPushNotificationsOn: freezed == isPushNotificationsOn
          ? _value.isPushNotificationsOn
          : isPushNotificationsOn // ignore: cast_nullable_to_non_nullable
              as bool?,
      isTripChangeOn: freezed == isTripChangeOn
          ? _value.isTripChangeOn
          : isTripChangeOn // ignore: cast_nullable_to_non_nullable
              as bool?,
      isDirectMessagingOn: freezed == isDirectMessagingOn
          ? _value.isDirectMessagingOn
          : isDirectMessagingOn // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SettingsModel implements _SettingsModel {
  const _$_SettingsModel(
      {this.isTripChatOn,
      this.isPushNotificationsOn,
      this.isTripChangeOn,
      this.isDirectMessagingOn,
      @TimestampConverter() this.lastUpdated});

  factory _$_SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$$_SettingsModelFromJson(json);

  @override
  final bool? isTripChatOn;
  @override
  final bool? isPushNotificationsOn;
  @override
  final bool? isTripChangeOn;
  @override
  final bool? isDirectMessagingOn;
  @override
  @TimestampConverter()
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'SettingsModel(isTripChatOn: $isTripChatOn, isPushNotificationsOn: $isPushNotificationsOn, isTripChangeOn: $isTripChangeOn, isDirectMessagingOn: $isDirectMessagingOn, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SettingsModel &&
            (identical(other.isTripChatOn, isTripChatOn) ||
                other.isTripChatOn == isTripChatOn) &&
            (identical(other.isPushNotificationsOn, isPushNotificationsOn) ||
                other.isPushNotificationsOn == isPushNotificationsOn) &&
            (identical(other.isTripChangeOn, isTripChangeOn) ||
                other.isTripChangeOn == isTripChangeOn) &&
            (identical(other.isDirectMessagingOn, isDirectMessagingOn) ||
                other.isDirectMessagingOn == isDirectMessagingOn) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, isTripChatOn,
      isPushNotificationsOn, isTripChangeOn, isDirectMessagingOn, lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SettingsModelCopyWith<_$_SettingsModel> get copyWith =>
      __$$_SettingsModelCopyWithImpl<_$_SettingsModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SettingsModelToJson(
      this,
    );
  }
}

abstract class _SettingsModel implements SettingsModel {
  const factory _SettingsModel(
      {final bool? isTripChatOn,
      final bool? isPushNotificationsOn,
      final bool? isTripChangeOn,
      final bool? isDirectMessagingOn,
      @TimestampConverter() final DateTime? lastUpdated}) = _$_SettingsModel;

  factory _SettingsModel.fromJson(Map<String, dynamic> json) =
      _$_SettingsModel.fromJson;

  @override
  bool? get isTripChatOn;
  @override
  bool? get isPushNotificationsOn;
  @override
  bool? get isTripChangeOn;
  @override
  bool? get isDirectMessagingOn;
  @override
  @TimestampConverter()
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$_SettingsModelCopyWith<_$_SettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}
