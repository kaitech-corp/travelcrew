import 'package:travel_crew/services/safety_service.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/Notifications/notification_model.dart';
import 'package:travel_crew/models/Notifications/user_notification_model.dart';
import 'package:travel_crew/services/notifications/notification_badge_service.dart';
import 'package:travel_crew/services/notifications/notifications_firebase_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/error_handler.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> _allNotifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  List<NotificationModel> get notifications =>
      _allNotifications
          .map(
            (group) => NotificationModel(
              date: group.date,
              notifications:
                  group.notifications
                      .where(
                        (n) =>
                            n.createdBy == 'system' ||
                            !SafetyService.hides(n.createdBy),
                      )
                      .toList(),
            ),
          )
          .where((group) => group.notifications.isNotEmpty)
          .toList();

  Worker? _safetyWorker;
  Worker? _readyWorker;
  List<UserNotificationModel> _badgeItems = [];
  void _updateSafetyBadge() {
    final createdAt = GlobalVariables.loggedInUser.value?.createdAt?.toDate();
    final count =
        _badgeItems
            .where(
              (n) =>
                  n.isUnread &&
                  (createdAt == null || !n.createdAt.isBefore(createdAt)) &&
                  (n.createdBy == 'system' ||
                      !SafetyService.hides(n.createdBy)),
            )
            .length;
    unreadCount.value = count;
    unawaited(NotificationBadgeService.setCount(count));
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _badgeSubscription;
  Worker? _userWorker;
  String? _listeningUid;

  @override
  void onInit() {
    super.onInit();
    _safetyWorker = ever(SafetyService.blockedIds, (_) => _updateSafetyBadge());
    _readyWorker = ever(SafetyService.ready, (_) => _updateSafetyBadge());
    _userWorker = ever(GlobalVariables.loggedInUser, (_) {
      _bindBadgeListener();
      unawaited(getNotification());
    });
    _bindBadgeListener();
    if (GlobalVariables.loggedInUser.value != null) {
      unawaited(getNotification());
    }
  }

  @override
  void onClose() {
    _safetyWorker?.dispose();
    _readyWorker?.dispose();
    _userWorker?.dispose();
    _badgeSubscription?.cancel();
    super.onClose();
  }

  Future<void> getNotification() async {
    try {
      final user = GlobalVariables.loggedInUser.value;
      if (user == null) {
        _allNotifications.clear();
        isLoading.value = false;
        return;
      }

      isLoading.value = true;
      final loaded = await FirebaseNotificationsService.getUserNotifications(
        type: '',
      );
      if (GlobalVariables.currentUid != user.uid) return;
      _allNotifications.value = loaded;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'getNotification',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final updated = await FirebaseNotificationsService.markNotificationAsRead(
      notificationId: notificationId,
    );
    if (updated) {
      await getNotification();
    }
  }

  Future<void> markAllAsRead() async {
    final flatNotifications =
        notifications.expand((group) => group.notifications).toList();
    final updated =
        await FirebaseNotificationsService.markAllNotificationsAsRead(
          notifications: flatNotifications,
        );
    if (updated) {
      await getNotification();
    }
  }

  void _bindBadgeListener() {
    final uid = GlobalVariables.loggedInUser.value?.uid;
    if (_listeningUid == uid) {
      return;
    }

    _listeningUid = uid;
    _badgeItems = [];
    _allNotifications.clear();
    _updateSafetyBadge();
    unawaited(_badgeSubscription?.cancel());
    _badgeSubscription = null;

    if (uid == null || uid.isEmpty) {
      unreadCount.value = 0;
      unawaited(NotificationBadgeService.clear());
      return;
    }

    _badgeSubscription = firestore
        .collection(kNotificationsCollection)
        .doc(uid)
        .collection(kNotificationsSubCollection)
        .snapshots()
        .listen(
          (snapshot) async {
            if (_listeningUid != uid) return;
            _badgeItems =
                snapshot.docs
                    .map((doc) => UserNotificationModel.fromMap(doc.data()))
                    .toList();
            _updateSafetyBadge();
            unawaited(getNotification());
          },
          onError: (error, stackTrace) {
            ErrorHandler.handleError(
              error,
              stackTrace: stackTrace,
              context: 'notificationBadgeListener',
            );
          },
        );
  }
}
