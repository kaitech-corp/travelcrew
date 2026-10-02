import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/logger.dart';

class ChatActivityService {
  static Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String roomId) =>
      firestore
          .collection('users')
          .doc(GlobalVariables.currentUid)
          .collection('chatActivity')
          .doc(roomId)
          .snapshots();

  static Future<void> markRead(String roomId) async {
    if (GlobalVariables.currentUid.isEmpty) return;
    try {
      await firestore
          .collection('users')
          .doc(GlobalVariables.currentUid)
          .collection('chatActivity')
          .doc(roomId)
          .set({
            'readAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (error) {
      AppLogger.warning('Unable to mark conversation read: $error');
    }
  }
}
