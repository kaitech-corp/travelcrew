import 'package:get/get.dart';
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';
import 'package:travel_crew/utils/logger.dart';
import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';
import '../../utils/app_strings.dart';
import '../session_services.dart';
import 'notification_navigation.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  if (kDebugMode) {
    print('===========Title ${message.notification?.title}');
    print('===========Body: ${message.notification?.body}');
    print('===========Payload: ${message.data}');
  }
}

class FirebasePushNotificationApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  final callChannel = const AndroidNotificationChannel(
    'call_channel', // id
    'call_channel_notification', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,

    audioAttributesUsage: AudioAttributesUsage.voiceCommunication,
  );
  void handleMessage(RemoteMessage? message) {
    if (kDebugMode) {
      print('=========handleMessage:: $message');
    }
    if (message == null) return;

    NotificationNavigation.receive(message.data);
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  void showProgressNotification(
    int progress,
    int id, {
    String? title,
    String? subTitle,
  }) {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'upload_channel',
      'Upload Channel',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    flutterLocalNotificationsPlugin.show(
      id: id,
      title: title ?? 'Uploading File',
      body: '${subTitle ?? ''} progress:$progress%',
      notificationDetails: platformChannelSpecifics,
    );
  }

  void showCompletionNotification({int id = 0}) {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'upload_channel',
      'Upload Channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    flutterLocalNotificationsPlugin.show(
      id: id,
      title: 'Upload complete',
      body: 'Your file has been uploaded successfully.',
      notificationDetails: platformChannelSpecifics,
    );

    // Auto hide notification after 3 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      await flutterLocalNotificationsPlugin.cancel(id: id);
    });
  }

  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) async {
      if (message.data['recipientUid'] != null &&
          message.data['recipientUid'] != GlobalVariables.currentUid) {
        return;
      }
      if (message.data['type'] == 'Chat' &&
          Get.currentRoute == kMessagesScreenRoute &&
          Get.isRegistered<UsersController>() &&
          Get.find<UsersController>().roomId ==
              message.data['notificationForId']) {
        return;
      }
      final notification = message.notification;
      if (notification == null) return;

      await flutterLocalNotificationsPlugin.show(
        id:
            message.notification?.body == 'Incomming video call' ||
                    message.notification?.body == 'Incomming voice call'
                ? 1
                : notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          iOS: const DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            audioAttributesUsage: AudioAttributesUsage.voiceCommunication,

            fullScreenIntent:
                message.notification?.body == 'Incomming video call' ||
                        message.notification?.body == 'Incomming voice call'
                    ? true
                    : false,
            androidChannel.id,
            androidChannel.name,
            importance: Importance.high,
            channelDescription: androidChannel.description,
            icon: '@drawable/tc_logo',
            showProgress: false,
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future initLocalNotifications() async {
    const ios = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const android = AndroidInitializationSettings('@drawable/tc_logo');
    const settings = InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveBackgroundNotificationResponse: backGroundResponse,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload?.isNotEmpty != true) return;
        try {
          handleMessage(
            RemoteMessage.fromMap(
              jsonDecode(response.payload!) as Map<String, dynamic>,
            ),
          );
        } catch (_) {
          /* Upload progress alerts have no navigation payload. */
        }
      },
    );
    final launch =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true &&
        payload?.isNotEmpty == true) {
      try {
        handleMessage(
          RemoteMessage.fromMap(jsonDecode(payload!) as Map<String, dynamic>),
        );
      } catch (_) {}
    }
    final platfrom =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await platfrom?.createNotificationChannel(androidChannel);
    await platfrom?.createNotificationChannel(callChannel);
  }

  Future<String> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await requestNotificationPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    await saveTokenForCurrentUser(fcmToken);
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenForCurrentUser);
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    await initPushNotifications();
    await initLocalNotifications();
    return fcmToken ?? '';
  }

  Future<void> removeTokenForCurrentUser() async {
    final uid = GlobalVariables.currentUid;
    if (uid.isEmpty) return;
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await firestore
            .collection(kFcmTokensCollection)
            .doc(uid)
            .collection(kFcmTokensCollection)
            .doc(token)
            .delete();
      }
      await _firebaseMessaging.deleteToken();
    } catch (error) {
      AppLogger.warning('Unable to remove push token: $error');
    }
  }

  Future<void> saveTokenForCurrentUser([String? token]) async {
    final uid = GlobalVariables.loggedInUser.value?.uid;
    if (uid == null || uid.isEmpty) return;
    final currentToken = token ?? await _firebaseMessaging.getToken();
    if (currentToken == null || currentToken.isEmpty) return;
    await firestore
        .collection(kFcmTokensCollection)
        .doc(uid)
        .collection(kFcmTokensCollection)
        .doc(currentToken)
        .set({
          'token': currentToken,
          'platform': defaultTargetPlatform.name,
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }
}

@pragma('vm:entry-point')
void backGroundResponse(NotificationResponse response) {
  // Navigation is handled in the main isolate by the launch-details callback.
}
