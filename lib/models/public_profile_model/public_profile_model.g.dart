// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UserPublicProfile _$$_UserPublicProfileFromJson(Map<String, dynamic> json) =>
    _$_UserPublicProfile(
      tripsJoined: json['tripsJoined'] as int?,
      tripsCreated: json['tripsCreated'] as int?,
      hometown: json['hometown'] as String?,
      instagramLink: json['instagramLink'] as String?,
      facebookLink: json['facebookLink'] as String?,
      topDestinations: (json['topDestinations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      blockedList: (json['blockedList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      following:
          (json['following'] as List<dynamic>).map((e) => e as String).toList(),
      followers:
          (json['followers'] as List<dynamic>).map((e) => e as String).toList(),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      uid: json['uid'] as String,
      urlToImage: json['urlToImage'] as String,
    );

Map<String, dynamic> _$$_UserPublicProfileToJson(
        _$_UserPublicProfile instance) =>
    <String, dynamic>{
      'tripsJoined': instance.tripsJoined,
      'tripsCreated': instance.tripsCreated,
      'hometown': instance.hometown,
      'instagramLink': instance.instagramLink,
      'facebookLink': instance.facebookLink,
      'topDestinations': instance.topDestinations,
      'blockedList': instance.blockedList,
      'displayName': instance.displayName,
      'email': instance.email,
      'following': instance.following,
      'followers': instance.followers,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'uid': instance.uid,
      'urlToImage': instance.urlToImage,
    };
