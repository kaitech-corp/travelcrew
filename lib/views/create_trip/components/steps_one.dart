import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_crew/models/search_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_strings_keys.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/utils/common_code.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../custom_widgets/bottom_sheets/custom_image_bottomsheet.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/custom_toggle_button.dart';
import '../../custom_widgets/date_range_picker/range_picker_dialogue.dart';
import '../../custom_widgets/location_dropdown.dart';
import '../controller/create_trip_controller.dart';

class StepsOne extends StatelessWidget {
  const StepsOne({super.key, required this.controller});
  final CreateTripController controller;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formStep1,
      child: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Name',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize20,

                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                hintText: 'Summer Getaway 2025',
                controller: controller.tripNameController,
                focusNode: controller.tripNameFocusNode,
                validator:
                    (p0) => p0?.isBlank ?? true ? 'Please enter name' : null,
              ),
              SizedBox(height: 27.h),
              Text(
                'Destination',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize20,

                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () =>
                    controller.selectedLocation.value.isNotEmpty
                        ? Stack(
                          children: [
                            FutureBuilder(
                              future: controller.selectedPlaceId.value ==
                                      'existing_location'
                                  ? Future.value(null)
                                  : controller.getLocationDetails(
                                      controller.selectedPlaceId.value,
                                    ),
                              builder: (c, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(20.r),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey,
                                      highlightColor:
                                          Theme.of(context).primaryColor,
                                      child: Container(
                                        height: 199.h,
                                        width: context.width,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (snap.hasData) {
                                  return AnyImageView(
                                    borderRadius: BorderRadius.circular(25.r),
                                    url:
                                        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${snap.data.toString()}&key=$kGoogleMapKey',
                                    height: 199.h,
                                    width: context.width,
                                  );
                                }
                                // No Google Places photo — show first uploaded
                                // image or a neutral placeholder
                                final firstImage =
                                    controller.selectedImages.isNotEmpty
                                        ? controller.selectedImages.first
                                        : null;
                                if (firstImage != null) {
                                  return AnyImageView(
                                    borderRadius: BorderRadius.circular(25.r),
                                    url: firstImage.imageUrl,
                                    height: 199.h,
                                    width: context.width,
                                    fileType: firstImage.isNetworkImage
                                        ? SourceType.network
                                        : SourceType.file,
                                  );
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Container(
                                    height: 199.h,
                                    width: context.width,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.grey.shade400,
                                      size: 48.sp,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectedLocation.value = '';
                                  GlobalVariables.showDropdown.value = true;
                                },
                                child: CustomLocationLabel(
                                  text: controller.selectedLocation.value,
                                ),
                              ),
                            ),
                          ],
                        )
                        : LocationDropdownWidget(
                          items: controller.locations,
                          hintText: 'Search Destination',
                          selectedText: controller.searchText.value,
                          onChanged: (value) {
                            controller.fetchLocation(value);
                          },
                          onTap: (String placeId, SearchModel searchText) {
                            controller.selectedPlaceId.value = placeId;
                            controller.selectedLocation.value =
                                searchText.searchText;
                            GlobalVariables.showDropdown.value = false;
                          },
                          textInputAction: TextInputAction.done,
                          validator:
                              (p0) =>
                                  p0?.isBlank ?? true
                                      ? 'Please enter destination'
                                      : null,
                          textEditingController:
                              controller.destinationController,
                          focusNode: controller.destinationFocusNode,
                        ),
              ),
              SizedBox(height: 27.h),
              if (controller.selectedLocation.value.isNotEmpty) ...{
                Text(
                  'Date',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: Colors.black,
                    fontSize: AppStyles.fontSize20,

                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () async {
                    CommonCode().removeTextFieldFocus();
                    await showDialog(
                      context: context,
                      builder:
                          (c) => RangeCalendarDialog(
                            focusedDay: DateTime.now(),
                            rangeStart: controller.startDate.value,
                            initialDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 4),
                            rangeEnd: controller.endDate.value,
                            onRangeSelected: (startDate, endDate) async {
                              if (startDate != null && endDate != null) {
                                controller.startDate.value = startDate;
                                controller.endDate.value = endDate;
                              }
                            },
                          ),
                    );
                    if (controller.startDate.value != null) {
                      await pickTime(
                        title: 'Select Start Time',
                        selectedTime: (time) async {
                          controller.startDate.value = DateTime(
                            controller.startDate.value!.year,
                            controller.startDate.value!.month,
                            controller.startDate.value!.day,
                            time.hour,
                            time.minute,
                          );
                          await pickTime(
                            title: 'Select End Time',
                            selectedTime: (time) async {
                              controller.endDate.value = DateTime(
                                controller.endDate.value!.year,
                                controller.endDate.value!.month,
                                controller.endDate.value!.day,
                                time.hour,
                                time.minute,
                              );
                            },
                          );
                        },
                      );
                    }
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => Text(
                            controller.startDate.value == null ||
                                    controller.endDate.value == null
                                ? 'Select from and to date'
                                : '${DateFormat('EEE, d MMM').format(controller.startDate.value!)} - ${DateFormat('EEE, d MMM').format(controller.endDate.value!)}',
                            textAlign: TextAlign.center,
                            style: AppStyles.labelTextStyle().copyWith(
                              color: Colors.black,
                              fontSize: AppStyles.fontSize13,

                              fontWeight: FontWeight.w500,
                              height: 1.25.h,
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
              },
              Text(
                'Trip Privacy',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize20,

                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose who can see and join your trip. Keep it private for invited members or make it public for everyone to explore!',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.grey,
                        fontSize: AppStyles.fontSize13,

                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  CustomLockToggle(isLocked: controller.isLocked),
                ],
              ),
              SizedBox(height: 27.h),
              Text(
                'Trip Cover Image',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize20,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child:
                    controller.selectedImages.isEmpty
                        ? GestureDetector(
                          onTap: () async {
                            final List<String> images =
                                await ImagePickerBottomSheet()
                                    .getImageFromCameraOrGallery(context);
                            if (images.where((e) => e.isNotEmpty).isNotEmpty) {
                              controller.selectedImages.addAll(
                                images.map((e) => SelectedImage(imageUrl: e)),
                              );
                            }
                          },
                          child: DottedBorder(
                            options: CircularDottedBorderOptions(
                              dashPattern: const [20, 20],
                              color: const Color(0xFF1D7FC2),
                            ),
                            child: SizedBox(
                              width: Get.width,
                              height: 164.h,
                              child: Center(
                                child: Image.asset(
                                  AppImages.kUploadIcon,
                                  scale: 4,
                                ),
                              ),
                            ),
                          ),
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 164.h,
                                child: ListView.separated(
                                  separatorBuilder:
                                      (context, index) => SizedBox(width: 10.w),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return AnyImageView(
                                      fileType:
                                          controller
                                                  .selectedImages[index]
                                                  .isNetworkImage
                                              ? SourceType.network
                                              : SourceType.file,
                                      url:
                                          controller
                                              .selectedImages[index]
                                              .imageUrl,
                                      width: 164.w,
                                      height: 164.h,
                                      borderRadius: BorderRadius.circular(24.r),
                                    );
                                  },
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final List<String> images =
                                    await ImagePickerBottomSheet()
                                        .getImageFromCameraOrGallery(context);
                                if (images
                                    .where((e) => e.isNotEmpty)
                                    .isNotEmpty) {
                                  controller.selectedImages.addAll(
                                    images.map(
                                      (e) => SelectedImage(imageUrl: e),
                                    ),
                                  );
                                }
                              },
                              child: Image.asset(
                                AppImages.kUploadIcon,
                                scale: 4,
                              ),
                            ),
                          ],
                        ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomLocationLabel extends StatelessWidget {
  const CustomLocationLabel({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RPSCustomPainter(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ImageIcon(
              AssetImage(AppImages.kOutlinedPinnedLocation),
              color: Colors.white,
              size: 26.sp,
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.width * 0.5),
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.white,
                  fontSize: AppStyles.fontSize15,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path_0 = Path();
    path_0.moveTo(size.width * 0.003246365, 0);
    path_0.lineTo(size.width * 0.9948629, 0);
    path_0.lineTo(size.width * 0.9812792, size.height * 0.01147123);
    path_0.cubicTo(
      size.width * 0.9381980,
      size.height * 0.04784343,
      size.width * 0.9063299,
      size.height * 0.2561411,
      size.width * 0.9063299,
      size.height * 0.5013343,
    );
    path_0.cubicTo(
      size.width * 0.9063299,
      size.height * 0.7749057,
      size.width * 0.8669239,
      size.height * 0.9966771,
      size.width * 0.8183198,
      size.height * 0.9966771,
    );
    path_0.lineTo(size.width * 0.1797888, size.height * 0.9966771);
    path_0.cubicTo(
      size.width * 0.1311848,
      size.height * 0.9966771,
      size.width * 0.09178376,
      size.height * 0.7749057,
      size.width * 0.09178376,
      size.height * 0.5013343,
    );
    path_0.cubicTo(
      size.width * 0.09178376,
      size.height * 0.2561411,
      size.width * 0.05991371,
      size.height * 0.04784343,
      size.width * 0.01683325,
      size.height * 0.01147123,
    );
    path_0.lineTo(size.width * 0.003246365, 0);
    path_0.close();

    final Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Colors.black.withAlpha(153);
    canvas.drawPath(path_0, paint0Fill);

    final Path path_1 = Path();
    path_1.moveTo(size.width * 0.1758944, size.height * 0.4475800);
    path_1.cubicTo(
      size.width * 0.1758944,
      size.height * 0.5684714,
      size.width * 0.1946838,
      size.height * 0.6684457,
      size.width * 0.2030010,
      size.height * 0.7067743,
    );
    path_1.cubicTo(
      size.width * 0.2041909,
      size.height * 0.7122600,
      size.width * 0.2047934,
      size.height * 0.7150371,
      size.width * 0.2056812,
      size.height * 0.7164429,
    );
    path_1.cubicTo(
      size.width * 0.2063726,
      size.height * 0.7175400,
      size.width * 0.2073904,
      size.height * 0.7175400,
      size.width * 0.2080817,
      size.height * 0.7164429,
    );
    path_1.cubicTo(
      size.width * 0.2089716,
      size.height * 0.7150343,
      size.width * 0.2095695,
      size.height * 0.7122857,
      size.width * 0.2107645,
      size.height * 0.7067800,
    );
    path_1.cubicTo(
      size.width * 0.2190812,
      size.height * 0.6684486,
      size.width * 0.2378701,
      size.height * 0.5684829,
      size.width * 0.2378701,
      size.height * 0.4475914,
    );
    path_1.cubicTo(
      size.width * 0.2378701,
      size.height * 0.4018400,
      size.width * 0.2346056,
      size.height * 0.3579600,
      size.width * 0.2287939,
      size.height * 0.3256086,
    );
    path_1.cubicTo(
      size.width * 0.2229827,
      size.height * 0.2932571,
      size.width * 0.2151010,
      size.height * 0.2750837,
      size.width * 0.2068827,
      size.height * 0.2750837,
    );
    path_1.cubicTo(
      size.width * 0.1986640,
      size.height * 0.2750837,
      size.width * 0.1907817,
      size.height * 0.2932600,
      size.width * 0.1849706,
      size.height * 0.3256114,
    );
    path_1.cubicTo(
      size.width * 0.1791589,
      size.height * 0.3579629,
      size.width * 0.1758944,
      size.height * 0.4018286,
      size.width * 0.1758944,
      size.height * 0.4475800,
    );
    path_1.close();

    // Paint paint1Stroke =
    //     Paint()
    //       ..style = PaintingStyle.stroke
    //       ..strokeWidth = size.width * 0.006640305;
    // paint1Stroke.color = Colors.white.withOpacity(1.0);
    // paint1Stroke.strokeCap = StrokeCap.round;
    // paint1Stroke.strokeJoin = StrokeJoin.round;
    // canvas.drawPath(path_1, paint1Stroke);

    // Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    // paint1Fill.color = const Color(0xff000000).withOpacity(1.0);
    // canvas.drawPath(path_1, paint1Fill);

    // Additional paths and painting logic omitted for brevity
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Future<void> pickTime({
  String? title,
  required Function(TimeOfDay time) selectedTime,
}) async {
  await showTimePicker(
    context: Get.context!,
    helpText: title ?? 'Select Time',
    initialTime: TimeOfDay.now(),
  ).then((value) {
    if (value != null) {
      selectedTime.call(value);
    }
  });
}
