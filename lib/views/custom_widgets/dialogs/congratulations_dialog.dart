import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_strings.dart';

import '../../../utils/app_styles.dart';

class CongratulationsDialog extends StatelessWidget {
  const CongratulationsDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(28.23),
        decoration: ShapeDecoration(
          color: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.64),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.kCongratulationImage, scale: 4),
            SizedBox(height: 10.h),
            Text(
              'Congratulations!',
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors.kWhiteColor,
                fontSize: 28.sp,

                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 273.49,
              child: Text(
                'Your confirmation code has been successfully verified.',
                textAlign: TextAlign.center,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.white.withAlpha(140), // Adjust opacity for better readability
                  fontSize: 15.88,

                  fontWeight: FontWeight.w500,
                  height: 1.33,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () {
                Get.toNamed(kNewPasswordScreenRoute);
              },
              child: Container(
                width: 273.49,
                padding: const EdgeInsets.symmetric(
                  horizontal: 17.64,
                  vertical: 15.88,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFF1D7FC2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(49.40),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Accept',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.white,
                        fontSize: 14.12,

                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
