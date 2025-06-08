import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  String id;
  int unreadedMessages;
  String name;
  String profileImage;
  Timestamp? lastActive;
  bool isOnline;
  bool isTyping;
  ChatUser({
    required this.id,
    required this.unreadedMessages,
    required this.name,
    required this.profileImage,
    this.lastActive,
    required this.isOnline,
    required this.isTyping,
  });

  ChatUser copyWith({
    String? id,
    int? unreadedMessages,
    String? name,
    String? profileImage,
    Timestamp? lastActive,
    bool? isOnline,
    bool? isTyping,
  }) {
    return ChatUser(
      id: id ?? this.id,
      unreadedMessages: unreadedMessages ?? this.unreadedMessages,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'unreadedMessages': unreadedMessages});
    result.addAll({'name': name});
    result.addAll({'profileImage': profileImage});
    if (lastActive != null) {
      result.addAll({'lastActive': lastActive!});
    }
    result.addAll({'isOnline': isOnline});
    result.addAll({'isTyping': isTyping});

    return result;
  }

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id'] ?? '',
      unreadedMessages: map['unreadedMessages']?.toInt() ?? 0,
      name: map['name'] ?? '',
      profileImage: map['profileImage'] ?? '',
      lastActive: map['lastActive'] != null ? (map['lastActive']) : null,
      isOnline: map['isOnline'] ?? false,
      isTyping: map['isTyping'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatUser.fromJson(String source) =>
      ChatUser.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChatUser(id: $id, unreadedMessages: $unreadedMessages, name: $name, profileImage: $profileImage, lastActive: $lastActive, isOnline: $isOnline, isTyping: $isTyping)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatUser &&
        other.id == id &&
        other.unreadedMessages == unreadedMessages &&
        other.name == name &&
        other.profileImage == profileImage &&
        other.lastActive == lastActive &&
        other.isOnline == isOnline &&
        other.isTyping == isTyping;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        unreadedMessages.hashCode ^
        name.hashCode ^
        profileImage.hashCode ^
        lastActive.hashCode ^
        isOnline.hashCode ^
        isTyping.hashCode;
  }
}
