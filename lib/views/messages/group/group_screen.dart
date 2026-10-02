import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/messages/group/controller/group_controller.dart';
import 'package:travel_crew/views/messages/users/widget/users_widget.dart';

import '../../custom_widgets/custom_scaffold.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final GroupController controller = Get.put(GroupController());
    return CustomScaffold(
      screenName: 'Messages',
      isBackIcon: false,
      scaffoldKey: _scaffoldKey,
      centerTitle: true,
      className: 'Group',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Trips with chat',
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Open a trip to catch up with the group, check dates, and jump back into the conversation.',
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors.kGreyyColor,
                fontSize: AppStyles.fontSize13,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: Obx(
              () {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.chatRooms.isEmpty) {
                  return _EmptyGroupsState();
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = controller.chatRooms[index];
                    return _GroupTile(chatRoom: chatRoom);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.chatRoom});

  final ChatRoom chatRoom;

  @override
  Widget build(BuildContext context) {
    final trip = chatRoom.trip;
    if (trip == null) {
      return const SizedBox.shrink();
    }
    final subtitle =
        '${DateFormat('dd MMM').format(trip.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(trip.tripEndDate ?? DateTime.now())}';
    final totalMembers = 1 + (trip.joinedUsers?.length ?? 0);
    final extraMembers = totalMembers > 3 ? totalMembers - 3 : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: UsersWidget(
        imageUrl: trip.images.first,
        tripModel: trip,
        title: trip.title ?? '',
        subtitle: subtitle,
        timestamp: DateFormat('dd MMM, hh:mma').format(chatRoom.updatedAt.toDate()),
        memberImages: chatRoom.users.map((e) => e.profileImage).toList(),
        extraMembers: extraMembers,
      ),
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.kLightBlueColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.kPrimaryColor,
                size: 38,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No trip chats yet',
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Once you join or create a trip, its group chat will appear here.',
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors.kGreyyColor,
                fontSize: AppStyles.fontSize14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
