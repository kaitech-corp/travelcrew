import 'package:get/get.dart';
import 'package:travel_crew/services/notifications/notifications_firebase_service.dart';

import '../../../models/Notifications/notification_model.dart';
import '../../../utils/error_handler.dart';

class NotificationController extends GetxController {
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Perform initialization tasks here
    getNotification();
  }

  Future<void> getNotification() async {
    try {
      isLoading.value = true;
      notifications.value =
          await FirebaseNotificationsService.getUserNotifications(type: '');
    } catch (e, stackTrace) {
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'getNotification',
      );
    }
    isLoading.value = false;
  }
}
