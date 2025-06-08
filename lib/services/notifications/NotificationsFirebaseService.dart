import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
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
      List<UserNotificationModel> notification = await _getNotifications(
        type: type,
      );
      notification.removeWhere(
        (element) => element.createdAt.isBefore(
          GlobalVariables.loggedInUser.value!.createdAt.toDate(),
        ),
      );
      var res = groupBy(
        notification,
        (p0) => p0.createdAt.toString().split(' ').first,
      );
      var ress =
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
      print(e);
    }
    return [];
  }

  static Future<List<UserNotificationModel>> _getNotifications({
    required String type,
  }) async {
    var result =
        await FirebaseFirestore.instance
            .collection(kNotificationsCollection)
            .where(
              'sentTo',
              arrayContainsAny: ['All', GlobalVariables.loggedInUser.value!.id],
            )
            .get();
    var futures =
        result.docs.map((e) async {
          UserNotificationModel us = UserNotificationModel.fromMap(e.data());
          if (us.notificationType == NotificationType.trip.status) {
            us.trip = await FirebaseTripService.getTripById(
              tripId: us.notificationForId,
            );
          }
          us.addedBy = await AuthService.getUser(userId: us.createdBy);
          return us;
        }).toList();
    var res = await Future.wait(futures);
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
      UserNotificationModel userNotificationModel = UserNotificationModel(
        notificationId: const Uuid().v4(),
        notificationMessage: message,
        notificationTitle: title,
        notificationType: notificationType,
        notificationForId: notificationForId,
        createdAt: DateTime.now(),
        createdBy: GlobalVariables.loggedInUser.value!.id,
        updateAt: DateTime.now(),
        updateBy: GlobalVariables.loggedInUser.value!.id,
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
      await FirebaseFirestore.instance
          .collection(kNotificationsCollection)
          .add(notification.toMap())
          .then((value) => value.update({'notificationId': value.id}));
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> updateNotification({
    required String notificationId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(kNotificationsCollection)
          .doc(notificationId)
          .update(data);
      return true;
    } catch (e) {}
    return false;
  }
}
