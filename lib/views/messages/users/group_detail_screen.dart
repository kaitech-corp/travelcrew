import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';

import '../../custom_widgets/any_image_view.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/text_widget.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final UsersController controller = Get.find<UsersController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller.currentTrip.value = Get.arguments;
    controller.getUsersDetail();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      className: widget.runtimeType.toString(),
      screenName: '',
      appBarSize: 70.h,
      title: Obx(
        () => Row(
          children: [
            AnyImageView(
              url: controller.currentTrip.value?.images.first ?? '',
              height: 52.h,
              width: 52.w,
              isCircle: true,
              containerBackgroundColor: AppColors.kLightBlueColor,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    labelText: controller.currentTrip.value?.title ?? '',
                    textAlign: TextAlign.start,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: AppColors.kBlackColor,
                      fontSize: AppStyles.fontSize16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        AppImages.kCalendarIcon,
                        color: AppColors.kGreyyColor,
                        scale: 7,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: TextWidget(
                          labelText:
                              '${DateFormat('dd MMM').format(controller.currentTrip.value?.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(controller.currentTrip.value?.tripEndDate ?? DateTime.now())}',
                          textAlign: TextAlign.start,
                          style: AppStyles.labelTextStyle().copyWith(
                            color: AppColors.kGreyyColor,
                            fontSize: AppStyles.fontSize13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      padding: EdgeInsets.zero,
      scaffoldKey: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.kLightGreyColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Obx(
                () {
                  final trip = controller.currentTrip.value;
                  final memberCount =
                      1 + (controller.tripUsers.length);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              color: AppColors.kLightBlueColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              color: AppColors.kPrimaryColor,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip?.title ?? 'Trip chat members',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    fontSize: AppStyles.fontSize18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '$memberCount people in this chat',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: AppColors.kGreyyColor,
                                    fontSize: AppStyles.fontSize13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _InfoChip(
                            icon: Icons.date_range_rounded,
                            text:
                                '${DateFormat('dd MMM').format(trip?.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(trip?.tripEndDate ?? DateTime.now())}',
                          ),
                          _InfoChip(
                            icon: Icons.location_on_outlined,
                            text: trip?.destination ?? 'Trip destination',
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Members',
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Obx(
              () =>
                  controller.isLoadingUsers.isTrue
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                        itemCount: controller.tripUsers.length + 1,
                        itemBuilder: (context, index) {
                          final member =
                              index == 0
                                  ? controller.currentTrip.value!.createdByUser
                                  : controller.tripUsers[index - 1];
                          if (member == null) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppColors.kWhiteColor,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: AppColors.kLightGreyColor,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: AnyImageView(
                                  url: member.profileImage ?? '',
                                  height: 50.h,
                                  width: 50.w,
                                  isCircle: true,
                                  containerBackgroundColor:
                                      AppColors.kLightBlueColor,
                                ),
                                title: Text(
                                  member.displayName,
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: AppColors.kBlackColor,
                                    fontSize: AppStyles.fontSize15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  member.uid ==
                                          controller.currentTrip.value?.createdBy
                                      ? 'Trip creator'
                                      : 'Trip member',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: AppColors.kGreyyColor,
                                    fontSize: AppStyles.fontSize12,
                                  ),
                                ),
                                trailing:
                                    member.uid ==
                                            controller.currentTrip.value
                                                ?.createdBy
                                        ? Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.kLightBlueColor,
                                            borderRadius:
                                                BorderRadius.circular(20.r),
                                          ),
                                          child: Text(
                                            'Admin',
                                            style:
                                                AppStyles.labelTextStyle()
                                                    .copyWith(
                                                      color:
                                                          AppColors
                                                              .kPrimaryColor,
                                                      fontSize:
                                                          AppStyles.fontSize12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                          ),
                                        )
                                        : GlobalVariables.loggedInUser.value!.uid ==
                                            controller.currentTrip.value!.createdBy
                                        ? InkWell(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: const Text(
                                                      'Remove User',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to remove from group?',
                                                      style: TextStyle(
                                                        fontSize:
                                                            AppStyles
                                                                .fontSize16,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Get.back(),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          controller.leaveGroup(
                                                            userId: member.uid,
                                                          );
                                                          Get.back();
                                                        },
                                                        child: const Text(
                                                          'Remove',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                          child: const Icon(Icons.more_vert),
                                        )
                                        : null,
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
          if (controller.currentTrip.value != null &&
              !GlobalVariables.isLoggedInUser(
                controller.currentTrip.value!.createdBy,
              ) &&
              (controller.currentTrip.value!.joinedUsers ?? const [])
                  .contains(GlobalVariables.currentUid))
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Leave Group'),
                          content: Text(
                            'Are you sure you want to leave this group?',
                            style: TextStyle(fontSize: AppStyles.fontSize16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.leaveGroup();
                                Get.back();
                              },
                              child: const Text('Leave'),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Leave Group',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: const Color(0xFFDA2828),
                    fontSize: AppStyles.fontSize13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 24.w,
                  ),
                  side: const BorderSide(color: Colors.red),
                  backgroundColor: Colors.red.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.kLightBlueColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.kPrimaryColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: AppStyles.labelTextStyle().copyWith(
              color: AppColors.kPrimaryColor,
              fontSize: AppStyles.fontSize12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
