   import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../models/chat_model/chat_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

final CollectionReference<Object?> chatCollection =
      FirebaseFirestore.instance.collection('chat');
 /// Add new chat message
  Future<void> addNewChatMessage(String displayName, String message, String uid,
      Map<String, bool> status) async {
    final String key = chatCollection.doc().id;

    try {
      return await chatCollection
          .doc(tripDocID)
          .collection('messages')
          .doc(key)
          .set(<String, dynamic>{
        'displayName': displayName,
        'fieldID': key,
        'message': message,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'tripDocID': tripDocID,
        'uid': uid,
      });
    } catch (e) {
      CloudFunction().logError('Error writing new chat:  $e');
    }
  }

  /// Clear chat notifications.
  Future<void> clearChatNotifications() async {
    try {
      final Query<Map<String, dynamic>> db = chatCollection
          .doc(tripDocID)
          .collection('messages')
          .where('status.$uid', isEqualTo: false);
      final QuerySnapshot<Object?> snapshot = await db.get();
      for (int i = 0; i < snapshot.docs.length; i++) {
        chatCollection
            .doc(tripDocID)
            .collection('messages')
            .doc(snapshot.docs[i].id)
            .update(<String, dynamic>{'status.$uid': true});
      }
    } catch (e) {
      CloudFunction().logError('Error clearing chat notifications:  $e');
    }
  }

  /// Get all chat messages
  List<ChatModel> _chatListFromSnapshot(QuerySnapshot<Object?> snapshot) {
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return ChatModel.fromJson(doc as Map<String, Object>);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list:  $e');
      return <ChatModel>[defaultChatModel];
    }
  }

  Stream<List<ChatModel>>? get chatListNotification {
    try {
      return chatCollection
          .doc(tripDocID)
          .collection('messages')
          .where('status.${userService.currentUserID}', isEqualTo: false)
          .snapshots()
          .map(_chatListFromSnapshot);
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list notifications:  $e');
      return null;
    }
  }
