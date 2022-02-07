import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/chat_model.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';

/// Interface to our 'chat' Firebase collection.
/// It contains the chat messages.
///
/// Relies on a remote NoSQL document-oriented database.
class ChatRepository {

  final CollectionReference chatCollection =  FirebaseFirestore.instance.collection("chat");
  final _loadedData = StreamController<List<ChatData>>.broadcast();
  final _loadedNotificationData = StreamController<List<ChatData>>.broadcast();


  void dispose() {
    _loadedData.close();
    _loadedNotificationData.close();
  }

  // Get all chat messages
  List<ChatData> _chatListFromSnapshot(QuerySnapshot snapshot){
    try {
      return snapshot.docs.map((doc){
        Map<String, dynamic> data = doc.data();
          return ChatData.fromData(data);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list:  ${e.toString()}');
      return null;
    }
  }

  void refresh(String tripDocID) {
    //Stream chats
    Stream<List<ChatData>> chatList = chatCollection
        .doc(tripDocID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(_chatListFromSnapshot);

    _loadedData.addStream(chatList);

  }

  void refreshChatNotifications(String tripDocID){


    Stream<List<ChatData>> chatListNotification = chatCollection
        .doc(tripDocID)
        .collection('messages')
        .where('status.${userService.currentUserID}' ,isEqualTo: false)
        .snapshots()
        .map(_chatListFromSnapshot);

    _loadedNotificationData.addStream(chatListNotification);
    }


  Stream<List<ChatData>> chats() => _loadedData.stream;
  Stream<List<ChatData>> notifications() => _loadedNotificationData.stream;

}
