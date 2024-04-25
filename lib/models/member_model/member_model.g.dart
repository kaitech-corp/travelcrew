// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberModelImpl _$$MemberModelImplFromJson(Map<String, dynamic> json) =>
    _$MemberModelImpl(
      displayName: json['displayName'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      uid: json['uid'] as String,
      urlToImage: json['urlToImage'] as String,
    );

Map<String, dynamic> _$$MemberModelImplToJson(_$MemberModelImpl instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'uid': instance.uid,
      'urlToImage': instance.urlToImage,
    };
