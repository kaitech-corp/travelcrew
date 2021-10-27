
import 'package:notification_permissions/notification_permissions.dart';

class SettingsNotifications {

  /// Return responses PermissionStatus
  ///   provisional, // iOS Only
  /// 	granted,
  /// 	unknown,
  /// 	denied
  /// iOS, a permission is unknown when the user hasn’t accepted or refuse the notification permissions
  ///
  ///Check permission status for notifications
  Future<bool> permissionStatus() async {
    return NotificationPermissions.getNotificationPermissionStatus().then((value) {
      if(value == PermissionStatus.granted){
        return true;
      } else{
        return false;
      }
    });
  }

  ///Request permission if permission is not granted.
  Future<PermissionStatus> requestPermission() {
    return NotificationPermissions.requestNotificationPermissions(
        iosSettings: const NotificationSettingsIos(
            sound: true, badge: true, alert: true),openSettings: true
        );
  }
}