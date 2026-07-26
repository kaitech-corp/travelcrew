import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_strings.dart';

import '../../../../utils/app_styles.dart';
import '../../../custom_widgets/any_image_view.dart';
import '../controller/users_controller.dart';

class UsersWidget extends StatelessWidget {
  const UsersWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.tripModel,
    required this.subtitle,
    this.unreadCount = 0,
    required this.timestamp,
    required this.memberImages,
    this.extraMembers = 0,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final int unreadCount;
  final String timestamp;
  final TripModel tripModel;
  final List<String> memberImages;
  final int extraMembers;

  @override
  Widget build(BuildContext context) {
    final visibleExtraMembers = extraMembers > 0 ? extraMembers : 0;
    return GestureDetector(
      onTap: () async {
        late UsersController usersController;
        if (!Get.isRegistered<UsersController>()) {
          usersController = Get.put(UsersController());
        } else {
          usersController = Get.find<UsersController>();
        }
        usersController.currentTrip.value = tripModel;

        usersController.listenToChat();

        await Get.toNamed(kMessagesScreenRoute);
        await usersController.stopListeningToChat();
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.all(14.r),
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
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnyImageView(
                  url: imageUrl,
                  height: 58,
                  width: 58,
                  isCircle: true,
                  containerBackgroundColor: AppColors.kLightBlueColor,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.kPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: AppColors.kWhiteColor, width: 2),
                      ),
                    ),
                    child: const Icon(
                      Icons.forum_rounded,
                      size: 10,
                      color: AppColors.kWhiteColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.labelTextStyle().copyWith(
                                  color: AppColors.kBlackColor,
                                  fontSize: AppStyles.fontSize16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                margin: EdgeInsets.only(left: 6.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.kSecondaryColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: AppColors.kWhiteColor,
                                    fontSize: AppStyles.fontSize12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        timestamp,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: AppColors.kGreyyColor,
                          fontSize: AppStyles.fontSize12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: AppColors.kGreyyColor,
                      fontSize: AppStyles.fontSize13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _MemberPreviewStack(memberImages: memberImages),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          visibleExtraMembers > 0
                              ? '$visibleExtraMembers more travelers'
                              : 'Trip chat',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: AppColors.kBlackColor,
                            fontSize: AppStyles.fontSize12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.kGreyyColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberPreviewStack extends StatelessWidget {
  const _MemberPreviewStack({required this.memberImages});

  final List<String> memberImages;

  @override
  Widget build(BuildContext context) {
    final visibleMembers = memberImages.take(3).toList();
    return SizedBox(
      width: 62,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(visibleMembers.length, (index) {
          final left = index * 18.0;
          return Positioned(
            left: left,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.kWhiteColor, width: 2),
              ),
              child: AnyImageView(
                url: visibleMembers[index],
                height: 24,
                width: 24,
                isCircle: true,
                containerBackgroundColor: AppColors.kLightBlueColor,
              ),
            ),
          );
        }),
      ),
    );
  }
}
