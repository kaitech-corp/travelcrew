import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/models/chat_module/ChatUser.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';

import '../models/chat_module/ChatMessage.dart';
import '../models/chat_module/chatroom.dart';
import '../utils/app_strings.dart';

class ChatFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Future<ChatRoom?> getChatsByRoomId({required String roomId}) async {
    try {
      var result =
          await _firestore.collection(kTripChatCollection).doc(roomId).get();
      if (result.exists) {
        return ChatRoom.fromMap(result.data()!);
      }
    } catch (e) {}
    return null;
  }

  static Future<List<ChatRoom>> getChatRoomsByUserId({
    required String userId,
  }) async {
    try {
      var result =
          await _firestore
              .collection(kTripChatCollection)
              .where('usersIds', arrayContains: userId)
              .get();
      if (result.docs.isNotEmpty) {
        var futures = result.docs.map((e) async {
          var chatRoom = ChatRoom.fromMap(e.data());
          chatRoom.trip = await FirebaseTripService.getTripById(
            tripId: chatRoom.roomId,
          );
          return chatRoom;
        });
        return Future.wait(futures);
      }
    } catch (e) {}
    return [];
  }

  static Future<ChatRoom?> checkIfRoomExists({required String roomId}) async {
    try {
      var result =
          await _firestore.collection(kTripChatCollection).doc(roomId).get();
      if (result.exists) {
        return ChatRoom.fromMap(result.data()!);
      }
    } catch (e) {}
    return null;
  }

  // // fn to get all active users

  //   static Future<List<String>> getAllActiveUsers() async {
  //     List<String> users = [];
  //     try {
  //       var res = await _firestore
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
  //       await _firestore
  //           .collection(kActiveUsersCollection)
  //           .doc(kActiveUsersDocumentId)
  //           .update({'users': FieldValue.arrayUnion(users)});
  //     } else {
  //       await _firestore
  //           .collection(kActiveUsersCollection)
  //           .doc(kActiveUsersDocumentId)
  //           .update({'users': users});
  //     }
  //   } catch (e) {}
  // }
  static updateChatRoom({
    required String roomId,
    required ChatRoom chatToSave,
  }) async {
    try {
      await _firestore
          .collection(kTripChatCollection)
          .doc(roomId)
          .update(chatToSave.toMap());
    } catch (e) {}
  }

  // creating chat room if not exists
  static createChatRoom({required ChatRoom chatroom}) async {
    try {
      await _firestore
          .collection(kTripChatCollection)
          .doc(chatroom.roomId)
          .set(chatroom.toMap());
    } catch (e) {}
  }

  // to save message in firebase

  static sendMessage({
    required String roomId,
    required ChatMessage chatToSave,
  }) async {
    try {
      await _firestore.collection(kTripChatCollection).doc(roomId).update({
        'updatedAt': Timestamp.now(),
        'chats': FieldValue.arrayUnion([chatToSave.toMap()]),
      });
    } catch (e) {
      print(e);
    }
  }

  static updateIsTyping({
    required List<ChatUser> users,
    required String roomId,
  }) async {
    try {
      await _firestore.collection(kTripChatCollection).doc(roomId).update({
        'users': users.map((e) => e.toMap()).toList(),
      });
    } catch (e) {}
  }
}
