import 'dart:convert';

import '../user_model.dart';
import 'chatroom.dart';

class ChatRoomUsers {
  ChatRoomUsers({required this.userModel, this.chatRoom});

  factory ChatRoomUsers.fromMap(Map<String, dynamic> map) {
    return ChatRoomUsers(
      userModel: UserModel.fromMap(map['userModel'] as Map<String, dynamic>),
      chatRoom:
          map['chatRoom'] != null
              ? ChatRoom.fromMap(map['chatRoom'] as Map<String, dynamic>)
              : null,
    );
  }

  factory ChatRoomUsers.fromJson(String source) =>
      ChatRoomUsers.fromMap(json.decode(source) as Map<String, dynamic>);
  UserModel userModel;
  ChatRoom? chatRoom;

  ChatRoomUsers copyWith({UserModel? userModel, ChatRoom? chatRoom}) {
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

  String toJson() => json.encode(toMap());

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
