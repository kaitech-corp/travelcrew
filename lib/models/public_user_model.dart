import 'dart:convert';

import 'package:flutter/foundation.dart';

class PublicUserModel {

  PublicUserModel({
    required this.displayName,
    this.email,
    this.facebookLink,
    this.firstName,
    this.hometown,
    this.instagramLink,
    this.lastName,
    this.blockedList,
    this.followers,
    this.following,
    this.topDestinations,
    this.tripsCreated,
    this.tripsJoined,
    required this.uid,
    this.profileImage,
  });

  factory PublicUserModel.fromMap(Map<String, dynamic> map) {
    return PublicUserModel(
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String?,
      facebookLink: map['facebookLink'] as String?,
      firstName: map['firstName'] as String?,
      hometown: map['hometown'] as String?,
      instagramLink: map['instagramLink'] as String?,
      lastName: map['lastName'] as String?,
      blockedList: (map['blockedList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      followers: (map['followers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      following: (map['following'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      topDestinations: (map['topDestinations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tripsCreated: map['tripsCreated'] as int?,
      tripsJoined: map['tripsJoined'] as int?,
      uid: map['uid'] as String? ?? '',
      profileImage: map['profileImage'] as String?,
    );
  }
  factory PublicUserModel.fromJson(String source) =>
      PublicUserModel.fromMap(json.decode(source) as Map<String, dynamic>);
  String displayName;
  String? email;
  String? facebookLink;
  String? firstName;
  String? hometown;
  String? instagramLink;
  String? lastName;
  List<String>? blockedList;
  List<String>? followers;
  List<String>? following;
  List<String>? topDestinations;
  int? tripsCreated;
  int? tripsJoined;
  String uid;
  String? profileImage;

  PublicUserModel copyWith({
    String? displayName,
    String? email,
    String? facebookLink,
    String? firstName,
    String? hometown,
    String? instagramLink,
    String? lastName,
    List<String>? blockedList,
    List<String>? followers,
    List<String>? following,
    List<String>? topDestinations,
    int? tripsCreated,
    int? tripsJoined,
    String? uid,
    String? profileImage,
  }) {
    return PublicUserModel(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      facebookLink: facebookLink ?? this.facebookLink,
      firstName: firstName ?? this.firstName,
      hometown: hometown ?? this.hometown,
      instagramLink: instagramLink ?? this.instagramLink,
      lastName: lastName ?? this.lastName,
      blockedList: blockedList ?? this.blockedList,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      topDestinations: topDestinations ?? this.topDestinations,
      tripsCreated: tripsCreated ?? this.tripsCreated,
      tripsJoined: tripsJoined ?? this.tripsJoined,
      uid: uid ?? this.uid,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      'email': email,
      'facebookLink': facebookLink,
      'firstName': firstName,
      'hometown': hometown,
      'instagramLink': instagramLink,
      'lastName': lastName,
      'blockedList': blockedList,
      'followers': followers,
      'following': following,
      'topDestinations': topDestinations,
      'tripsCreated': tripsCreated,
      'tripsJoined': tripsJoined,
      'uid': uid,
      'profileImage': profileImage,
    };
  }

  @override
  String toString() {
    return 'PublicUserModel(displayName: $displayName, email: $email, facebookLink: $facebookLink, firstName: $firstName, hometown: $hometown, instagramLink: $instagramLink, lastName: $lastName, blockedList: $blockedList, followers: $followers, following: $following, topDestinations: $topDestinations, tripsCreated: $tripsCreated, tripsJoined: $tripsJoined, uid: $uid, profileImage: $profileImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PublicUserModel &&
        other.displayName == displayName &&
        other.email == email &&
        other.facebookLink == facebookLink &&
        other.firstName == firstName &&
        other.hometown == hometown &&
        other.instagramLink == instagramLink &&
        other.lastName == lastName &&
        listEquals(other.blockedList, blockedList) &&
        listEquals(other.followers, followers) &&
        listEquals(other.following, following) &&
        listEquals(other.topDestinations, topDestinations) &&
        other.tripsCreated == tripsCreated &&
        other.tripsJoined == tripsJoined &&
        other.uid == uid &&
        other.profileImage == profileImage;
  }

  @override
  int get hashCode {
    return displayName.hashCode ^
        email.hashCode ^
        facebookLink.hashCode ^
        firstName.hashCode ^
        hometown.hashCode ^
        instagramLink.hashCode ^
        lastName.hashCode ^
        blockedList.hashCode ^
        followers.hashCode ^
        following.hashCode ^
        topDestinations.hashCode ^
        tripsCreated.hashCode ^
        tripsJoined.hashCode ^
        uid.hashCode ^
        profileImage.hashCode;
  }

  String toJson() => json.encode(toMap());

  // Mock data for testing purposes
  static PublicUserModel mockData() {
    return PublicUserModel(
      displayName: 'John Doe',
      email: '',
      facebookLink: 'https://facebook.com/johndoe',
      firstName: 'John',
      hometown: 'New York',
      instagramLink: 'https://instagram.com/johndoe',
      lastName: 'Doe',
      blockedList: [],
      followers: [],
      following: [],
      topDestinations: [],
      tripsCreated: 0,
      tripsJoined: 0,
      uid: '1234567890',
      profileImage: 'https://example.com/image.jpg',
    );
  }
}
