import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/url_launcher_helper.dart';

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
              (c, index) => Obx(() {
                final activity = controller.tripModel.value?.activities?[index];
                if (activity == null) return const SizedBox.shrink();
                return ActivityWidget(
                  controller: controller,
                  isLiked: activity.likedBy.contains(
                    GlobalVariables.loggedInUser.value?.uid,
                  ),
                  onLiked: () {
                    controller.likeActivity(
                      isLiked: activity.likedBy.contains(
                        GlobalVariables.loggedInUser.value?.uid,
                      ),
                      activityId: activity.id ?? '',
                    );
                  },
                  likesCount: activity.likesCount,
                  timing: _formatTimeRange(activity),
                  index: index,
                  title: activity.title,
                  description: activity.description,
                  location: activity.location,
                  onTap: () => _showActivityDetails(context, activity),
                );
              }),
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

  String _formatTimeRange(ActivityModel activity) {
    final start = activity.startDateTime;
    final end = activity.endDateTime;
    if (start == null && end == null) return 'Time not set';
    if (start == null) return DateFormat('hh:mm a').format(end!);
    if (end == null) return DateFormat('hh:mm a').format(start);
    return '${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}';
  }

  void _showActivityDetails(BuildContext context, ActivityModel activity) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ActivityDetailsSheet(activity: activity),
    );
  }
}

class ActivityDetailsSheet extends StatelessWidget {
  const ActivityDetailsSheet({super.key, required this.activity});

  final ActivityModel activity;

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Not set';
    return DateFormat('EEE, MMM d • h:mm a').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = activity.location?.trim().isNotEmpty == true;
    final hasDescription = activity.description.trim().isNotEmpty;
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .82,
        ),
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: AppColors.kBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.kGreyColor.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      activity.title.trim().isEmpty
                          ? 'Activity'
                          : activity.title,
                      style: AppStyles.labelTextStyle().copyWith(
                        fontSize: AppStyles.fontSize24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Date & time',
                value:
                    activity.startDateTime == null &&
                            activity.endDateTime == null
                        ? 'Not set'
                        : '${_formatDateTime(activity.startDateTime)}${activity.endDateTime == null ? '' : '\n${_formatDateTime(activity.endDateTime)}'}',
              ),
              if (hasLocation) ...[
                SizedBox(height: 14.h),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () => openMapLocation(activity.location!),
                    child: Ink(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.kLightBlueColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.kPrimaryColor.withValues(alpha: .15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(9.w),
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryColor.withValues(
                                alpha: .12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.kPrimaryColor,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: AppColors.kGreyTextColor,
                                    fontSize: AppStyles.fontSize12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  activity.location!,
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: AppColors.kPrimaryColor,
                                    fontSize: AppStyles.fontSize15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.open_in_new_rounded,
                            color: AppColors.kPrimaryColor,
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (hasDescription) ...[
                SizedBox(height: 22.h),
                Text(
                  'About this activity',
                  style: AppStyles.labelTextStyle().copyWith(
                    fontSize: AppStyles.fontSize16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  activity.description,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: AppColors.kGreyTextColor,
                    fontSize: AppStyles.fontSize15,
                    height: 1.45,
                  ),
                ),
              ],
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.kPrimaryColor, size: 22),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors.kGreyTextColor,
                fontSize: AppStyles.fontSize12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              value,
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize15,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
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
    this.location,
    this.onTap,
  });
  final Function()? onLiked;
  final SpecificTripViewController? controller;
  final String? title;
  final bool isLiked;
  final int index;
  final String? description;
  final String? location;
  final int likesCount;
  final String timing;
  final Function()? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap:
              onTap ??
              (location?.trim().isNotEmpty == true
                  ? () => openMapLocation(location!)
                  : null),
          child: Container(
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
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'Brunch at The Spot',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black,
                          fontSize: AppStyles.fontSize17,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        description ?? '1180 Seven Seas Drive, Lak...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black.withValues(alpha: 140),
                          fontSize: AppStyles.fontSize14,

                          fontWeight: FontWeight.w500,
                          height: 1.23,
                        ),
                      ),
                      if (location?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 5.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: AppStyles.fontSize14,
                              color: Colors.black.withValues(alpha: 140),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                location!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.labelTextStyle().copyWith(
                                  color: Colors.black.withValues(alpha: 140),
                                  fontSize: AppStyles.fontSize14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.23,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          mainAxisSize: MainAxisSize.min,
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
                                fontSize: AppStyles.fontSize14,

                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      if (onTap != null)
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.kGreyTextColor,
                            size: 22,
                          ),
                        ),
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
