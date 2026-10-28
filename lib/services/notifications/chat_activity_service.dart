import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/logger.dart';

class ChatActivityService {
  static bool hasUnreadMessage(Map<String, dynamic>? activity) {
    if (activity == null) return false;
    final precise = activity['lastMessageAtTime'];
    final legacyMillis = activity['lastMessageAt'];
    final latest =
        precise is Timestamp
            ? precise
            : legacyMillis is num
            ? Timestamp.fromMillisecondsSinceEpoch(legacyMillis.toInt())
            : null;
    if (latest == null) return false;
    final readAt = activity['readAt'];
    return readAt is! Timestamp || latest.compareTo(readAt) > 0;
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String roomId) =>
      firestore
          .collection('users')
          .doc(GlobalVariables.currentUid)
          .collection('chatActivity')
          .doc(roomId)
          .snapshots();

  static Future<bool> markRead(String roomId, Timestamp readThrough) async {
    final uid = GlobalVariables.currentUid;
    if (uid.isEmpty || roomId.isEmpty) return false;
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('chatActivity')
          .doc(roomId)
          .set({'readAt': readThrough}, SetOptions(merge: true));
      return true;
    } catch (error) {
      AppLogger.warning('Unable to mark conversation read: $error');
      return false;
    }
  }
}
