import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crew/models/chat_module/chat_user.dart';
import 'package:travel_crew/models/trip_model.dart';

class ChatRoom {
  ChatRoom({
    required this.roomId,
    required this.updatedAt,
    this.trip,
    required this.usersIds,
    required this.users,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      roomId: (map['roomId'] as String?) ?? '',
      usersIds: List<String>.from(
        (map['usersIds'] as List<dynamic>?) ?? <dynamic>[],
      ),
      updatedAt:
          (map['updatedAt'] as Timestamp?) ??
          Timestamp.fromDate(DateTime(1999)),
      users: List<ChatUser>.from(
        map['users']?.map((x) => ChatUser.fromMap(x)) ?? [],
      ),
    );
  }

  factory ChatRoom.fromJson(String source) =>
      ChatRoom.fromMap(json.decode(source) as Map<String, dynamic>);
  String roomId;
  TripModel? trip;
  Timestamp updatedAt;
  List<String> usersIds;
  List<ChatUser> users;

  ChatRoom copyWith({
    String? roomId,
    Timestamp? updatedAt,
    List<String>? usersIds,
    List<ChatUser>? users,
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      updatedAt: updatedAt ?? this.updatedAt,
      usersIds: usersIds ?? this.usersIds,
      users: users ?? this.users,
    );
  }

  Map<String, dynamic> toMap({bool isOnlyUser = false}) {
    final result = <String, dynamic>{};
    if (isOnlyUser) {
      result.addAll({'users': users.map((x) => x.toMap()).toList()});
      return result;
    }
    result.addAll({'usersIds': usersIds});
    result.addAll({'roomId': roomId});
    result.addAll({'updatedAt': updatedAt});
    result.addAll({'users': users.map((x) => x.toMap()).toList()});

    return result;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'ChatRoom(roomId: $roomId, updatedAt: $updatedAt, users: $users)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoom &&
        other.roomId == roomId &&
        other.updatedAt == updatedAt &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return roomId.hashCode ^ updatedAt.hashCode ^ users.hashCode;
  }

  /// Check if a user is already in the chatroom
  bool containsUser(String userId) {
    return usersIds.contains(userId) || users.any((user) => user.id == userId);
  }

  /// Safely add a user to the chatroom if not already present
  bool addUserSafely(ChatUser user) {
    if (containsUser(user.id)) {
      return false; // User already exists
    }

    users.add(user);
    usersIds.add(user.id);
    return true; // User was added successfully
  }

  /// Remove a user from the chatroom
  bool removeUser(String userId) {
    final initialUserCount = users.length;
    users.removeWhere((user) => user.id == userId);
    final userRemoved = users.length < initialUserCount;
    final userIdRemoved = usersIds.remove(userId);
    return userRemoved || userIdRemoved;
  }
}
