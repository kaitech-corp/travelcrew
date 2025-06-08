// import 'dart:convert';

// import 'package:http/http.dart' as http;

// import '../../utils/app_strings.dart';

// Future<void> scheduleNotification({
//   required String title,
//   required String body,
//   required List<String> topics,
//   required DateTime scheduledTime,
// }) async {
//   const String url = 'https://onesignal.com/api/v1/notifications';
//   const String apiKey = kOneSignalApiKey;

//   final Map<String, dynamic> notificationData = {
//     'app_id': kOneSignalAppId,
//     'included_segments': topics,
//     'headings': {'en': title},
//     'contents': {'en': body},
//     'send_after': scheduledTime.toUtc().toIso8601String(),
//   };

//   final response = await http.post(
//     Uri.parse(url),
//     headers: {
//       'Content-Type': 'application/json; charset=utf-8',
//       'Authorization': 'Basic $apiKey',
//     },
//     body: jsonEncode(notificationData),
//   );

//   if (response.statusCode == 200) {
//     print('Notification scheduled successfully');
//   } else {
//     print('Failed to schedule notification: ${response.body}');
//   }
// }

// sendPushNotificationToTag({
//   required String tag,
//   required String title,
//   required String body,
// }) async {
//   const String url = 'https://onesignal.com/api/v1/notifications';
//   const String apiKey = kOneSignalApiKey;
//   final Map<String, dynamic> notificationData = {
//     'app_id': kOneSignalAppId,
//     'filters': [
//       {'field': 'tag', 'key': 'tag', 'relation': '=', 'value': tag},
//     ],
//     'headings': {'en': title},
//     'contents': {'en': body},
//   };

//   final response = await http.post(
//     Uri.parse(url),
//     headers: {
//       'Content-Type': 'application/json; charset=utf-8',
//       'Authorization': 'Basic $apiKey',
//     },
//     body: jsonEncode(notificationData),
//   );

//   if (response.statusCode == 200) {
//     print('Notification sent to tag successfully');
//   } else {
//     print('Failed to send notification to tag: ${response.body}');
//   }
// }

// sendPushNotificationToUser({
//   required String userId,
//   required String title,
//   required String body,
// }) async {
//   const String url = 'https://onesignal.com/api/v1/notifications';
//   const String apiKey = kOneSignalApiKey;
//   final Map<String, dynamic> notificationData = {
//     'app_id': kOneSignalAppId,
//     'include_external_user_ids': [userId],
//     'headings': {'en': title},
//     'contents': {'en': body},
//   };

//   final response = await http.post(
//     Uri.parse(url),
//     headers: {
//       'Content-Type': 'application/json; charset=utf-8',
//       'Authorization': 'Basic $apiKey',
//     },
//     body: jsonEncode(notificationData),
//   );

//   if (response.statusCode == 200) {
//     print('Notification sent successfully');
//   } else {
//     print('Failed to send notification: ${response.body}');
//   }
// }
