import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/models/Notifications/notification_model.dart';
import 'package:travel_crew/models/Notifications/user_notification_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/custom_widgets/read_more_text.dart';
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';
import 'package:travel_crew/views/messages/users/widget/users_widget.dart';
import 'package:travel_crew/views/notification/controller/notification_controller.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: CustomScaffold(
        screenName: 'Inbox',
        centerTitle: true,
        isBackIcon: false,
        scaffoldKey: _scaffoldKey,
        className: 'InboxScreen',
        body: Column(
          children: [
            TabBar(
              labelColor: AppColors.kPrimaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.kPrimaryColor,
              tabs: [Tab(text: l10n.messages), Tab(text: l10n.notifications)],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MessagesTab(l10n: l10n),
                  _NotificationsTab(l10n: l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    return Column(
      children: [
        SizedBox(height: 12.h),
        TextField(
          style: AppStyles.labelTextStyle().copyWith(
            fontSize: AppStyles.fontSize14,
            color: const Color(0xFF333333),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintText: l10n.search,
            hintStyle: AppStyles.labelTextStyle().copyWith(
              color: const Color(0xFF9C9FA3),
              fontSize: AppStyles.fontSize13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(42),
              borderSide: const BorderSide(
                width: 0.52,
                color: Color(0xFFD2D5D9),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(42),
              borderSide: const BorderSide(
                width: 0.52,
                color: Color(0xFFD2D5D9),
              ),
            ),
            isDense: true,
            prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
          ),
        ),
        SizedBox(height: 10.h),
        Expanded(
          child: Obx(
            () =>
                controller.isLoadingChats.isTrue
                    ? const Center(child: CircularProgressIndicator())
                    : controller.chatRooms.isEmpty
                    ? Center(child: Text(l10n.noChatsFound))
                    : ListView.separated(
                      itemCount: controller.chatRooms.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final room = controller.chatRooms[index];
                        return UsersWidget(
                          imageUrl: room.trip?.images.first ?? '',
                          tripModel: room.trip!,
                          title: room.trip?.title ?? '',
                          subtitle:
                              '${DateFormat('dd MMM').format(room.trip?.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(room.trip?.tripEndDate ?? DateTime.now())}',
                          timestamp: DateFormat(
                            'dd MMM, hh:mma',
                          ).format(room.updatedAt.toDate()),
                          memberImages:
                              room.users
                                  .map((e) => e.profileImage.toString())
                                  .toList(),
                          extraMembers: 4,
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.builder(
          itemCount: 8,
          itemBuilder:
              (_, _) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListTile(
                  title: Container(height: 10, color: Colors.white),
                  subtitle: Container(height: 10, color: Colors.white),
                ),
              ),
        );
      }
      if (controller.notifications.isEmpty) {
        return Center(child: Text(l10n.noNotificationsFound));
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: controller.notifications.length,
        itemBuilder: (context, i) {
          final NotificationModel group = controller.notifications[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                child: Text(
                  DateFormat('dd MMM, yyyy').format(group.date),
                  style: AppStyles.labelTextStyle().copyWith(
                    fontSize: AppStyles.fontSize12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.notifications.length,
                itemBuilder: (context, j) {
                  final UserNotificationModel n = group.notifications[j];
                  return ListTile(
                    leading: _notificationImage(n),
                    title: Text(
                      n.notificationTitle,
                      style: AppStyles.labelTextStyle().copyWith(
                        fontSize: AppStyles.fontSize13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: ReadMoreTextWidget(
                      textStyle: AppStyles.labelTextStyle().copyWith(
                        color: AppColors.kBlackColor.withValues(alpha: .5),
                        fontSize: AppStyles.fontSize12,
                      ),
                      text: n.notificationMessage,
                    ),
                    onTap: () {
                      if (n.trip != null) {
                        Get.toNamed(
                          kSpecificTripViewScreenRoute,
                          arguments: n.trip,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          );
        },
      );
    });
  }

  Widget _notificationImage(UserNotificationModel n) {
    final url =
        n.notificationType == NotificationType.trip.status
            ? n.trip?.images.first ?? ''
            : n.addedBy?.profileImage ?? '';
    return AnyImageView(url: url, height: 44, width: 44, isCircle: true);
  }
}
