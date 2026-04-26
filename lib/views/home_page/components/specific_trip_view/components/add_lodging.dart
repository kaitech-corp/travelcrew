import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/utils/common_code.dart';
import 'package:travel_crew/views/custom_widgets/custom_drop_down_widget.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/custom_widgets/date_range_picker/range_picker_dialogue.dart';
import 'package:travel_crew/views/create_trip/components/steps_one.dart'
    show pickTime;
import 'package:travel_crew/views/custom_widgets/location_dropdown.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

// ignore: must_be_immutable
class AddLodgingScreen extends GetView<SpecificTripViewController> {
  AddLodgingScreen({super.key});
  bool _firstTime = true;

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      _firstTime = false;
      final args = Get.arguments;
      if (args is TripModel) {
        Future.microtask(() {
          controller.tripModel.value = args;
          controller.initLodgingFromTrip();
        });
      } else {
        Future.microtask(() => controller.initLodgingFromTrip());
      }
    }

    return CustomScaffold(
      className: runtimeType.toString(),
      screenName: 'Lodging',
      centerTitle: true,
      scaffoldKey: GlobalKey<ScaffoldState>(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              'Lodging Type',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() {
              final current = controller.lodgingTypeController.text;
              return SimpleDropdown<String>(
                items: const ['Hotel', 'Home'],
                value: ['Hotel', 'Home'].contains(current) ? current : null,
                hintText: 'Hotel',
                onChanged: (v) {
                  controller.lodgingTypeController.text = v ?? '';
                },
              );
            }),
            SizedBox(height: 27.h),
            Text(
              'Hotel Name',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => LocationDropdownWidget(
                selectedText: controller.lodgingHotelSearchText.value,
                hintText: 'Search Hotel',
                items: controller.hotelLocations,
                textEditingController: controller.lodgingHotelNameController,
                focusNode: controller.hotelNameFocusNode,
                onChanged: (value) => controller.fetchHotelLocations(value),
                onTap: (placeId, searchText) {
                  controller.lodgingHotelNameController.text =
                      searchText.searchText;
                  controller.lodgingHotelSearchText.value =
                      searchText.searchText;
                },
              ),
            ),
            SizedBox(height: 27.h),
            Text(
              'Address',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => LocationDropdownWidget(
                selectedText: controller.searchText.value,
                hintText: 'Enter address',
                items: controller.locations,
                textEditingController: controller.lodgingAddressController,
                focusNode: controller.lodgingAddressFocusNode,
                onChanged:
                    (value) => controller.fetchLodgingAddressLocations(value),
                onTap: (placeId, searchText) {
                  controller.lodgingAddressController.text =
                      searchText.searchText;
                  controller.searchText.value = searchText.searchText;
                },
              ),
            ),
            SizedBox(height: 27.h),
            Text(
              'Check-in & Check-out',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap:
                  () => showDialog(
                    context: context,
                    builder:
                        (c) => Obx(
                          () => RangeCalendarDialog(
                            focusedDay: DateTime.now(),
                            rangeStart:
                                controller.lodgingCheckIn.value ??
                                DateTime.now(),
                            initialDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 4),
                            rangeEnd:
                                controller.lodgingCheckOut.value ??
                                DateTime.now(),
                            onRangeSelected: (startDate, endDate) {
                              if (startDate != null && endDate != null) {
                                controller.lodgingCheckIn.value = startDate;
                                controller.lodgingCheckOut.value = endDate;
                              }
                            },
                          ),
                        ),
                  ).then((_) async {
                    if (controller.lodgingCheckIn.value != null) {
                      await pickTime(
                        title: 'Select Check-In Time',
                        selectedTime: (time) async {
                          final d = controller.lodgingCheckIn.value!;
                          controller.lodgingCheckIn.value = DateTime(
                            d.year,
                            d.month,
                            d.day,
                            time.hour,
                            time.minute,
                          );
                          await pickTime(
                            title: 'Select Check-Out Time',
                            selectedTime: (time) async {
                              final d2 = controller.lodgingCheckOut.value!;
                              controller.lodgingCheckOut.value = DateTime(
                                d2.year,
                                d2.month,
                                d2.day,
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
                      Flexible(
                        child: Text(
                          controller.lodgingCheckIn.value == null
                              ? 'Check-in & Check-out'
                              : controller.lodgingCheckIn.value != null &&
                                  controller.lodgingCheckOut.value != null
                              ? '${CommonCode.formatMonth(controller.lodgingCheckIn.value!.month)} ${controller.lodgingCheckIn.value!.day}, ${controller.lodgingCheckIn.value!.year} - ${CommonCode.formatTime(controller.lodgingCheckIn.value!)} to ${CommonCode.formatMonth(controller.lodgingCheckOut.value!.month)} ${controller.lodgingCheckOut.value!.day}, ${controller.lodgingCheckOut.value!.year} - ${CommonCode.formatTime(controller.lodgingCheckOut.value!)}'
                              : '',
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
            ),
            SizedBox(height: 30.h),
            CustomElevatedButton(
              width: context.width,
              title: 'Save',
              onPressed: () => controller.saveLodging(),
            ),
          ],
        ),
      ),
    );
  }
}
