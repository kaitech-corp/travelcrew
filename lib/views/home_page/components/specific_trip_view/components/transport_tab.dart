import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/user_flight_model.dart';
import 'package:travel_crew/services/session_services.dart';
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
            fontSize: AppStyles.fontSize20,

            fontWeight: FontWeight.w600,
            height: 1.33,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          controller.tripModel.value?.airlineName ?? '',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black.withValues(alpha: 140),
            fontSize: AppStyles.fontSize18,

            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 30.h),
        Text(
          'Flight Number',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: AppStyles.fontSize20,

            fontWeight: FontWeight.w600,
            height: 1.33,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          controller.tripModel.value?.flightNumber ?? '',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black.withValues(alpha: 140),
            fontSize: AppStyles.fontSize18,

            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 30.h),
        Text(
          'Departure Date & Time',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: AppStyles.fontSize20,

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
                fontSize: AppStyles.fontSize18,

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
            fontSize: AppStyles.fontSize20,

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
                fontSize: AppStyles.fontSize18,

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
            fontSize: AppStyles.fontSize20,
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
                  fontSize: AppStyles.fontSize13,
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
                  fontSize: AppStyles.fontSize13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Crew Flights',
          style: AppStyles.labelTextStyle().copyWith(
            color: const Color(0xFF0F0F0F),
            fontSize: AppStyles.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Divider(),
        SizedBox(height: 8.h),
        Obx(() {
          final flights = controller.tripModel.value?.flights ?? [];
          if (flights.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No crew flights added yet',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black54,
                  fontSize: AppStyles.fontSize14,
                ),
              ),
            );
          }
          return Column(
            children: flights
                .map((flight) => _buildCrewFlightCard(flight, controller))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildCrewFlightCard(
    UserFlightModel flight,
    SpecificTripViewController controller,
  ) {
    final isOwner = flight.userId == GlobalVariables.currentUid;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.kLightGreyColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (flight.displayName != null)
                  Text(
                    flight.displayName!,
                    style: AppStyles.labelTextStyle().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: AppStyles.fontSize14,
                    ),
                  ),
                if (flight.airlineName != null || flight.flightNumber != null)
                  Text(
                    [flight.airlineName, flight.flightNumber]
                        .whereType<String>()
                        .join(' · '),
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: AppStyles.fontSize13,
                    ),
                  ),
                if (flight.departureAirport != null ||
                    flight.arrivalAirport != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        Text(
                          flight.departureAirport ?? '—',
                          style: AppStyles.labelTextStyle().copyWith(
                            fontSize: AppStyles.fontSize12,
                            color: Colors.black54,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          flight.arrivalAirport ?? '—',
                          style: AppStyles.labelTextStyle().copyWith(
                            fontSize: AppStyles.fontSize12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (flight.departureDate != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(flight.departureDate!),
                      style: AppStyles.labelTextStyle().copyWith(
                        fontSize: AppStyles.fontSize12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isOwner)
            GestureDetector(
              onTap: () => controller.deleteFlight(flight.id),
              child: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.redAccent,
              ),
            ),
        ],
      ),
    );
  }
}
