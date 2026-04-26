import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/custom_widgets/location_dropdown.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_images.dart';
import '../../../../../utils/app_styles.dart';
import '../../../../../utils/common_code.dart';
import '../../../../create_trip/components/steps_one.dart';
import '../../../../custom_widgets/custom_text_field.dart';
import '../../../../custom_widgets/date_range_picker/range_picker_dialogue.dart';

// ignore: must_be_immutable
class AddActivity extends GetView<SpecificTripViewController> {
  AddActivity({super.key});
  bool firstTime = true;
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final bool toAdd = args['toAdd'] as bool? ?? true;
    final ActivityModel? activity =
        toAdd ? null : args['activity'] as ActivityModel?;

    if (firstTime) {
      firstTime = false;
      if (!toAdd && activity != null) {
        Future.microtask(() {
          controller.activityNameController.text = activity.title;
          controller.locationController.text = activity.location ?? '';
          controller.activityNoteController.text = activity.description;
          controller.activityStartTime.value = activity.startDateTime;
          controller.activityEndTime.value = activity.endDateTime;
        });
      }
    }
    return CustomScaffold(
      className: runtimeType.toString(),
      screenName: '${toAdd ? 'Add' : 'Update'} Activity',
      centerTitle: true,
      scaffoldKey: controller.addActivityScaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              'Activity Name',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              focusNode: controller.activityNameFocusNode,
              validator:
                  (p0) =>
                      p0?.isBlank == true ? 'Please enter activity name' : null,
              hintText: 'Enter Activity Name',

              // focusNode: controller.activityNameFocusNode,
              controller: controller.activityNameController,
              prefixIcon: Image.asset(AppImages.kSearchIcon, scale: 4),
            ),
            SizedBox(height: 27.h),
            Text(
              'Location',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => LocationDropdownWidget(
                items: controller.locations,
                hintText: 'Location',
                selectedText: controller.searchText.value,
                // : Image.asset(AppImages.kLocationIcon, scale: 4),
                textEditingController: controller.locationController,
                onTap: (placeId, searchText) {
                  controller.searchText.value = searchText.searchText;
                  controller.locationController.text = searchText.searchText;
                },
                validator:
                    (p0) =>
                        p0?.isBlank == true ? 'Please enter location' : null,
                focusNode: controller.locationFocusNode,
                onChanged: (value) {
                  controller.fetchLocations(value ?? '');
                },
              ),
            ),
            SizedBox(height: 27.h),
            Text(
              'Date & Time',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

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
                            controller.activityStartTime.value ??
                            DateTime.now(),
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
                            : '${DateFormat('MMM dd yyyy').format(controller.activityStartTime.value!)} - ${DateFormat('MMM dd yyyy').format(controller.activityEndTime.value!)}',

                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black,
                          fontSize: AppStyles.fontSize13,
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
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              focusNode: controller.activityNoteFocusNode,
              hintText: 'Includes professional guide & lunch.',

              controller: controller.activityNoteController,
              // prefixIcon: Image.asset(AppImages.kSearchIcon, scale: 4),
            ),
            SizedBox(height: 20.h),
            CustomElevatedButton(
              width: context.width,
              title: toAdd ? 'Add' : 'Update',
              onPressed: () {
                controller.addActivity();
              },
            ),
          ],
        ),
      ),
    );
  }
}
