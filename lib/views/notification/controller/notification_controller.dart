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
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _badgeSubscription;
  Worker? _userWorker;
  String? _listeningUid;

  @override
  void onInit() {
    super.onInit();
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
    _userWorker?.dispose();
    _badgeSubscription?.cancel();
    super.onClose();
  }

  Future<void> getNotification() async {
    try {
      final user = GlobalVariables.loggedInUser.value;
      if (user == null) {
        notifications.clear();
        isLoading.value = false;
        return;
      }

      isLoading.value = true;
      notifications.value =
          await FirebaseNotificationsService.getUserNotifications(type: '');
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
    final updated = await FirebaseNotificationsService.markAllNotificationsAsRead(
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
    unawaited(_badgeSubscription?.cancel());
    _badgeSubscription = null;

    if (uid == null || uid.isEmpty) {
      unreadCount.value = 0;
      unawaited(NotificationBadgeService.clear());
      return;
    }

    _badgeSubscription =
        firestore
            .collection(kNotificationsCollection)
            .doc(uid)
            .collection(kNotificationsSubCollection)
            .snapshots()
            .listen(
              (snapshot) async {
                final userCreatedAt =
                    GlobalVariables.loggedInUser.value?.createdAt?.toDate();
                final count = snapshot.docs
                    .map((doc) => UserNotificationModel.fromMap(doc.data()))
                    .where((notification) {
                      if (userCreatedAt != null &&
                          notification.createdAt.isBefore(userCreatedAt)) {
                        return false;
                      }
                      return notification.isUnread;
                    })
                    .length;
                unreadCount.value = count;
                await NotificationBadgeService.setCount(count);
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
