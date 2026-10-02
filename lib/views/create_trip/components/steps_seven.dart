import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/date_range_picker/range_picker_dialogue.dart';
import 'steps_one.dart';

class StepsSeven extends StatelessWidget {
  const StepsSeven({super.key, required this.controller});
  final CreateTripController controller;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formStep7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Name',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: AppStyles.fontSize20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            hintText: 'Enter Expense Name',
            controller: controller.expenseNameController,
            focusNode: controller.expenseNameFocusNode,
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter an expense name';
            //   }
            //   return null;
            // },
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 27.h),
          Text(
            'Amount Paid',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: AppStyles.fontSize20,

              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            hintText: 'Enter Total Cost',
            controller: controller.amountPaidController,
            focusNode: controller.amountPaidFocusNode,
            // validator:
            //     (p0) =>
            //         p0 == null || p0.isEmpty
            //             ? 'Please enter the amount paid'
            //             : null,
            keyboardType: TextInputType.number,
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 5.w),
                Image.asset(AppImages.kDollarIcon, scale: 4),
                SizedBox(width: 5.w),
                const Icon(Icons.keyboard_arrow_up),
              ],
            ),
          ),
          SizedBox(height: 27.h),
          Text(
            'Date',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: AppStyles.fontSize20,

              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (c) => RangeCalendarDialog(
                      focusedDay:
                          controller.expanseDate.value ?? DateTime.now(),
                      rangeStart: DateTime.now(),
                      initialDate: DateTime.now(),
                      isRange: false,
                      lastDate: DateTime(DateTime.now().year + 4),
                      rangeEnd: DateTime.now(),
                      onDateSelected:
                          (selectedDate) =>
                              controller.expanseDate.value = selectedDate,
                    ),
              ).then((_) async {
                if (controller.expanseDate.value != null) {
                  if (controller.activityStartTime.value != null) {
                    await pickTime(
                      title: 'Select Time',
                      selectedTime: (time) async {
                        controller.expanseDate.value = DateTime(
                          controller.expanseDate.value!.year,
                          controller.expanseDate.value!.month,
                          controller.expanseDate.value!.day,
                          time.hour,
                          time.minute,
                        );
                      },
                    );
                  }
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 15.h),
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
                      controller.expanseDate.value == null
                          ? 'select date'
                          : DateFormat(
                            'MMM dd, yyyy',
                          ).format(controller.expanseDate.value!),
                      textAlign: TextAlign.center,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize13,

                        fontWeight: FontWeight.w500,
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
          SizedBox(height: 27.h),
        ],
      ),
    );
  }
}
