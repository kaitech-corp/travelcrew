import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';
import '../models/chat_model/chat_model.dart';

/// Interface to our 'chat' Firebase collection.
/// It contains the chat messages.
///
/// Relies on a remote NoSQL document-oriented database.
class ChatRepository extends GenericBlocRepository<ChatModel> {
  ChatRepository({required this.tripDocID});

  final String tripDocID;

  final CollectionReference<Object> chatCollection =
      FirebaseFirestore.instance.collection('chat');
  // Get all chat messages
  List<ChatModel> _chatListFromSnapshot(QuerySnapshot<Object> snapshot) {
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return ChatModel.fromJson(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list:  $e');
      if (kDebugMode) {
        print('Error displaying chat messages: $e');
      }
      return <ChatModel>[];
    }
  }

  @override
  Stream<List<ChatModel>> data() {
    //Stream chats
    return chatCollection
        .doc(tripDocID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(_chatListFromSnapshot);
  }
}

class ChatNotificationRepository extends GenericBlocRepository<ChatModel> {
  ChatNotificationRepository({required this.tripDocID});

  final String tripDocID;

  final CollectionReference<Object> chatCollection =
      FirebaseFirestore.instance.collection('chat');
  // Get all chat messages
  List<ChatModel> _chatListFromSnapshot(QuerySnapshot<Object> snapshot) {
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return ChatModel.fromJson(doc as Map<String, Object>);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list:  $e');
      return <ChatModel>[];
    }
  }

  @override
  Stream<List<ChatModel>> data() {
    //Stream chat notifications
    return chatCollection
        .doc(tripDocID)
        .collection('messages')
        .where('status.${userService.currentUserID}', isEqualTo: false)
        .snapshots()
        .map(_chatListFromSnapshot);
  }
}
