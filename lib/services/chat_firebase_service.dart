import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/models/chat_module/chat_user.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';

import '../models/chat_module/chatroom.dart';
import '../utils/app_strings.dart';

class ChatFirebaseService {
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
    }
    return null;
  }

  static Future<List<ChatRoom>> getChatRoomsByUserId({
    required String userId,
  }) async {
    try {
      final result =
          await firestore
              .collection(kTripChatCollection)
              .where('usersIds', arrayContains: userId)
              .get();
      if (result.docs.isNotEmpty) {
        final futures = result.docs.map((e) async {
          final chatRoom = ChatRoom.fromMap(e.data());
          chatRoom.trip = await FirebaseTripService.getTripById(
            tripId: chatRoom.roomId,
          );
          return chatRoom;
        });
        return Future.wait(futures);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getChatRoomsByUserId for userId: $userId. Error: $e');
      }
    }
    return [];
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
      return null;
    }
    return null;
  }

  // // fn to get all active users

  //   static Future<List<String>> getAllActiveUsers() async {
  //     List<String> users = [];
  //     try {
  //       var res = await firestore
  //           .collection(kActiveUsersCollection)
  //           .doc(kActiveUsersDocumentId)
  //           .get();
  //       if (res.exists) {
  //         for (var element in res.data()!['users']) {
  //           users.add(element);
  //         }
  //         return users;
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //     return [];
  //   }

  // // fn to set user to Active or in-active
  // static updateUserActiveStatus(
  //     {required List<String> users, bool isToAdd = true}) async {
  //   try {
  //     if (isToAdd) {
  //       await firestore
  //           .collection(kActiveUsersCollection)
  //           .doc(kActiveUsersDocumentId)
  //           .update({'users': FieldValue.arrayUnion(users)});
  //     } else {
  //       await firestore
  //           .collection(kActiveUsersCollection)
  //           .doc(kActiveUsersDocumentId)
  //           .update({'users': users});
  //     }
  //   } catch (e) {}
  // }
  static Future<void> updateChatRoom({
    required String roomId,
    required ChatRoom chatToSave,
  }) async {
    try {
      await firestore
          .collection(kTripChatCollection)
          .doc(roomId)
          .update(chatToSave.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error in updateChatRoom for roomId: $roomId. Error: $e');
      }
    }
  }

  // creating chat room if not exists
  static Future<void> createChatRoom({required ChatRoom chatroom}) async {
    try {
      await firestore
          .collection(kTripChatCollection)
          .doc(chatroom.roomId)
          .set(chatroom.toMap());
    } catch (e) {
      if (kDebugMode) {
        print(
          'Error in createChatRoom for roomId: ${chatroom.roomId}. Error: $e',
        );
      }
    }
  }

  // to save message in firebase

  static Future<void> sendMessage({
    required String roomId,
    required ChatMessage chatToSave,
  }) async {
    if (kDebugMode) {
      print('Saving message in room: $roomId');
    }
    try {
      await firestore
          .collection(kTripChatCollection)
          .doc(roomId)
          .collection(kTripChatMessagesCollection)
          .doc(chatToSave.chateId)
          .set(chatToSave.copyWith(createdAt: Timestamp.now()).toMap());
      await firestore.collection(kTripChatCollection).doc(roomId).update({
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in sendMessage for roomId: $roomId. Error: $e');
      }
    }
  }

  static Future<void> updateIsTyping({
    required List<ChatUser> users,
    required String roomId,
  }) async {
    try {
      await firestore.collection(kTripChatCollection).doc(roomId).update({
        'users': users.map((e) => e.toMap()).toList(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in updateIsTyping for roomId: $roomId. Error: $e');
      }
    }
  }

  static Future<List<ChatMessage>> getPaginatedChats(
    String roomId,
    DocumentSnapshot? lastVisible,
    int limit,
  ) async {
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
      return [];
    }
  }

  /// Safely add a user to a chatroom, preventing duplicates
  static Future<bool> addUserToChatRoom({
    required String roomId,
    required ChatUser user,
  }) async {
    try {
      final chatRoom = await getChatsByRoomId(roomId: roomId);
      if (chatRoom == null) {
        if (kDebugMode) {
          print('Cannot add user to non-existent chatroom: $roomId');
        }
        return false;
      }

      final userAdded = chatRoom.addUserSafely(user);
      if (!userAdded) {
        if (kDebugMode) {
          print('User ${user.id} is already in chatroom: $roomId');
        }
        return false; // User was already in the chatroom
      }

      await updateChatRoom(roomId: roomId, chatToSave: chatRoom);
      if (kDebugMode) {
        print('Successfully added user ${user.id} to chatroom: $roomId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(
          'Error in addUserToChatRoom for roomId: $roomId, userId: ${user.id}. Error: $e',
        );
      }
      return false;
    }
  }

  /// Remove a user from a chatroom
  static Future<bool> removeUserFromChatRoom({
    required String roomId,
    required String userId,
  }) async {
    try {
      final chatRoom = await getChatsByRoomId(roomId: roomId);
      if (chatRoom == null) {
        if (kDebugMode) {
          print('Cannot remove user from non-existent chatroom: $roomId');
        }
        return false;
      }

      final userRemoved = chatRoom.removeUser(userId);
      if (!userRemoved) {
        if (kDebugMode) {
          print('User $userId was not found in chatroom: $roomId');
        }
        return false;
      }

      await updateChatRoom(roomId: roomId, chatToSave: chatRoom);
      if (kDebugMode) {
        print('Successfully removed user $userId from chatroom: $roomId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(
          'Error in removeUserFromChatRoom for roomId: $roomId, userId: $userId. Error: $e',
        );
      }
      return false;
    }
  }
}
