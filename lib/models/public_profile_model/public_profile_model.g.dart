// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names, always_specify_types

part of 'public_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UserPublicProfile _$$_UserPublicProfileFromJson(Map<String, dynamic> json) =>
    _$_UserPublicProfile(
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      facebookLink: json['facebookLink'] as String?,
      firstName: json['firstName'] as String?,
      hometown: json['hometown'] as String?,
      instagramLink: json['instagramLink'] as String?,
      lastName: json['lastName'] as String?,
      blockedList: (json['blockedList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      followers: (json['followers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      following: (json['following'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      topDestinations: (json['topDestinations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tripsCreated: json['tripsCreated'] as int?,
      tripsJoined: json['tripsJoined'] as int?,
      uid: json['uid'] as String,
      urlToImage: json['urlToImage'] as String?,
    );

Map<String, dynamic> _$$_UserPublicProfileToJson(
        _$_UserPublicProfile instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'email': instance.email,
      'facebookLink': instance.facebookLink,
      'firstName': instance.firstName,
      'hometown': instance.hometown,
      'instagramLink': instance.instagramLink,
      'lastName': instance.lastName,
      'blockedList': instance.blockedList,
      'followers': instance.followers,
      'following': instance.following,
      'topDestinations': instance.topDestinations,
      'tripsCreated': instance.tripsCreated,
      'tripsJoined': instance.tripsJoined,
      'uid': instance.uid,
      'urlToImage': instance.urlToImage,
    };
