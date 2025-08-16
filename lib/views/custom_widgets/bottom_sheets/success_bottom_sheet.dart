import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_styles.dart';
import '../any_image_view.dart';
import '../custom_elevated_button.dart';
import '../text_widget.dart';
import 'bottom_sheet_close_line.dart';
import 'general_bottom_sheet.dart';
class SuccessBottomSheet extends StatelessWidget {
  const SuccessBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.onContinue,
    required this.buttonText,
  });
  final String title;
  final String description;
  final VoidCallback onContinue;
  final String buttonText;
  @override
  Widget build(BuildContext context) {
    return GeneralBottomSheet(
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12.h,
          children: [
            const BottomSheetCloseLine(),
            SizedBox(height: 10.h),
            Center(
              child: AnyImageView(
                url: AppImages.kCheckIcon,
                fileType: SourceType.asset,
                height: 100.h,
                isCircle: true,
              ),
            ),
            TextWidget(
              labelText: title,
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors.kWhiteColor,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextWidget(
              labelText: description,
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            CustomElevatedButton(
              width: Get.width * 0.9,
              onPressed: onContinue,
              title: buttonText,
              isShadow: false,
              height: 56.h,
              foregroundColor: AppColors.kPrimaryColor,
              backgroundColor: AppColors.kWhiteColor,
            ),
            SizedBox(height: 25.h),
          ],
        ),
      ),
    );
  }
}
