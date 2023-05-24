import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../../models/settings_model/settings_model.dart';
import '../../../../services/database.dart';
import '../../../../services/notifications/notifications.dart';

final CollectionReference<Object?> settingsCollection =
    FirebaseFirestore.instance.collection('settings');
final CollectionReference<Object?> notificationCollection =
    FirebaseFirestore.instance.collection('notifications');

///Checks current users saved Settings for on their device.
Future<SettingsModel> getUserNotificationSettings() async {
  final DocumentSnapshot<Object?> ref =
      await notificationCollection.doc(userService.currentUserID).get();
  if (ref.exists) {
    final Map<String, dynamic> settings = ref.data()! as Map<String, dynamic>;
    return SettingsModel.fromJson(settings);
  } else {
    final bool status = await SettingsNotifications().permissionStatus();
    settingsCollection
        .doc(userService.currentUserID)
        .update(SettingsModel(
          isPushNotificationsOn: status,
          isDirectMessagingOn: true,
          isTripChangeOn: true,
          isTripChatOn: true,
        ).toJson());
    return null;
  }
}

void changeDMSettings(bool response) {
  settingsCollection.doc(userService.currentUserID).update(<String, dynamic>{
    'isDirectMessagingOn': response,
  });
}

void changeTripNotificationSettings(bool response) {
  settingsCollection.doc(userService.currentUserID).update(<String, dynamic>{
    'isTripChangeOn': response,
  });
}

void changeTripChatNotificationSettings(bool response) {
  settingsCollection.doc(userService.currentUserID).update(<String, dynamic>{
    'isTripChatOn': response,
  });
}
