import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/services/session_services.dart';

/// Private, session-scoped safety state. UI filtering never grants data access.
class SafetyService {
  static final blockedIds = <String>{}.obs;
  static final ready = false.obs;
  static final failed = false.obs;
  static final busyIds = <String>{}.obs;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  static Worker? _worker;
  static String? _uid;
  static int _generation = 0;

  static void initialize() {
    _worker ??= ever(GlobalVariables.loggedInUser, (_) => _bind());
    _bind();
  }

  static void retry() => _bind(force: true);

  static void _bind({bool force = false}) {
    final uid = GlobalVariables.currentUid;
    if (!force && _uid == uid) return;
    _uid = uid;
    final generation = ++_generation;
    unawaited(_subscription?.cancel());
    _subscription = null;
    blockedIds.clear();
    busyIds.clear();
    ready.value = uid.isEmpty;
    failed.value = false;
    if (uid.isEmpty) return;
    _subscription = firestore
        .collection('users')
        .doc(uid)
        .collection('blockedUsers')
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) {
            if (_generation != generation) return;
            blockedIds.assignAll(snapshot.docs.map((doc) => doc.id));
            ready.value =
                !snapshot.metadata.isFromCache || snapshot.docs.isNotEmpty;
            failed.value = !ready.value;
          },
          onError: (Object error) {
            if (_generation != generation) return;
            ready.value = false;
            failed.value = true;
          },
        );
  }

  static bool isBlocked(String uid) => blockedIds.contains(uid);
  static bool hides(String uid) =>
      uid != GlobalVariables.currentUid &&
      (!ready.value || blockedIds.contains(uid));

  static Future<void> setBlocked(String targetUserId, bool blocked) async {
    if (busyIds.contains(targetUserId)) return;
    final generation = _generation;
    busyIds.add(targetUserId);
    try {
      await FirebaseFunctions.instance
          .httpsCallable(blocked ? 'blockUserV3' : 'unblockUserV3')
          .call<void>({'targetUserId': targetUserId});
      if (generation != _generation) return;
      if (blocked) {
        blockedIds.add(targetUserId);
      } else {
        blockedIds.remove(targetUserId);
      }
    } finally {
      if (generation == _generation) busyIds.remove(targetUserId);
    }
  }

  static Future<void> report({
    required String targetType,
    required String targetId,
    String? roomId,
    required String reason,
    required String details,
    required String requestId,
  }) async {
    await FirebaseFunctions.instance.httpsCallable('submitReportV3').call({
      'targetType': targetType,
      'targetId': targetId,
      if (roomId != null) 'roomId': roomId,
      'reason': reason,
      'details': details,
      'requestId': requestId,
    });
  }
}
