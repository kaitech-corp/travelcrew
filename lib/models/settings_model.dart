import 'package:cloud_firestore/cloud_firestore.dart';

///Model for user settings
class UserNotificationSettingsData {
  UserNotificationSettingsData(
      {this.isTripChatOn,
      this.isPushNotificationsOn,
      this.isTripChangeOn,
      this.isDirectMessagingOn,
      this.lastUpdated});

  UserNotificationSettingsData.fromData(Map<String, dynamic> data)
      : isDirectMessagingOn = data['isDirectMessagingOn'] as bool,
        isPushNotificationsOn = data['isPushNotificationsOn'] as bool,
        isTripChangeOn = data['isTripChangeOn'] as bool,
        isTripChatOn = data['isTripChatOn'] as bool,
        lastUpdated = data['lastUpdated'] as Timestamp;

  final bool? isDirectMessagingOn;
  final bool? isPushNotificationsOn;
  final bool? isTripChangeOn;
  final bool? isTripChatOn;
  final Timestamp? lastUpdated;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isDirectMessagingOn': isDirectMessagingOn,
      'isPushNotificationsOn': isPushNotificationsOn,
      'isTripChangeOn': isTripChangeOn,
      'isTripChatOn': isTripChatOn,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  UserNotificationSettingsData fakerData() {
    return UserNotificationSettingsData(
        isTripChatOn: true,
        isTripChangeOn: true,
        isDirectMessagingOn: true,
        isPushNotificationsOn: true,
        lastUpdated: Timestamp.now());
  }
}
