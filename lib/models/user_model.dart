import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userName;
  String email;
  bool isDeleted;
  String id;
  String password;
  String phone;
  String? profileImage;
  List<String>? favouriteTrips;
  bool email_confirmed;
  Timestamp createdAt;
  Timestamp updatedAt;

  UserModel({
    required this.userName,
    this.isDeleted = false,
    required this.email,
    this.profileImage,
    required this.id,
    required this.password,
    this.favouriteTrips,
    required this.phone,
    required this.email_confirmed,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? userName,
    String? email,
    String? profileImage,
    String? id,
    List<String>? favouriteTrips,
    String? password,
    String? phone,
    bool? email_confirmed,
    bool? isDeleted,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      userName: userName ?? this.userName,
      isDeleted: isDeleted ?? this.isDeleted,
      email: email ?? this.email,
      favouriteTrips: favouriteTrips ?? this.favouriteTrips,
      id: id ?? this.id,
      profileImage: profileImage ?? this.profileImage,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      email_confirmed: email_confirmed ?? this.email_confirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'userName': userName});
    result.addAll({'email': email});
    result.addAll({'isDeleted': isDeleted});
    result.addAll({'favouriteTrips': favouriteTrips});
    result.addAll({'profileImage': profileImage});
    result.addAll({'id': id});
    result.addAll({'phone': phone});
    result.addAll({'email_confirmed': email_confirmed});
    result.addAll({'createdAt': createdAt});
    result.addAll({'updatedAt': updatedAt});

    return result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userName: map['userName'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
      profileImage: map['profileImage'],
      email: map['email'] ?? '',
      id: map['id'] ?? '',
      favouriteTrips: List<String>.from(map['favouriteTrips'] ?? []),
      password: map['password'] ?? '',
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
    return 'UserModel(userName: $userName, profileImage: $profileImage, email: $email, id: $id, password: $password, phone: $phone, email_confirmed: $email_confirmed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.userName == userName &&
        other.email == email &&
        other.id == id &&
        other.profileImage == profileImage &&
        other.password == password &&
        other.phone == phone &&
        other.email_confirmed == email_confirmed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return userName.hashCode ^
        profileImage.hashCode ^
        email.hashCode ^
        id.hashCode ^
        password.hashCode ^
        phone.hashCode ^
        email_confirmed.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
