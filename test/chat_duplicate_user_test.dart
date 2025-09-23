import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/models/chat_module/chat_user.dart';

void main() {
  group('ChatRoom Duplicate User Prevention Tests', () {
    late ChatRoom chatRoom;
    late ChatUser testUser1;
    late ChatUser testUser2;

    setUp(() {
      // Create a test chatroom
      chatRoom = ChatRoom(
        roomId: 'test-room-123',
        updatedAt: Timestamp.now(),
        usersIds: [],
        users: [],
      );

      // Create test users
      testUser1 = ChatUser(
        id: 'user-1',
        unreadedMessages: 0,
        name: 'Test User 1',
        profileImage: '',
        lastActive: Timestamp.now(),
        isOnline: true,
        isTyping: false,
      );

      testUser2 = ChatUser(
        id: 'user-2',
        unreadedMessages: 0,
        name: 'Test User 2',
        profileImage: '',
        lastActive: Timestamp.now(),
        isOnline: true,
        isTyping: false,
      );
    });

    test('should add user successfully when chatroom is empty', () {
      // Act
      final result = chatRoom.addUserSafely(testUser1);

      // Assert
      expect(result, true);
      expect(chatRoom.users.length, 1);
      expect(chatRoom.usersIds.length, 1);
      expect(chatRoom.containsUser('user-1'), true);
    });

    test('should prevent adding duplicate user', () {
      // Arrange - add user first time
      chatRoom.addUserSafely(testUser1);

      // Act - try to add same user again
      final result = chatRoom.addUserSafely(testUser1);

      // Assert
      expect(result, false);
      expect(chatRoom.users.length, 1);
      expect(chatRoom.usersIds.length, 1);
    });

    test('should add different users successfully', () {
      // Act
      final result1 = chatRoom.addUserSafely(testUser1);
      final result2 = chatRoom.addUserSafely(testUser2);

      // Assert
      expect(result1, true);
      expect(result2, true);
      expect(chatRoom.users.length, 2);
      expect(chatRoom.usersIds.length, 2);
      expect(chatRoom.containsUser('user-1'), true);
      expect(chatRoom.containsUser('user-2'), true);
    });

    test('should detect user exists in usersIds even if not in users list', () {
      // Arrange - manually add user ID without user object (edge case)
      chatRoom.usersIds.add('user-1');

      // Act
      final result = chatRoom.addUserSafely(testUser1);

      // Assert
      expect(result, false);
      expect(chatRoom.containsUser('user-1'), true);
    });

    test('should detect user exists in users list even if not in usersIds', () {
      // Arrange - manually add user object without user ID (edge case)
      chatRoom.users.add(testUser1);

      // Act
      final result = chatRoom.addUserSafely(testUser1);

      // Assert
      expect(result, false);
      expect(chatRoom.containsUser('user-1'), true);
    });

    test('should remove user successfully', () {
      // Arrange
      chatRoom.addUserSafely(testUser1);
      chatRoom.addUserSafely(testUser2);

      // Act
      final result = chatRoom.removeUser('user-1');

      // Assert
      expect(result, true);
      expect(chatRoom.users.length, 1);
      expect(chatRoom.usersIds.length, 1);
      expect(chatRoom.containsUser('user-1'), false);
      expect(chatRoom.containsUser('user-2'), true);
    });

    test('should return false when trying to remove non-existent user', () {
      // Act
      final result = chatRoom.removeUser('non-existent-user');

      // Assert
      expect(result, false);
      expect(chatRoom.users.length, 0);
      expect(chatRoom.usersIds.length, 0);
    });

    test('containsUser should return false for empty chatroom', () {
      // Act & Assert
      expect(chatRoom.containsUser('any-user'), false);
    });
  });
}
