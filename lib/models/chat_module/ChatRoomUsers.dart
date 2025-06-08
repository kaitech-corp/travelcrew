import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../user_model.dart';
import 'chatroom.dart';

class ChatRoomUsers {
  UserModel userModel;
  ChatRoom? chatRoom;
  ChatRoomUsers({
    required this.userModel,
    this.chatRoom,
  });

  ChatRoomUsers copyWith({
    UserModel? userModel,
    ChatRoom? chatRoom,
  }) {
    return ChatRoomUsers(
      userModel: userModel ?? this.userModel,
      chatRoom: chatRoom ?? this.chatRoom,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'userModel': userModel.toMap()});
    if (chatRoom != null) {
      result.addAll({'chatRoom': chatRoom!.toMap()});
    }

    return result;
  }

  factory ChatRoomUsers.fromMap(Map<String, dynamic> map) {
    return ChatRoomUsers(
      userModel: UserModel.fromMap(map['userModel']),
      chatRoom:
          map['chatRoom'] != null ? ChatRoom.fromMap(map['chatRoom']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatRoomUsers.fromJson(String source) =>
      ChatRoomUsers.fromMap(json.decode(source));

  @override
  String toString() =>
      'ChatRoomUsers(userModel: $userModel, chatRoom: $chatRoom)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatRoomUsers &&
        other.userModel == userModel &&
        other.chatRoom == chatRoom;
  }

  @override
  int get hashCode => userModel.hashCode ^ chatRoom.hashCode;
}
