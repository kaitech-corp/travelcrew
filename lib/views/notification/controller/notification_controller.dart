import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/Notifications/notification_model.dart';
import '../../../services/notifications/NotificationsFirebaseService.dart';

class NotificationController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  onInit() {
    super.onInit();
    // Perform initialization tasks here
    getNotification();
  }

  getNotification() async {
    try {
      isLoading.value = true;
      notifications.value =
          await FirebaseNotificationsService.getUserNotifications(type: '');
    } catch (e) {
      print(e);
    }
    isLoading.value = false;
  }
}
