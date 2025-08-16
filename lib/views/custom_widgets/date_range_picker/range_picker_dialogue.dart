import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/views/create_trip/widget/single_date_selection.dart';
import 'package:travel_crew/views/custom_widgets/date_range_picker/controller/range_picker_controller.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_styles.dart';
import '../../create_trip/widget/date_picker.dart';

class RangeCalendarDialog extends GetView<RangePickerController> {
  const RangeCalendarDialog({
    super.key,
    this.focusedDay,
    this.isRange = true,
    this.onDateSelected,
    this.rangeStart,
    this.initialDate,
    this.lastDate,
    this.rangeEnd,
    this.onRangeSelected,
  });
  final DateTime? focusedDay;
  final bool isRange;
  final DateTime? rangeStart;
  final DateTime? initialDate;
  final DateTime? lastDate;
  final DateTime? rangeEnd;
  final Function(DateTime? selectedDate)? onDateSelected;
  final Function(DateTime? startDate, DateTime? endDate)? onRangeSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      '${DateFormat('EEE, dd MMM').format(controller.startDate.value)} ${!isRange ? '' : '- ${DateFormat('EEE, dd MMM').format(controller.endDate.value)}'}',
                      textAlign: TextAlign.center,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: AppColors.kPrimaryColor,
                        fontSize: 13.95,
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
            SizedBox(height: 15.h),
            if (isRange)
              DateRangePickerScreen(
                focusedDay: focusedDay ?? DateTime.now(),
                initialDate: initialDate ?? DateTime.now(),
                rangeStart: rangeStart ?? DateTime.now(),
                rangeEnd: rangeEnd ?? DateTime.now(),
                onRangeChanged: (selectedDate, endDate) {
                  controller.setStartDate(selectedDate ?? DateTime.now());
                  controller.setEndDate(endDate ?? DateTime.now());
                },
                onRangeSelected: (start, end) {
                  if (start != null && end != null) {
                    controller.setStartDate(start);
                    controller.setEndDate(end);
                  }
                  if (onRangeSelected != null) {
                    onRangeSelected!(start, end);
                  }
                },
                lastDate: lastDate ?? DateTime(DateTime.now().year + 2),
              )
            else
              SingleDatePickerScreen(
                focusedDay: focusedDay ?? DateTime.now(),
                initialDate: initialDate ?? DateTime.now(),
                onDateChanged:
                    (selectedDate) =>
                        controller.setStartDate(selectedDate ?? DateTime.now()),
                onDateSelected: (selectedDate) {
                  onDateSelected?.call(selectedDate);
                },
                lastDate: lastDate ?? DateTime(DateTime.now().year + 2),
              ),
          ],
        ),
      ),
    );
  }
}
