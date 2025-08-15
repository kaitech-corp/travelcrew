import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/utils/app_colors.dart';

import '../../models/Notifications/notification_model.dart';
import '../../models/Notifications/user_notification_model.dart';
import '../../utils/app_styles.dart';
import '../custom_widgets/any_image_view.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../custom_widgets/read_more_text.dart';
import 'controller/notification_controller.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      centerTitle: true,
      className: runtimeType.toString(),
      screenName: l10n.notifications,
      scaffoldKey: controller.scaffoldKey,
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListTile(
                  title: Container(
                    width: double.infinity,
                    height: 10.0,
                    color: Colors.white,
                  ),
                  subtitle: Container(
                    width: double.infinity,
                    height: 10.0,
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        } else {
          return controller.notifications.isEmpty
              ? Center(child: Text(l10n.noNotificationsFound))
              : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.notifications.length,
                shrinkWrap: true,
                itemBuilder: (context, indexx) {
                  NotificationModel notificationModel =
                      controller.notifications[indexx];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat(
                          'dd MMM, yyyy',
                        ).format(notificationModel.date),
                      ),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notificationModel.notifications.length,
                        itemBuilder: (context, index) {
                          UserNotificationModel notification =
                              notificationModel.notifications[index];
                          return ListTile(
                            title: Text(notification.notificationTitle),
                            leading: getImageUrl(notification),
                            subtitle: ReadMoreTextWidget(
                              trimLines: 2,
                              textStyle: AppStyles.labelTextStyle().copyWith(
                                color: AppColors.kBlackColor.withValues(
                                  alpha: .5,
                                ),
                              ),
                              text: notification.notificationMessage,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
        }
      }),
    );
  }

  Widget getImageUrl(UserNotificationModel notification) {
    if (notification.notificationType == NotificationType.trip.status) {
      return AnyImageView(
        url: notification.trip?.images.first ?? '',
        height: 80,
        width: 80,
        isCircle: false,
      );
    } else {
      return AnyImageView(
        url: notification.addedBy?.urlToImage ?? '',
        height: 80,
        width: 80,
        isCircle: false,
      );
    }
  }
}
