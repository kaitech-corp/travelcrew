import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/session_services.dart';

import '../models/chat_module/chatroom.dart';
import '../utils/app_strings.dart';

class ChatFirebaseService {
  static Future<ChatRoom> ensureChatRoom({required String roomId}) async {
    await FirebaseFunctions.instance.httpsCallable('ensureChatRoomV3').call({
      'tripId': roomId,
    });
    final snapshot =
        await firestore.collection(kTripChatCollection).doc(roomId).get();
    final data = snapshot.data();
    if (data == null) throw StateError('Chat room unavailable.');
    return ChatRoom.fromMap(data);
  }

  static Future<ChatRoom?> getChatsByRoomId({required String roomId}) async {
    try {
      final result =
          await firestore.collection(kTripChatCollection).doc(roomId).get();
      if (result.exists) {
        return ChatRoom.fromMap(result.data()!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getChatsByRoomId for roomId: $roomId. Error: $e');
      }
      rethrow;
    }
    return null;
  }

  static Future<List<ChatRoom>> getChatRoomsByUserId({
    required String userId,
  }) async {
    try {
      if (userId != GlobalVariables.currentUid) {
        throw StateError('Cannot load another traveler’s chat rooms.');
      }
      final rooms = <ChatRoom>[];
      Map<String, dynamic>? cursor;
      for (var page = 0; page < 20; page++) {
        final response = await FirebaseFunctions.instance
            .httpsCallable('listChatRoomsV3')
            .call({if (cursor != null) 'cursor': cursor});
        if (userId != GlobalVariables.currentUid) return [];
        final data = Map<String, dynamic>.from(response.data as Map);
        final ids = List<String>.from(data['roomIds'] as List<dynamic>);
        final batch = await Future.wait(
          ids.map((id) async {
            try {
              final snapshot =
                  await firestore.collection(kTripChatCollection).doc(id).get();
              final roomData = snapshot.data();
              if (roomData == null) return null;
              final room = ChatRoom.fromMap(roomData);
              room.trip = await FirebaseTripService.getTripById(tripId: id);
              return room.trip == null ? null : room;
            } on FirebaseException catch (error) {
              if (error.code == 'permission-denied') return null;
              rethrow;
            }
          }),
        );
        if (userId != GlobalVariables.currentUid) return [];
        rooms.addAll(batch.whereType<ChatRoom>());
        cursor =
            data['nextCursor'] == null
                ? null
                : Map<String, dynamic>.from(data['nextCursor'] as Map);
        if (cursor == null) return rooms;
      }
      throw StateError('Chat room list is too large to load.');
    } catch (e) {
      if (kDebugMode) {
        print('Error in getChatRoomsByUserId for userId: $userId. Error: $e');
      }
      rethrow;
    }
  }

  static Future<ChatRoom?> checkIfRoomExists({required String roomId}) async {
    try {
      final result =
          await firestore.collection(kTripChatCollection).doc(roomId).get();
      if (result.exists) {
        return ChatRoom.fromMap(result.data()!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in checkIfRoomExists for roomId: $roomId. Error: $e');
      }
      rethrow;
    }
    return null;
  }

  // to save message in firebase

  static Future<void> sendMessage({
    required String roomId,
    required ChatMessage chatToSave,
  }) async {
    if (chatToSave.chateId.isEmpty ||
        chatToSave.createdBy != GlobalVariables.currentUid ||
        chatToSave.sentTo != roomId ||
        chatToSave.messageType != MessageType.Text.name ||
        chatToSave.messageStatus != MessageStatus.sent.status ||
        chatToSave.data.trim().isEmpty ||
        chatToSave.data.length > 4000 ||
        chatToSave.callTimeTaken != null) {
      throw const FormatException('Invalid chat message.');
    }
    if (kDebugMode) {
      print('Saving message in room: $roomId');
    }
    try {
      final room = firestore.collection(kTripChatCollection).doc(roomId);
      final messageRef = room
          .collection(kTripChatMessagesCollection)
          .doc(chatToSave.chateId);
      await firestore.runTransaction((transaction) async {
        final existing = (await transaction.get(messageRef)).data();
        if (existing != null) {
          if (existing['chateId'] == chatToSave.chateId &&
              existing['createdBy'] == chatToSave.createdBy &&
              existing['sentTo'] == roomId &&
              existing['messageType'] == MessageType.Text.name &&
              existing['data'] == chatToSave.data) {
            return;
          }
          throw StateError('A different message already uses this ID.');
        }
        transaction.set(messageRef, {
          ...chatToSave.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(room, {
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessageId': chatToSave.chateId,
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in sendMessage for roomId: $roomId. Error: $e');
      }
      rethrow;
    }
  }

  static Future<List<ChatMessage>> getPaginatedChats(
    String roomId,
    DocumentSnapshot? lastVisible,
    int limit,
  ) async {
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }
    try {
      Query query = firestore
          .collection(kTripChatCollection)
          .doc(roomId)
          .collection(kTripChatMessagesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastVisible != null) {
        query = query.startAfterDocument(lastVisible);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => ChatMessage.fromMap(doc.data()! as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error in getPaginatedChats for roomId: $roomId. Error: $e');
      }
      rethrow;
    }
  }
}
