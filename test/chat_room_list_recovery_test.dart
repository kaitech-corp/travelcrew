import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/views/messages/group/controller/group_controller.dart';
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';

ChatRoom room(String id) => ChatRoom(
  roomId: id,
  updatedAt: Timestamp.fromMillisecondsSinceEpoch(1800000000000),
  usersIds: const ['owner'],
  users: const [],
  trip: TripModel.fromMap({
    'id': id,
    'title': id,
    'createdBy': 'owner',
    'destination': 'Tokyo',
    'country': 'Japan',
    'startDate': '2027-01-01',
  }),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    GlobalVariables.loggedInUser.value = UserModel(
      uid: 'owner',
      email: 'owner@example.com',
    );
  });
  tearDown(() => GlobalVariables.loggedInUser.value = null);

  test(
    'message list distinguishes failure from empty and retry recovers',
    () async {
      var attempts = 0;
      final controller = UsersController(
        fetchRooms: (uid) async {
          expect(uid, 'owner');
          attempts++;
          if (attempts == 1) throw StateError('offline');
          return [room('trip')];
        },
      );
      addTearDown(controller.onClose);

      await controller.loadChatRooms();
      expect(controller.chatRooms, isEmpty);
      expect(controller.chatRoomsError.value, contains('retry'));
      await controller.loadChatRooms();
      expect(controller.chatRooms.single.roomId, 'trip');
      expect(controller.chatRoomsError.value, isNull);
    },
  );

  test('message list discards an old account response', () async {
    final pending = Completer<List<ChatRoom>>();
    final controller = UsersController(fetchRooms: (_) => pending.future);
    addTearDown(controller.onClose);
    final load = controller.loadChatRooms();
    GlobalVariables.loggedInUser.value = UserModel(
      uid: 'other',
      email: 'other@example.com',
    );
    pending.complete([room('private-trip')]);
    await load;
    expect(controller.chatRooms, isEmpty);
  });

  test(
    'group list retains loaded rooms after failure and clears on retry',
    () async {
      var attempts = 0;
      final controller = GroupController(
        fetchRooms: (_) async {
          attempts++;
          if (attempts == 2) throw StateError('offline');
          return [room('trip')];
        },
      );
      addTearDown(controller.onClose);

      await controller.getChatRooms();
      expect(controller.chatRooms.single.roomId, 'trip');
      await controller.getChatRooms();
      expect(controller.chatRooms.single.roomId, 'trip');
      expect(controller.loadError.value, contains('retry'));
      await controller.getChatRooms();
      expect(controller.loadError.value, isNull);
      expect(controller.chatRooms.single.roomId, 'trip');
    },
  );

  test(
    'a session change clears prior chat rooms and loads the new account',
    () async {
      final controller = UsersController(
        fetchRooms: (uid) async => [room('$uid-trip')],
      );
      addTearDown(controller.onClose);
      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      expect(controller.chatRooms.single.roomId, 'owner-trip');
      controller.chatOpenError.value = 'Old account chat failed';
      controller.earlierMessagesError.value = 'Old account page failed';
      controller.isOpeningChat.value = true;

      GlobalVariables.loggedInUser.value = UserModel(
        uid: 'other',
        email: 'other@example.com',
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.chatRooms.single.roomId, 'other-trip');
      expect(controller.chatOpenError.value, isNull);
      expect(controller.earlierMessagesError.value, isNull);
      expect(controller.isOpeningChat.value, isFalse);
    },
  );

  test('chat search matches title and restores rooms when cleared', () {
    final controller = UsersController(fetchRooms: (_) async => []);
    addTearDown(controller.onClose);
    controller.chatRooms.value = [room('Tokyo weekend'), room('Kyoto week')];
    controller.messagesSearch.value = '  KYOTO  ';
    expect(
      controller
          .visibleChatRooms(controller.messagesSearch.value)
          .map((item) => item.roomId),
      ['Kyoto week'],
    );
    controller.messagesSearch.value = '';
    expect(
      controller.visibleChatRooms(controller.messagesSearch.value).length,
      2,
    );
  });
}
