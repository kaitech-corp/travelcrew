import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';

import '../../../../../services/session_services.dart';
import '../../../../../utils/app_strings.dart';
import '../../../../../utils/app_styles.dart';
import '../../../../custom_widgets/like_widget.dart';
import '../controller/specific_trip_view_controller.dart';

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key, required this.controller});
  final SpecificTripViewController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder:
              (c, index) => Obx(
                () => ActivityWidget(
                  controller: controller,
                  isLiked: (controller
                              .tripModel
                              .value
                              ?.activities?[index]
                              .likedBy ??
                          [])
                      .contains(GlobalVariables.loggedInUser.value?.uid),
                  onLiked: () {
                    controller.likeActivity(
                      isLiked: (controller
                                  .tripModel
                                  .value
                                  ?.activities?[index]
                                  .likedBy ??
                              [])
                          .contains(GlobalVariables.loggedInUser.value?.uid),
                      activityId:
                          controller.tripModel.value?.activities?[index].id ??
                          '',
                    );
                  },
                  likesCount:
                      controller
                          .tripModel
                          .value
                          ?.activities?[index]
                          .likesCount ??
                      0,
                  timing:
                      '${DateFormat('hh:mm a').format(controller.tripModel.value?.activities?[index].startDateTime ?? DateTime.now())} - ${DateFormat('hh:mm a').format(controller.tripModel.value?.activities?[index].endDateTime ?? DateTime.now())}',

                  index: index,
                  title:
                      controller.tripModel.value?.activities?[index].title ??
                      '',
                  description:
                      controller
                          .tripModel
                          .value
                          ?.activities?[index]
                          .description,
                ),
              ),
          separatorBuilder: (c, index) => SizedBox(height: 10.h),
          itemCount: controller.tripModel.value?.activities?.length ?? 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: () {
            Get.toNamed(
              kAddActivityScreenRoute,
              arguments: {
                'toAdd': true,
                'tripId': controller.tripModel.value?.id,
                'onAdded': (ActivityModel activityId) {
                  controller.tripModel.value?.activities?.add(activityId);
                  controller.tripModel.refresh();
                },
              },
            );
          },
          child: Container(
            width: 155.23.w,
            padding: EdgeInsets.symmetric(
              horizontal: 17.44.w,
              vertical: 15.70.h,
            ),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0x261D7FC2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(41.86),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6.98,
              children: [
                const Icon(Icons.add, size: 20, color: Color(0xFF1D7FC2)),
                Text(
                  'Add Activity',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: const Color(0xFF1D7FC2),
                    fontSize: AppStyles.fontSize13,

                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({
    super.key,
    required this.index,
    this.isLiked = false,
    this.timing = '11:45 - 12:00 pm',
    this.onLiked,
    this.likesCount = 20,
    this.onDelete,
    this.controller,
    this.title,
    this.description,
  });
  final Function()? onLiked;
  final SpecificTripViewController? controller;
  final String? title;
  final bool isLiked;
  final int index;
  final String? description;
  final int likesCount;
  final String timing;
  final Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: controller != null ? double.infinity : context.width * 0.8,
          padding: EdgeInsets.only(
            top: 12.13.r,
            left: 10.12.r,
            right: 14.24.r,
            bottom: 12.13.r,
          ),
          decoration: ShapeDecoration(
            color: AppColors.kLightGreyColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.01.r),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Cincerella’s Roy',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black,
                      fontSize: AppStyles.fontSize17,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    description ?? '1180 Seven Seas Drive, Lak...',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black.withValues(alpha: 140),
                      fontSize: AppStyles.fontSize12,

                      fontWeight: FontWeight.w500,
                      height: 1.23,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    padding: const EdgeInsets.all(7.12),
                    decoration: ShapeDecoration(
                      color: AppColors.kGreyColor.withValues(alpha: .4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19.57.r),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.kClockIcon,
                          scale: 4,
                          color: AppColors.kBlackColor,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          timing,
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.black,
                            fontSize: AppStyles.fontSize12,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (controller != null)
                Row(
                  children: [
                    Text(
                      '$likesCount',
                      textAlign: TextAlign.right,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize14,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    HeartToggleWidget(onLiked: onLiked, isLiked: isLiked),
                    SizedBox(width: 8.w),
                    if (GlobalVariables.isLoggedInUser(
                      controller?.tripModel.value?.createdBy ?? '',
                    ))
                      GestureDetector(
                        onTap: () {
                          if (controller != null) {
                            Get.toNamed(
                              kAddActivityScreenRoute,
                              arguments: {
                                'toAdd': false,
                                'activity':
                                    controller
                                        ?.tripModel
                                        .value
                                        ?.activities?[index],
                                'tripId': controller?.tripModel.value?.id,
                                'onAdded': (ActivityModel activityId) {
                                  controller!
                                          .tripModel
                                          .value
                                          ?.activities?[index] =
                                      activityId;
                                  controller!.tripModel.refresh();
                                },
                              },
                            );
                          }
                        },
                        child: Image.asset(
                          AppImages.kEditClipboardIcon,
                          scale: 4,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (controller == null ||
            (GlobalVariables.isLoggedInUser(
              controller?.tripModel.value?.createdBy ?? '',
            )))
          if (onDelete != null)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete),
              ),
            ),
      ],
    );
  }
}
