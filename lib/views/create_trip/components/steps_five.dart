import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/utils/app_utils.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/custom_widgets/location_dropdown.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/activities_tab.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/date_range_picker/range_picker_dialogue.dart';
import 'steps_one.dart';

class StepsFive extends StatelessWidget {
  final CreateTripController controller;
  const StepsFive({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formStep5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () =>
                controller.activityList.isEmpty
                    ? SizedBox.shrink()
                    : Container(
                      margin: EdgeInsets.only(bottom: 15.h),
                      height: 110.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder:
                            (c, index) => ActivityWidget(
                              index: index,
                              onDelete: () {
                                AppUtils.showConfirmationDialogue(
                                  title: 'Delete Activity',
                                  description:
                                      'Are you sure you want to delete this activity?',
                                  onPressedYes: () {
                                    controller.removeActivity(
                                      controller.activityList[index].id,
                                      index,
                                    );
                                    Get.back();
                                  },
                                );
                              },
                              title: controller.activityList[index].title,
                              description:
                                  controller.activityList[index].description,
                            ),
                        separatorBuilder: (c, index) => SizedBox(width: 10.w),
                        itemCount: controller.activityList.length,
                      ),
                    ),
          ),
          Text(
            'Activity Name',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.93,

              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            // validator:
            //     (p0) =>
            //         p0?.isBlank == true ? 'Please enter activity name' : null,
            hintText: 'Enter Activity Name',
            focusNode: controller.activityNameFocusNode,
            controller: controller.activityNameController,
            prefixIcon: Image.asset(AppImages.kSearchIcon, scale: 4),
          ),
          SizedBox(height: 27.h),
          Text(
            'Location',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.93,

              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => LocationDropdownWidget(
              hintText: 'Location',
              items: controller.locations,
              onChanged: (value) => controller.fetchLocation(value ?? '', type: 'tourist_attraction'),
              // validator:
              //     (p0) =>
              //         p0?.isBlank == true ? 'Please select a location' : null,
              selectedText: controller.searchText.value,
              textEditingController: controller.locationController,
              focusNode: controller.locationFocusNode,
            ),
          ),
          SizedBox(height: 27.h),
          Text(
            'Date & Time',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.93,

              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {
              CommonCode().removeTextFieldFocus();
              showDialog(
                context: context,
                builder:
                    (c) => RangeCalendarDialog(
                      focusedDay: DateTime.now(),
                      rangeStart:
                          controller.activityStartTime.value ?? DateTime.now(),
                      initialDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 4),
                      rangeEnd:
                          controller.activityEndTime.value ?? DateTime.now(),
                      onRangeSelected: (startDate, endDate) {
                        if (startDate != null && endDate != null) {
                          controller.activityStartTime.value = startDate;
                          controller.activityEndTime.value = endDate;
                        }
                      },
                    ),
              ).then((_) async {
                if (controller.activityStartTime.value != null) {
                  await pickTime(
                    title: 'Select Start Time',
                    selectedTime: (time) async {
                      controller.activityStartTime.value = DateTime(
                        controller.activityStartTime.value!.year,
                        controller.activityStartTime.value!.month,
                        controller.activityStartTime.value!.day,
                        time.hour,
                        time.minute,
                      );
                    },
                  );
                  await pickTime(
                    title: 'Select End Time',
                    selectedTime: (time) async {
                      controller.activityEndTime.value = DateTime(
                        controller.activityEndTime.value!.year,
                        controller.activityEndTime.value!.month,
                        controller.activityEndTime.value!.day,
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
              padding: EdgeInsets.symmetric(
                horizontal: 17.44.w,
                vertical: 15.70.h,
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
                      // 'June 10 - June 18, 2025',
                      controller.activityStartTime.value == null ||
                              controller.activityEndTime.value == null
                          ? 'Select activity start & end date'
                          : '${controller.activityStartTime.value != null && controller.activityEndTime.value != null ? "${CommonCode.formatMonth(controller.activityStartTime.value!.month)} ${controller.activityStartTime.value!.day}, ${controller.activityStartTime.value!.year} - ${CommonCode.formatTime(controller.activityStartTime.value!)} to ${CommonCode.formatMonth(controller.activityEndTime.value!.month)} ${controller.activityEndTime.value!.day}, ${controller.activityEndTime.value!.year} - ${CommonCode.formatTime(controller.activityEndTime.value!)}" : ""}',

                      // : '${DateFormat('MMM dd yyyy').format(controller.activityStartTime.value!)} - ${DateFormat('MMM dd yyyy').format(controller.activityEndTime.value!)}',
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

          SizedBox(height: 27.h),
          Text(
            'Activity Notes',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.93,

              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            hintText: 'Includes professional guide & lunch.',
            focusNode: controller.activityNoteFocusNode,

            controller: controller.activityNoteController,
            // prefixIcon: Image.asset(AppImages.kSearchIcon, scale: 4),
          ),
          SizedBox(height: 27.h),
          Center(
            child: GestureDetector(
              onTap: () {
                if (controller.formStep5.currentState?.validate() == false) {
                  return;
                }
                if (controller.activityStartTime.value == null ||
                    controller.activityEndTime.value == null) {
                  showCustomSnackBar(content: 'Please select date');
                  return;
                }
                controller.activityList.add(
                  ActivityModel(
                    likesCount: 0,
                    location: controller.locationController.text,
                    tripId: '',
                    id: '',
                    startDateTime: controller.activityStartTime.value!,
                    endDateTime: controller.activityEndTime.value!,
                    title: controller.activityNameController.text,
                    description: controller.activityNoteController.text,
                  ),
                );
                controller.activityNameController.clear();
                controller.activityNoteController.clear();
                controller.locationController.clear();
                controller.activityStartTime.value = null;
                controller.activityEndTime.value = null;
                controller.update();
              },
              child: Text(
                'Add Another Activity',
                style: AppStyles.labelTextStyle().copyWith(
                  color: const Color(0xFF1D7FC2),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF1D7FC2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
