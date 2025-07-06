import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? displayName;
  String email;
  bool isDeleted;
  String uid;
  String? phone;
  bool? email_confirmed;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  UserModel({
    this.displayName,
    this.isDeleted = false,
    required this.email,
    required this.uid,
     this.phone,
     this.email_confirmed,
     this.createdAt,
     this.updatedAt,
  });

  UserModel copyWith({
    String? displayName,
    String? email,
    String? profileImage,
    String? uid,
    List<String>? favouriteTrips,
    String? password,
    String? phone,
    bool? email_confirmed,
    bool? isDeleted,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      displayName: displayName ?? this.displayName,
      isDeleted: isDeleted ?? this.isDeleted,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      phone: phone ?? this.phone,
      email_confirmed: email_confirmed ?? this.email_confirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'displayName': displayName});
    result.addAll({'email': email});
    result.addAll({'isDeleted': isDeleted});
    result.addAll({'uid': uid});
    result.addAll({'phone': phone});
    result.addAll({'email_confirmed': email_confirmed});
    result.addAll({'createdAt': createdAt});
    result.addAll({'updatedAt': updatedAt});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      displayName: map['displayName'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
      email: map['email'] ?? '',
      uid: map['uid'] ?? '',
      phone: map['phone'] ?? '',
      email_confirmed: map['email_confirmed'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(displayName: $displayName, email: $email, uid: $uid, phone: $phone, email_confirmed: $email_confirmed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.displayName == displayName &&
        other.email == email &&
        other.uid == uid &&
        other.phone == phone &&
        other.email_confirmed == email_confirmed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return displayName.hashCode ^
        email.hashCode ^
        uid.hashCode ^
        phone.hashCode ^
        email_confirmed.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
