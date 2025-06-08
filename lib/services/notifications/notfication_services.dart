import 'dart:async';
import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('===========Title ${message.notification?.title}');
  print('===========Body: ${message.notification?.body}');
  print('===========Payload: ${message.data}');
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
    playSound: true,

    audioAttributesUsage: AudioAttributesUsage.voiceCommunication,
    enableVibration: true,
    showBadge: true,
  );
  void handleMessage(RemoteMessage? message) {
    print('=========handleMessage:: $message');
    if (message == null) return;

    // Get.toNamed(kSplashScreenRoute, arguments: message);
  }

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
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
                message.notification?.body == "Incomming voice call"
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
                        message.notification?.body == "Incomming voice call"
                    ? true
                    : false,
            androidChannel.id,
            androidChannel.name,
            playSound: true,
            importance: Importance.high,
            channelDescription: androidChannel.description,
            // TODO add a proper drawable resource to android, for now using
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
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    const settings = InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: backGroundResponse,
      onDidReceiveNotificationResponse: (response) {
        final message = RemoteMessage.fromMap(
          jsonDecode(response.payload ?? ""),
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
    return fcmToken ?? "";
  }
}

backGroundResponse(response) {
  final message = RemoteMessage.fromMap(jsonDecode(response.payload ?? ""));
}

Future<bool> sendPushMessage({
  required String title,
  required String body,
}) async {
  String token = userDeviceToken;
  if (token.isEmpty) {
    print('Unable to send FCM message, no token exists.');
    return false;
  }

  final jsonCredentials = await rootBundle.loadString(
    'assets/travelcrew_auth.json',
  );
  final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

  final client = await auth.clientViaServiceAccount(creds, [
    'https://www.googleapis.com/auth/cloud-platform',
  ]);

  final notificationData = {
    'message': {
      'token': token,
      'notification': {'title': title, 'body': body},
    },
  };

  final response = await client.post(
    Uri.parse('https://fcm.googleapis.com/v1/projects/$senderId/messages:send'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode(notificationData),
  );

  client.close();
  if (response.statusCode == 200) {
    return true; // Success!
  }

  devtools.log(
    'Notification Sending Error Response status: ${response.statusCode}',
  );
  debugPrint(
    'Notification Sending Error Response status: ${response.statusCode}',
  );
  devtools.log('Notification Response body: ${response.body}');
  debugPrint('Notification Response body: ${response.body}');
  return false;
}

const String senderId = '101337609697';

Future<bool> sendPushMessageToTopic({
  required String title,
  required String body,
  required String topic,
  String? roomId,
}) async {
  final jsonCredentials = await rootBundle.loadString(
    'assets/travelcrew_auth.json',
  );
  final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

  final client = await auth.clientViaServiceAccount(creds, [
    'https://www.googleapis.com/auth/cloud-platform',
  ]);

  final notificationData = {
    'message': {
      // 'token': _token,
      "topic": topic,
      'notification': {'title': title, 'body': body},
      // 'data': {
      //   'roomId': roomId,
      //   if (roomId != null) ...{
      //     'profileImage': SessionServices.loggedInUser.value!.profileImage,
      //     'fullName': SessionServices.loggedInUser.value!.userName,
      //     'userId': SessionServices.loggedInUser.value!.userId,
      //   }
      // }
    },
  };

  final response = await client.post(
    Uri.parse('https://fcm.googleapis.com/v1/projects/$senderId/messages:send'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode(notificationData),
  );

  client.close();
  if (response.statusCode == 200) {
    return true; // Success!
  }

  devtools.log(
    'Notification Sending Error Response status: ${response.statusCode}',
  );
  debugPrint(
    'Notification Sending Error Response status: ${response.statusCode}',
  );
  devtools.log('Notification Response body: ${response.body}');
  debugPrint('Notification Response body: ${response.body}');
  return false;
}

// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token, String title, String body) {
  print('=========inside payload');
  _messageCount++;
  return jsonEncode({
    // 'token': token,
    'priority': 'high',
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': title, //'Hello FlutterFire!',
      'body':
          body, //'This notification (#$_messageCount) was created via FCM!',
    },
    'to': token,
  });
}
