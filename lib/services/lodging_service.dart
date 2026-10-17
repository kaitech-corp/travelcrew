import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/lodging_model.dart';

class LodgingService {
  static CollectionReference<Map<String, dynamic>> options(String tripId) =>
      firestore.collection('trips').doc(tripId).collection('lodgings');

  static Stream<List<LodgingModel>> watch(String tripId) =>
      options(tripId).snapshots().map(
        (snapshot) =>
            snapshot.docs
                .where((doc) => doc.data()['moderationRemoved'] != true)
                .map((doc) => LodgingModel.fromMap(doc.id, doc.data()))
                .where((option) => option.hasDetails)
                .toList(),
      );

  static Stream<Set<String>> watchLikes(String tripId, String lodgingId) =>
      options(tripId)
          .doc(lodgingId)
          .collection('likes')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());

  static Future<void> setLiked(
    String tripId,
    String lodgingId,
    String uid,
    bool liked,
  ) async {
    final ref = options(tripId).doc(lodgingId).collection('likes').doc(uid);
    if (liked) {
      await ref.set({'userId': uid});
    } else {
      await ref.delete();
    }
  }

  static Future<void> save(
    String tripId,
    LodgingModel option, {
    required bool isNew,
  }) async {
    final ref = options(tripId).doc(option.id);
    if (isNew) {
      await ref.set(option.toMap());
    } else {
      // An edit must not recreate an option removed on another device.
      await ref.update(option.toMap());
    }
  }
}
