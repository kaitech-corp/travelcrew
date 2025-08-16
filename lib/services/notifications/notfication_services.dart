import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';

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
    if (kDebugMode){print('=========handleMessage:: $message');}
    if (message == null) return;

    // Get.toNamed(kSplashScreenRoute, arguments: message);
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
      id,
      title ?? 'Uploading File',
      '${subTitle ?? ''} progress:$progress%',
      platformChannelSpecifics,
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
      id,
      'Upload complete',
      'Your file has been uploaded successfully.',
      platformChannelSpecifics,
    );

    // Auto hide notification after 3 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      await flutterLocalNotificationsPlugin.cancel(id);
    });
  }

  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification == null) return;

      await flutterLocalNotificationsPlugin.show(
        message.notification?.body == 'Incomming video call' ||
                message.notification?.body == 'Incomming voice call'
            ? 1
            : notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
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
            // TODOadd a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@mipmap/ic_launcher',
            showProgress: true,
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
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: backGroundResponse,
      onDidReceiveNotificationResponse: (response) {
        final message = RemoteMessage.fromMap(
          jsonDecode(response.payload ?? '') as Map<String, dynamic>,
        );

        handleMessage(message);
      },
    );
    final platfrom =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await platfrom?.createNotificationChannel(androidChannel);
    await platfrom?.createNotificationChannel(callChannel);
  }

  Future<String> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    await initPushNotifications();
    await initLocalNotifications();
    return fcmToken ?? '';
  }
}

void backGroundResponse(response) {
  // final message =
  RemoteMessage.fromMap(jsonDecode((response.payload as String?) ?? '') as Map<String, dynamic>);
}
