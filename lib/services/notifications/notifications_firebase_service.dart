import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:uuid/uuid.dart';

import '../../models/Notifications/notification_model.dart';
import '../../models/Notifications/user_notification_model.dart';
import '../../utils/app_strings.dart';

class FirebaseNotificationsService {
  static Future<List<NotificationModel>> getUserNotifications({
    required String type,
  }) async {
    try {
      final user = GlobalVariables.loggedInUser.value;
      if (user == null) return [];
      final List<UserNotificationModel> notification = await _getNotifications(
        type: type,
      );
      final userCreatedAt = user.createdAt?.toDate();
      if (userCreatedAt != null) {
        notification.removeWhere(
          (element) => element.createdAt.isBefore(userCreatedAt),
        );
      }
      final res = groupBy(
        notification,
        (p0) => p0.createdAt.toString().split(' ').first,
      );
      final ress =
          res.keys
              .map(
                (e) => NotificationModel(
                  date: DateTime.parse(e),
                  notifications: (res[e] ?? []).toList(),
                ),
              )
              .toList();
      ress.sort((a, b) => b.date.compareTo(a.date));
      return ress;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return [];
  }

  static Future<List<UserNotificationModel>> _getNotifications({
    required String type,
  }) async {
    final uid = GlobalVariables.loggedInUser.value?.uid;
    if (uid == null) return [];
    final result =
        await firestore
            .collection(kNotificationsCollection)
            .doc(uid)
            .collection(kNotificationsSubCollection)
            .where('sentTo', arrayContainsAny: ['All', uid])
            .get();
    final futures =
        result.docs.map((e) async {
          final UserNotificationModel us = UserNotificationModel.fromMap(
            e.data(),
          );
          if (us.notificationType == NotificationType.trip.status) {
            us.trip = await FirebaseTripService.getTripById(
              tripId: us.notificationForId,
            );
          }
          us.addedBy = await AuthService.getUserPublicProfile(
            userId: us.createdBy,
          );
          return us;
        }).toList();
    final res = await Future.wait(futures);
    res.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return res;
  }

  static Future<void> saveNotifications({
    required String message,
    required String title,
    bool? isLookBook,
    required List<String> sentTo,
    String? releaseDate,
    required String notificationForId,
    required String notificationType,
    bool isTopic = false,
    List<String> notificationTopic = const ['User loggedIn'],
  }) async {
    try {
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return;
      final UserNotificationModel userNotificationModel = UserNotificationModel(
        notificationId: const Uuid().v4(),
        notificationMessage: message,
        notificationTitle: title,
        notificationType: notificationType,
        notificationForId: notificationForId,
        createdAt: DateTime.now(),
        createdBy: uid,
        updateAt: DateTime.now(),
        updateBy: uid,
        sentTo: sentTo,
        isTopic: isTopic,
        releaseDate: releaseDate,
        notificationTopic: notificationTopic,
        isActive: true,
      );
      _saveNotification(userNotificationModel);
    } catch (e) {}
  }

  static Future<void> _saveNotification(
    UserNotificationModel notification,
  ) async {
    try {
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return;
      await firestore
          .collection(kNotificationsCollection)
          .doc(uid)
          .collection(kNotificationsSubCollection)
          .add(notification.toMap())
          .then((value) => value.update({'notificationId': value.id}));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<bool> updateNotification({
    required String notificationId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return false;
      await firestore
          .collection(kNotificationsCollection)
          .doc(uid)
          .collection(kNotificationsSubCollection)
          .doc(notificationId)
          .update(data);
      return true;
    } catch (e) {}
    return false;
  }
}
