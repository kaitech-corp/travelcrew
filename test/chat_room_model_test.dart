import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';

void main() {
  test('server roster round trips with public display fields', () {
    final savedAt = Timestamp.fromMillisecondsSinceEpoch(1800000000000);
    final room = ChatRoom.fromMap({
      'roomId': 'trip',
      'updatedAt': savedAt,
      'usersIds': ['alice', 'bob'],
      'users': [
        {
          'id': 'alice',
          'name': 'Alice',
          'profileImage': 'alice.jpg',
          'unreadedMessages': 0,
          'isOnline': false,
          'isTyping': false,
        },
      ],
    });
    expect(room.roomId, 'trip');
    expect(room.updatedAt, savedAt);
    expect(room.users.first.name, 'Alice');
    expect(room.users.first.profileImage, 'alice.jpg');
    expect(room.containsUser('bob'), isTrue);
    expect(ChatRoom.fromMap(room.toMap()).containsUser('alice'), isTrue);
  });

  test('legacy room profiles remain readable when roster IDs are absent', () {
    final room = ChatRoom.fromMap({
      'roomId': 'trip',
      'users': [
        {'id': 'legacy', 'name': 'Traveler', 'profileImage': ''},
      ],
    });
    expect(room.containsUser('legacy'), isTrue);
    expect(room.containsUser('stranger'), isFalse);
  });
}
