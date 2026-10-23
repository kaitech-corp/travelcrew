import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/services/recommendation_service.dart';
import 'package:travel_crew/services/session_services.dart';

class RecommendationRuntime {
  static final service = RecommendationService(
    currentUid: () => GlobalVariables.currentUid,
    call: (name, data) async {
      try {
        final result = await FirebaseFunctions.instance
            .httpsCallable(
              name,
              options: HttpsCallableOptions(
                timeout: const Duration(seconds: 20),
              ),
            )
            .call<dynamic>(data);
        return Map<String, dynamic>.from(result.data as Map);
      } on FirebaseFunctionsException catch (error) {
        throw RecommendationException(error.code);
      }
    },
  );
  static Worker? _worker;
  static String? _uid;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _dismissals;
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _preferences;

  static void initialize() {
    _worker ??= ever(GlobalVariables.loggedInUser, (_) => _bind());
    _bind();
  }

  static void _bind() {
    final uid = GlobalVariables.currentUid;
    if (_uid == uid) return;
    _uid = uid;
    unawaited(_dismissals?.cancel());
    unawaited(_preferences?.cancel());
    _dismissals = null;
    _preferences = null;
    service.bindAccount();
    if (uid.isEmpty) return;
    final user = firestore.collection('users').doc(uid);
    _dismissals = user
        .collection('recommendationDismissals')
        .snapshots()
        .listen(
          (snapshot) {
            if (_uid != uid) return;
            service.updateDismissals(
              snapshot.docs
                  .where((doc) => doc.data()['dismissed'] == true)
                  .map((doc) => doc.id)
                  .toSet(),
            );
          },
          onError:
              (Object _) {}, // Server eligibility still enforces suppression.
        );
    _preferences = user
        .collection('recommendationPreferences')
        .doc('current')
        .snapshots()
        .listen(
          (snapshot) {
            if (_uid == uid) service.updatePreferences(snapshot.data() ?? {});
          },
          onError:
              (Object _) {}, // A feed request reads authoritative preferences.
        );
  }
}
