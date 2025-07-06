import 'dart:convert';

import 'package:flutter/foundation.dart';

class PublicUserModel {
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
  String? urlToImage;

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
    this.urlToImage,
  });

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
    String? urlToImage,
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
      urlToImage: urlToImage ?? this.urlToImage,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'displayName': displayName});
    result.addAll({'email': email});
    result.addAll({'facebookLink': facebookLink});
    result.addAll({'firstName': firstName});
    result.addAll({'hometown': hometown});
    result.addAll({'instagramLink': instagramLink});
    result.addAll({'lastName': lastName});
    result.addAll({'blockedList': blockedList});
    result.addAll({'followers': followers});
    result.addAll({'following': following});
    result.addAll({'topDestinations': topDestinations});
    result.addAll({'tripsCreated': tripsCreated});
    result.addAll({'tripsJoined': tripsJoined});
    result.addAll({'uid': uid});
    result.addAll({'urlToImage': urlToImage});

    return result;
  }

  factory PublicUserModel.fromMap(Map<String, dynamic> map) {
    return PublicUserModel(
      displayName: map['displayName'] ?? '',
      email: map['email'],
      facebookLink: map['facebookLink'],
      firstName: map['firstName'],
      hometown: map['hometown'],
      instagramLink: map['instagramLink'],
      lastName: map['lastName'],
      blockedList: List<String>.from(map['blockedList'] ?? []),
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      topDestinations: List<String>.from(map['topDestinations'] ?? []),
      tripsCreated: map['tripsCreated']?.toInt(),
      tripsJoined: map['tripsJoined']?.toInt(),
      uid: map['uid'] ?? '',
      urlToImage: map['urlToImage'],
    );
  }

  @override
  String toString() {
    return 'PublicUserModel(displayName: $displayName, email: $email, facebookLink: $facebookLink, firstName: $firstName, hometown: $hometown, instagramLink: $instagramLink, lastName: $lastName, blockedList: $blockedList, followers: $followers, following: $following, topDestinations: $topDestinations, tripsCreated: $tripsCreated, tripsJoined: $tripsJoined, uid: $uid, urlToImage: $urlToImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublicUserModel) return false;
    return other.displayName == displayName &&
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
        other.urlToImage == urlToImage;
  }

  String toJson() => json.encode(toMap());
  factory PublicUserModel.fromJson(String source) =>
      PublicUserModel.fromMap(json.decode(source));

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
      urlToImage: 'https://example.com/image.jpg',
    );
  }
}
