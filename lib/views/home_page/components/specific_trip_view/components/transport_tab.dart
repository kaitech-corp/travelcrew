import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

import '../../../../../utils/app_styles.dart';

class TransportTab extends StatelessWidget {
  const TransportTab({super.key, required this.controller});
  final SpecificTripViewController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Airline Name',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: 20.93,

            fontWeight: FontWeight.w600,
            height: 1.33,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          controller.tripModel.value?.airlineName ?? '',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black.withValues(alpha: 140),
            fontSize: 18,

            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 30.h),
        Text(
          'Flight Number',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: 20.93,

            fontWeight: FontWeight.w600,
            height: 1.33,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          controller.tripModel.value?.flightNumber ?? '',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black.withValues(alpha: 140),
            fontSize: 18,

            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 30.h),
        Text(
          'Departure Date & Time',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: 20.93,

            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Text(
              DateFormat('MMMM dd, yyyy - hh:mm a').format(
                controller.tripModel.value?.departureDate ?? DateTime.now(),
              ),
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black.withValues(alpha: 140),
                fontSize: 18,

                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 10.w),
            // Icon(Icons.date_range_outlined),
            Image.asset(
              AppImages.kCalendarIcon,
              scale: 5,
              color: AppColors.kBlackColor,
            ),
          ],
        ),
        SizedBox(height: 30.h),
        Text(
          'Arrival Date & Time',
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
            Text(
              DateFormat('MMMM dd, yyyy - hh:mm a').format(
                controller.tripModel.value?.arrivalDate ?? DateTime.now(),
              ),
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black.withValues(alpha: 140),
                fontSize: 18,

                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 10.w),
            Image.asset(
              AppImages.kCalendarIcon,
              scale: 5,
              color: AppColors.kBlackColor,
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          'Airport/Station Details',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: 20.93,
            fontWeight: FontWeight.w600,
            height: 1.33,
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 17.44,
            vertical: 15.70,
          ),
          decoration: ShapeDecoration(
            color: AppColors.kLightGreyColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27.91),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.tripModel.value?.departureAirport ?? 'Not Available',
                textAlign: TextAlign.center,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: 13.95,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5.h),
              const Icon(Icons.arrow_downward, size: 20),
              SizedBox(height: 5.h),
              Text(
                controller.tripModel.value?.arrivalAirport ?? 'Not available',
                textAlign: TextAlign.center,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: 13.95,

                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }
}
