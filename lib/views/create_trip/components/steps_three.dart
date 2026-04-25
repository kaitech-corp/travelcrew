import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/create_trip/components/steps_one.dart';
import 'package:travel_crew/views/custom_widgets/custom_textfield.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/date_range_picker/range_picker_dialogue.dart';
import '../../custom_widgets/location_dropdown.dart';
import '../controller/create_trip_controller.dart';

class StepsThree extends StatelessWidget {
  const StepsThree({super.key, required this.controller});
  final CreateTripController controller;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formStep3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Airline Name',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Obx(
              () => LocationDropdownWidget(
                hintText: 'Search Airline',
                selectedText: controller.searchText.value,

                textEditingController: controller.airLineNameController,
                focusNode: FocusNode(),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Flight Number',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              hintText: 'EK356',
              focusNode: controller.flightNumberFocusNode,
              // validator:
              //     (p0) =>
              //         p0?.isBlank == true ? 'Please enter flight number' : null,
              controller: controller.flightNumberController,
            ),
            SizedBox(height: 27.h),
            Text(
              'Departure Date & Time',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () async {
                CommonCode().removeTextFieldFocus();
                showDialog(
                  context: context,
                  builder:
                      (c) => RangeCalendarDialog(
                        focusedDay:
                            controller.departureDate.value ?? DateTime.now(),
                        rangeStart: DateTime.now(),
                        initialDate: DateTime.now(),
                        isRange: false,
                        lastDate: DateTime(DateTime.now().year + 4),
                        rangeEnd: DateTime.now(),
                        onDateSelected:
                            (selectedDate) =>
                                controller.departureDate.value = selectedDate,
                      ),
                ).then((_) async {
                  if (controller.departureDate.value != null) {
                    await pickTime(
                      title: 'Select Departure Time',
                      selectedTime: (time) async {
                        controller.departureDate.value = DateTime(
                          controller.departureDate.value!.year,
                          controller.departureDate.value!.month,
                          controller.departureDate.value!.day,
                          time.hour,
                          time.minute,
                        );
                      },
                    );
                  }
                });
              },
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Text(
                        controller.departureDate.value != null
                            ? controller.departureDate.value != null ? '${CommonCode.formatMonth(controller.departureDate.value!.month)} ${controller.departureDate.value!.day}, ${controller.departureDate.value!.year} - ${CommonCode.formatTime(controller.departureDate.value!)}' : ''
                            : 'June 10, 2025 - 10:00 AM',
                        // 'June 10, 2025 - 10:00 AM',
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black,
                          fontSize: AppStyles.fontSize13,

                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
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
            SizedBox(height: 27.h),
            Text(
              'Arrival Date & Time',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () async {
                CommonCode().removeTextFieldFocus();
                showDialog(
                  context: context,
                  builder:
                      (c) => RangeCalendarDialog(
                        focusedDay:
                            controller.arrivalDate.value ?? DateTime.now(),
                        rangeStart: DateTime.now(),
                        initialDate: DateTime.now(),
                        isRange: false,
                        lastDate: DateTime(DateTime.now().year + 4),
                        rangeEnd: DateTime.now(),
                        onDateSelected:
                            (selectedDate) =>
                                controller.arrivalDate.value = selectedDate,
                      ),
                ).then((_) async {
                  if (controller.arrivalDate.value != null) {
                    await pickTime(
                      title: 'Select Arrival Time',
                      selectedTime: (time) async {
                        controller.arrivalDate.value = DateTime(
                          controller.arrivalDate.value!.year,
                          controller.arrivalDate.value!.month,
                          controller.arrivalDate.value!.day,
                          time.hour,
                          time.minute,
                        );
                      },
                    );
                  }
                });
              },
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Text(
                        controller.arrivalDate.value != null
                            ? controller.arrivalDate.value != null ? '${CommonCode.formatMonth(controller.arrivalDate.value!.month)} ${controller.arrivalDate.value!.day}, ${controller.arrivalDate.value!.year} - ${CommonCode.formatTime(controller.arrivalDate.value!)}' : ''
                            : 'June 10, 2025 - 5:30 PM',
                        // 'June 10, 2025 - 5:30 PM',
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black,
                          fontSize: AppStyles.fontSize13,

                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
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
            SizedBox(height: 27.h),
            Text(
              'Airport/Station Details',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                showBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        spacing: 12.h,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextFormField(
                            focusNode: controller.airportDepartureFocusNode,
                            controller: controller.airportDepartureController,
                            hintText: 'Airport Departure',
                            // validator:
                            //     (p0) =>
                            //         p0?.isBlank == true
                            //             ? 'Please enter airport departure'
                            //             : null,
                          ),
                          CustomTextFormField(
                            focusNode: controller.airportArrivalFocusNode,
                            controller: controller.airportArrivalController,
                            hintText: 'Airport Arrival',
                            // validator:
                            //     (p0) =>
                            //         p0?.isBlank == true
                            //             ? 'Please enter airport arrival'
                            //             : null,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
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
                child: Column(
                  children: [
                    Text(
                      'Dubai International Airport (DXB)',
                      textAlign: TextAlign.center,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize13,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    const Icon(
                      Icons.arrow_downward,
                      size: 20,
                      color: AppColors.kBlackColor,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Bali Ngurah Rai (DPS)',
                      textAlign: TextAlign.center,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize13,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 27.h),
          ],
        ),
      ),
    );
  }
}
