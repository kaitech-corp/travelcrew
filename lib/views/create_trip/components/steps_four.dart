import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/utils/common_code.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/custom_widgets/date_range_picker/range_picker_dialogue.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../custom_widgets/custom_drop_down_widget.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/location_dropdown.dart';
import 'steps_one.dart';

class StepsFour extends StatelessWidget {
  final CreateTripController controller;
  const StepsFour({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formStep4,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lodging Type',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 20.93,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            SimpleDropdown(
              hintText: 'Hotel',
              items: ['Hotel', 'Home'],
              onChanged: (v) {
                controller.lodgingTypeController.text = v ?? '';
              },
            ),
            SizedBox(height: 27.h),
            Text(
              'Hotel Name',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 20.93,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),

            // Obx(
            //   () => LocationDropdownWidget(
            //     selectedText: controller.searchText.value,
            //     hintText: 'Search Hotel',
            //     validator:
            //         (p0) =>
            //             p0?.isBlank ?? true ? 'Please select a hotel' : null,
            //     textEditingController: controller.hotelNameController,
            //     focusNode: controller.hotelNameFocusNode,
            //   ),
            // ),
            CustomTextField(
              hintText: 'Please enter hotel name',
              controller: controller.hotelNameController,
              focusNode: controller.hotelNameFocusNode,
            ),
            SizedBox(height: 27.h),
            Text(
              'Address',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 20.93,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => LocationDropdownWidget(
                selectedText: controller.searchText.value,
                hintText: 'Jalan Raya Nusa Dua Selatan, Bali',
                onChanged: (value) {
                  controller.fetchLocation(value);
                },
                items: controller.locations,
                onTap:
                    (placeId, searchText) =>
                        controller.addressController.text =
                            searchText.searchText,
                // validator:
                //     (p0) =>
                //         p0?.isBlank ?? true
                //             ? 'Please enter hotel address'
                //             : null,
                textEditingController: controller.addressController,
                focusNode: controller.addressFocusNode,
              ),
            ),
            // CustomTextField(
            //   hintText: 'Jalan Raya Nusa Dua Selatan, Bali',
            //   controller: controller.addressController,
            //   validator:
            //       (p0) =>
            //           p0?.isBlank == true ? 'Please enter hotel address' : null,
            //   focusNode: controller.addressFocusNode,
            // ),
            SizedBox(height: 27.h),
            Text(
              'Check-in & Check-out',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 20.93,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (c) => RangeCalendarDialog(
                          focusedDay: DateTime.now(),
                          rangeStart:
                              controller.checkInStartTime.value ??
                              DateTime.now(),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 4),
                          rangeEnd:
                              controller.checkInEndTime.value ?? DateTime.now(),
                          onRangeSelected: (startDate, endDate) {
                            if (startDate != null && endDate != null) {
                              controller.checkInStartTime.value = startDate;
                              controller.checkInEndTime.value = endDate;
                            }
                          },
                        ),
                  ).then((_) async {
                    if (controller.checkInStartTime.value != null) {
                      await pickTime(
                        title: 'Select Check-In Time',
                        selectedTime: (time) async {
                          controller.checkInStartTime.value = DateTime(
                            controller.checkInStartTime.value!.year,
                            controller.checkInStartTime.value!.month,
                            controller.checkInStartTime.value!.day,
                            time.hour,
                            time.minute,
                          );
                          await pickTime(
                            title: 'Select Check-Out Time',
                            selectedTime: (time) async {
                              controller.checkInEndTime.value = DateTime(
                                controller.checkInEndTime.value!.year,
                                controller.checkInEndTime.value!.month,
                                controller.checkInEndTime.value!.day,
                                time.hour,
                                time.minute,
                              );
                            },
                          );
                        },
                      );
                    }
                  }),
              child: Container(
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
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.checkInStartTime.value == null
                            ? 'Check-in & Check-out'
                            : '${controller.checkInStartTime.value != null && controller.checkInEndTime.value != null ? "${CommonCode.formatMonth(controller.checkInStartTime.value!.month)} ${controller.checkInStartTime.value!.day}, ${controller.checkInStartTime.value!.year} - ${CommonCode.formatTime(controller.checkInStartTime.value!)} to ${CommonCode.formatMonth(controller.checkInEndTime.value!.month)} ${controller.checkInEndTime.value!.day}, ${controller.checkInEndTime.value!.year} - ${CommonCode.formatTime(controller.checkInEndTime.value!)}" : ""}',
                        // : '${DateFormat('MMM dd').format(controller.checkInStartTime.value!)} - ${DateFormat('MMM dd, yyyy').format(controller.checkInEndTime.value!)}',
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black,
                          fontSize: 13.95,

                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Image.asset(
                        AppImages.kCalendarIcon,
                        scale: 4,
                        color: AppColors.kBlackColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // SizedBox(height: 27.h),
            // Text(
            //   'Expanse Per Night',
            //   style: AppStyles.labelTextStyle().copyWith(
            //     color: Colors.black,
            //     fontSize: 20.93,

            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            // SizedBox(height: 12.h),
            // CustomTextField(
            //   hintText: '55',
            //   // focusNode: controller.expensePerNightFocusNode,
            //   validator:
            //       (p0) =>
            //           p0?.isBlank == true
            //               ? 'Please enter expense per night'
            //               : null,
            //   controller: controller.expensePerNightController,
            //   keyboardType: TextInputType.number,
            //   prefixIcon: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       SizedBox(width: 5.w),
            //       Image.asset(AppImages.kDollarIcon, scale: 4),
            //       SizedBox(width: 5.w),
            //       Icon(Icons.keyboard_arrow_up),
            //     ],
            //   ),
            // ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
