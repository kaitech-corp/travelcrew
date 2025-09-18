import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_styles.dart';
import '../custom_elevated_button.dart';
import '../text_widget.dart';
import 'general_bottom_sheet.dart';
class PrefrenceBottomSheet extends StatelessWidget {
  const PrefrenceBottomSheet({
    super.key,
    required this.availableTags,
    required this.sellectedTags,
    required this.onTagSelected,
  });
  final List<String> availableTags;
  final List<String> sellectedTags;
  final Function(String) onTagSelected;
  @override
  Widget build(BuildContext context) {
    return GeneralBottomSheet(
      color: AppColors.kWhiteColor,
      child: Container(
        // height: Get.height * 0.4,
        width: Get.width,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x1E000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.h,
          children: [
            TextWidget(
              labelText: 'Preferences',
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors.kBlackColor,
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Obx(
              () => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    availableTags.map((tag) {
                      final isSelected = sellectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          onTagSelected(tag);
                        },
                        // () {
                        //   if (isSelected) {
                        //     controller.tags.remove(tag);
                        //   } else {
                        //     controller.tags.add(tag);
                        //   }
                        // },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.kBlackColor
                                    : AppColors.kWhiteColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            tag,
                            style: AppStyles.labelTextStyle().copyWith(
                              color:
                                  isSelected
                                      ? AppColors.kWhiteColor
                                      : AppColors.kBlackColor,
                              fontSize: AppStyles.fontSize14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 10.h),
            CustomElevatedButton(
              width: Get.width * 0.85,
              height: 50.h,
              onPressed: () {
                Get.back();
              },
              title: 'Save',
            ),
          ],
        ),
      ),
    );
  }
}
