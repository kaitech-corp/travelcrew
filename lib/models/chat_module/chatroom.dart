import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crew/models/trip_model.dart';

import 'ChatMessage.dart';
import 'ChatUser.dart';

class ChatRoom {
  String roomId;
  TripModel? trip;
  Timestamp updatedAt;
  List<String> usersIds;
  List<ChatUser> users;
  List<ChatMessage> chats;
  ChatRoom({
    required this.roomId,
    required this.updatedAt,
    this.trip,
    required this.usersIds,
    required this.users,
    required this.chats,
  });

  ChatRoom copyWith({
    String? roomId,
    Timestamp? updatedAt,
    List<String>? usersIds,
    List<ChatUser>? users,
    List<ChatMessage>? chats,
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      updatedAt: updatedAt ?? this.updatedAt,
      usersIds: usersIds ?? this.usersIds,
      users: users ?? this.users,
      chats: chats ?? this.chats,
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
    result.addAll({'chats': chats.map((x) => x.toMap()).toList()});

    return result;
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      roomId: map['roomId'] ?? '',
      usersIds: List<String>.from(map['usersIds']),
      updatedAt: map['updatedAt'] ?? Timestamp.fromDate(DateTime(1999)),
      users: List<ChatUser>.from(map['users']?.map((x) => ChatUser.fromMap(x))),
      chats: List<ChatMessage>.from(
        map['chats']?.map((x) => ChatMessage.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatRoom.fromJson(String source) =>
      ChatRoom.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ChatRoom(roomId: $roomId, updatedAt: $updatedAt, users: $users, chats: $chats)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoom &&
        other.roomId == roomId &&
        other.updatedAt == updatedAt &&
        listEquals(other.users, users) &&
        listEquals(other.chats, chats);
  }

  @override
  int get hashCode {
    return roomId.hashCode ^
        updatedAt.hashCode ^
        users.hashCode ^
        chats.hashCode;
  }
}
