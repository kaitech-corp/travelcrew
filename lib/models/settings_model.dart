

import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotificationSettingsData {
  final bool isDirectMessagingOn;
  final bool isPushNotificationsOn;
  final bool isTripChangeOn;
  final bool isTripChatOn;
  final Timestamp lastUpdated;

  UserNotificationSettingsData(
      {this.isTripChatOn,
      this.isPushNotificationsOn,
      this.isTripChangeOn,
      this.isDirectMessagingOn,
      this.lastUpdated
     });

  UserNotificationSettingsData.fromData(Map<String, dynamic> data)
      : isDirectMessagingOn = data['isDirectMessagingOn'] ?? true,
        isPushNotificationsOn = data['isPushNotificationsOn'] ?? true,
        isTripChangeOn = data['isTripChangeOn'] ?? true,
        isTripChatOn = data['isTripChatOn'] ?? true,
        lastUpdated = data['lastUpdated'] ?? Timestamp.now();

  Map<String, dynamic> toJson() {
    return {
      'isDirectMessagingOn': isDirectMessagingOn,
      'isPushNotificationsOn': isPushNotificationsOn,
      'isTripChangeOn': isTripChangeOn,
      'isTripChatOn': isTripChatOn,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  UserNotificationSettingsData fakerData(){
    return UserNotificationSettingsData(
      isTripChatOn: true,
      isTripChangeOn: true,
      isDirectMessagingOn: true,
      isPushNotificationsOn: true,
      lastUpdated: Timestamp.now()
    );
  }
}
