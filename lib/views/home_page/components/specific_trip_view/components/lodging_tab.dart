import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_styles.dart';

class LodgingTab extends StatelessWidget {
  const LodgingTab({super.key, required this.controller});
  final SpecificTripViewController controller;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      // trailing: Icon(Icons.add),
      initiallyExpanded: true,
      backgroundColor: AppColors.kLightGreyColor,
      collapsedBackgroundColor: AppColors.kLightGreyColor,
      title: Text(
        'Lodging Details',
        style: AppStyles.labelTextStyle().copyWith(
          color: Colors.black,
          fontSize: 20.93,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelWithValue(
                'Lodging Type',
                controller.tripModel.value?.lodgingType ?? '',
              ),
              SizedBox(height: 30.h),
              _labelWithValue(
                'Hotel Name',
                controller.tripModel.value?.hotelName ?? '',
              ),
              SizedBox(height: 30.h),
              _labelWithValue(
                'Address',
                controller.tripModel.value?.hotelAddress ?? '',
              ),
              SizedBox(height: 30.h),
              _labelWithIcon(
                'Check-in & Check-out',
                DateFormat('MMMM dd, yyyy - hh:mm a').format(
                  controller.tripModel.value?.checkInDate ?? DateTime.now(),
                ),
                AppImages.kCalendarIcon,
              ),
              _labelWithIcon(
                '',
                DateFormat('MMMM dd, yyyy - hh:mm a').format(
                  controller.tripModel.value?.checkOutDate ?? DateTime.now(),
                ),
                AppImages.kCalendarIcon,
              ),
              SizedBox(height: 30.h),
              _labelWithIcon(
                'Expense Per Night',
                controller.tripModel.value?.expensePerNight.toString() ?? '0',
                AppImages.kDollarIcon,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labelWithValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: 20.93,
            fontWeight: FontWeight.w600,
            height: 1.33,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black.withValues(alpha: 140),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _labelWithIcon(String label, String value, String iconPath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: 20.93,
            fontWeight: FontWeight.w600,
            height: 1.33,
          ),
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            if (iconPath == AppImages.kDollarIcon)
              Image.asset(iconPath, scale: 4)
            else
              Image.asset(iconPath, scale: 5),
            SizedBox(width: 10.w),
            Text(
              value,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black.withValues(alpha: 140),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
