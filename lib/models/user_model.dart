import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel {

  UserModel({
    this.displayName,
    this.isDeleted = false,
    required this.email,
    required this.uid,
    this.phone,
    this.emailConfirmed,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.favouriteTrips = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      displayName: map['displayName'] as String?,
      isDeleted: map['isDeleted'] as bool? ?? false,
      email: map['email'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      phone: map['phone'] as String?,
      profileImage: map['profileImage'] as String?,
      emailConfirmed: map['emailConfirmed'] as bool?,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
      favouriteTrips: (map['favouriteTrips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
  String? displayName;
  String email;
  bool isDeleted;
  String uid;
  String? phone;
  bool? emailConfirmed;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  String? profileImage;
  List<String> favouriteTrips;

  UserModel copyWith({
    String? displayName,
    String? email,
    String? profileImage,
    String? uid,
    String? password,
    String? phone,
    bool? emailConfirmed,
    bool? isDeleted,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? favouriteTrips,
  }) {
    return UserModel(
      displayName: displayName ?? this.displayName,
      isDeleted: isDeleted ?? this.isDeleted,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favouriteTrips: favouriteTrips ?? this.favouriteTrips,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayName': displayName,
      'email': email,
      'isDeleted': isDeleted,
      'uid': uid,
      'phone': phone,
      'profileImage': profileImage,
      'emailConfirmed': emailConfirmed,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'favouriteTrips': favouriteTrips,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UserModel(displayName: $displayName, email: $email, uid: $uid, phone: $phone, profileImage: $profileImage, emailConfirmed: $emailConfirmed, createdAt: $createdAt, updatedAt: $updatedAt, favouriteTrips: $favouriteTrips)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.displayName == displayName &&
        other.email == email &&
        other.uid == uid &&
        other.phone == phone &&
        other.profileImage == profileImage &&
        other.emailConfirmed == emailConfirmed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.favouriteTrips, favouriteTrips);
  }

  @override
  int get hashCode {
    return displayName.hashCode ^
        email.hashCode ^
        uid.hashCode ^
        phone.hashCode ^
        profileImage.hashCode ^
        emailConfirmed.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        favouriteTrips.hashCode;
  }
}
