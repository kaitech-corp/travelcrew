import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/chat_model.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';

/// Interface to our 'chat' Firebase collection.
/// It contains the chat messages.
///
/// Relies on a remote NoSQL document-oriented database.
class ChatRepository extends GenericBlocRepository<ChatData>{

  ChatRepository({required this.tripDocID});

  final String tripDocID;

  final CollectionReference<Object> chatCollection =  FirebaseFirestore.instance.collection('chat');
  // Get all chat messages
  List<ChatData> _chatListFromSnapshot(QuerySnapshot<Object> snapshot){
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc){
          return ChatData.fromDocument(doc);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list:  ${e.toString()}');
      return [];
    }
  }

  @override
  Stream<List<ChatData>> data() {

    //Stream chats
    return chatCollection
        .doc(tripDocID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(_chatListFromSnapshot);

  }

}

class ChatNotificationRepository extends GenericBlocRepository<ChatData>{

  ChatNotificationRepository({required this.tripDocID});

  final String tripDocID;

  final CollectionReference<Object> chatCollection =  FirebaseFirestore.instance.collection('chat');
  // Get all chat messages
  List<ChatData> _chatListFromSnapshot(QuerySnapshot<Object> snapshot){
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc){
        return ChatData.fromDocument(doc);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list:  ${e.toString()}');
      return [];
    }
  }


  @override
  Stream<List<ChatData>> data(){
    //Stream chat notifications
    return chatCollection
        .doc(tripDocID)
        .collection('messages')
        .where('status.${userService.currentUserID}' ,isEqualTo: false)
        .snapshots()
        .map(_chatListFromSnapshot);

  }

}
