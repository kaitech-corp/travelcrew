// Notification screen
import 'user_notification_model.dart';

class NotificationModel {
  NotificationModel({required this.date, required this.notifications});
  DateTime date;
  List<UserNotificationModel> notifications;
}
