// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommended_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

RecommendedContentModel _$RecommendedContentModelFromJson(
    Map<String, dynamic> json) {
  return _RecommendedContentModel.fromJson(json);
}

/// @nodoc
mixin _$RecommendedContentModel {
  String get name => throw _privateConstructorUsedError;
  int get clicks => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get dateCreated => throw _privateConstructorUsedError;
  String get docID => throw _privateConstructorUsedError;
  List<String> get urlToImage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecommendedContentModelCopyWith<RecommendedContentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendedContentModelCopyWith<$Res> {
  factory $RecommendedContentModelCopyWith(RecommendedContentModel value,
          $Res Function(RecommendedContentModel) then) =
      _$RecommendedContentModelCopyWithImpl<$Res, RecommendedContentModel>;
  @useResult
  $Res call(
      {String name,
      int clicks,
      @TimestampConverter() DateTime? dateCreated,
      String docID,
      List<String> urlToImage});
}

/// @nodoc
class _$RecommendedContentModelCopyWithImpl<$Res,
        $Val extends RecommendedContentModel>
    implements $RecommendedContentModelCopyWith<$Res> {
  _$RecommendedContentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? clicks = null,
    Object? dateCreated = freezed,
    Object? docID = null,
    Object? urlToImage = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      clicks: null == clicks
          ? _value.clicks
          : clicks // ignore: cast_nullable_to_non_nullable
              as int,
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      docID: null == docID
          ? _value.docID
          : docID // ignore: cast_nullable_to_non_nullable
              as String,
      urlToImage: null == urlToImage
          ? _value.urlToImage
          : urlToImage // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_RecommendedContentModelCopyWith<$Res>
    implements $RecommendedContentModelCopyWith<$Res> {
  factory _$$_RecommendedContentModelCopyWith(_$_RecommendedContentModel value,
          $Res Function(_$_RecommendedContentModel) then) =
      __$$_RecommendedContentModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      int clicks,
      @TimestampConverter() DateTime? dateCreated,
      String docID,
      List<String> urlToImage});
}

/// @nodoc
class __$$_RecommendedContentModelCopyWithImpl<$Res>
    extends _$RecommendedContentModelCopyWithImpl<$Res,
        _$_RecommendedContentModel>
    implements _$$_RecommendedContentModelCopyWith<$Res> {
  __$$_RecommendedContentModelCopyWithImpl(_$_RecommendedContentModel _value,
      $Res Function(_$_RecommendedContentModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? clicks = null,
    Object? dateCreated = freezed,
    Object? docID = null,
    Object? urlToImage = null,
  }) {
    return _then(_$_RecommendedContentModel(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      clicks: null == clicks
          ? _value.clicks
          : clicks // ignore: cast_nullable_to_non_nullable
              as int,
      dateCreated: freezed == dateCreated
          ? _value.dateCreated
          : dateCreated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      docID: null == docID
          ? _value.docID
          : docID // ignore: cast_nullable_to_non_nullable
              as String,
      urlToImage: null == urlToImage
          ? _value._urlToImage
          : urlToImage // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_RecommendedContentModel implements _RecommendedContentModel {
  const _$_RecommendedContentModel(
      {required this.name,
      required this.clicks,
      @TimestampConverter() this.dateCreated,
      required this.docID,
      required final List<String> urlToImage})
      : _urlToImage = urlToImage;

  factory _$_RecommendedContentModel.fromJson(Map<String, dynamic> json) =>
      _$$_RecommendedContentModelFromJson(json);

  @override
  final String name;
  @override
  final int clicks;
  @override
  @TimestampConverter()
  final DateTime? dateCreated;
  @override
  final String docID;
  final List<String> _urlToImage;
  @override
  List<String> get urlToImage {
    if (_urlToImage is EqualUnmodifiableListView) return _urlToImage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_urlToImage);
  }

  @override
  String toString() {
    return 'RecommendedContentModel(name: $name, clicks: $clicks, dateCreated: $dateCreated, docID: $docID, urlToImage: $urlToImage)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_RecommendedContentModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.clicks, clicks) || other.clicks == clicks) &&
            (identical(other.dateCreated, dateCreated) ||
                other.dateCreated == dateCreated) &&
            (identical(other.docID, docID) || other.docID == docID) &&
            const DeepCollectionEquality()
                .equals(other._urlToImage, _urlToImage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, clicks, dateCreated, docID,
      const DeepCollectionEquality().hash(_urlToImage));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_RecommendedContentModelCopyWith<_$_RecommendedContentModel>
      get copyWith =>
          __$$_RecommendedContentModelCopyWithImpl<_$_RecommendedContentModel>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_RecommendedContentModelToJson(
      this,
    );
  }
}

abstract class _RecommendedContentModel implements RecommendedContentModel {
  const factory _RecommendedContentModel(
      {required final String name,
      required final int clicks,
      @TimestampConverter() final DateTime? dateCreated,
      required final String docID,
      required final List<String> urlToImage}) = _$_RecommendedContentModel;

  factory _RecommendedContentModel.fromJson(Map<String, dynamic> json) =
      _$_RecommendedContentModel.fromJson;

  @override
  String get name;
  @override
  int get clicks;
  @override
  @TimestampConverter()
  DateTime? get dateCreated;
  @override
  String get docID;
  @override
  List<String> get urlToImage;
  @override
  @JsonKey(ignore: true)
  _$$_RecommendedContentModelCopyWith<_$_RecommendedContentModel>
      get copyWith => throw _privateConstructorUsedError;
}
