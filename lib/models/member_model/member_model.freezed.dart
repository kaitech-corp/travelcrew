// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MemberModel _$MemberModelFromJson(Map<String, dynamic> json) {
  return _MemberModel.fromJson(json);
}

/// @nodoc
mixin _$MemberModel {
  String get displayName => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  String get urlToImage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MemberModelCopyWith<MemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberModelCopyWith<$Res> {
  factory $MemberModelCopyWith(
          MemberModel value, $Res Function(MemberModel) then) =
      _$MemberModelCopyWithImpl<$Res, MemberModel>;
  @useResult
  $Res call(
      {String displayName,
      String firstName,
      String lastName,
      String uid,
      String urlToImage});
}

/// @nodoc
class _$MemberModelCopyWithImpl<$Res, $Val extends MemberModel>
    implements $MemberModelCopyWith<$Res> {
  _$MemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? uid = null,
    Object? urlToImage = null,
  }) {
    return _then(_value.copyWith(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      urlToImage: null == urlToImage
          ? _value.urlToImage
          : urlToImage // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MemberModelCopyWith<$Res>
    implements $MemberModelCopyWith<$Res> {
  factory _$$_MemberModelCopyWith(
          _$_MemberModel value, $Res Function(_$_MemberModel) then) =
      __$$_MemberModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String displayName,
      String firstName,
      String lastName,
      String uid,
      String urlToImage});
}

/// @nodoc
class __$$_MemberModelCopyWithImpl<$Res>
    extends _$MemberModelCopyWithImpl<$Res, _$_MemberModel>
    implements _$$_MemberModelCopyWith<$Res> {
  __$$_MemberModelCopyWithImpl(
      _$_MemberModel _value, $Res Function(_$_MemberModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? uid = null,
    Object? urlToImage = null,
  }) {
    return _then(_$_MemberModel(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      urlToImage: null == urlToImage
          ? _value.urlToImage
          : urlToImage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_MemberModel implements _MemberModel {
  const _$_MemberModel(
      {required this.displayName,
      required this.firstName,
      required this.lastName,
      required this.uid,
      required this.urlToImage});

  factory _$_MemberModel.fromJson(Map<String, dynamic> json) =>
      _$$_MemberModelFromJson(json);

  @override
  final String displayName;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String uid;
  @override
  final String urlToImage;

  @override
  String toString() {
    return 'MemberModel(displayName: $displayName, firstName: $firstName, lastName: $lastName, uid: $uid, urlToImage: $urlToImage)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_MemberModel &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.urlToImage, urlToImage) ||
                other.urlToImage == urlToImage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, displayName, firstName, lastName, uid, urlToImage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MemberModelCopyWith<_$_MemberModel> get copyWith =>
      __$$_MemberModelCopyWithImpl<_$_MemberModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MemberModelToJson(
      this,
    );
  }
}

abstract class _MemberModel implements MemberModel {
  const factory _MemberModel(
      {required final String displayName,
      required final String firstName,
      required final String lastName,
      required final String uid,
      required final String urlToImage}) = _$_MemberModel;

  factory _MemberModel.fromJson(Map<String, dynamic> json) =
      _$_MemberModel.fromJson;

  @override
  String get displayName;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get uid;
  @override
  String get urlToImage;
  @override
  @JsonKey(ignore: true)
  _$$_MemberModelCopyWith<_$_MemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}
