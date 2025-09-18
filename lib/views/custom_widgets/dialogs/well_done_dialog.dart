import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_strings.dart';

import '../../../utils/app_styles.dart';

class WellDoneDialog extends StatelessWidget {
  const WellDoneDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Well done!',
            textAlign: TextAlign.center,
            style: AppStyles.labelTextStyle().copyWith(
              color: AppColors.kWhiteColor,
              fontSize: AppStyles.fontSize28,

              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: 273.49.w,
            child: Text(
              'You have sucessfully change \npassword.\nPlease use your new password \nwhen log in.',
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.white.withAlpha(140),
                fontSize: 15.88.sp,

                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: () {
              Get.offAllNamed(kLoginScreenRoute);
            },
            child: Container(
              width: 273.49,
              padding: EdgeInsets.symmetric(
                horizontal: 17.64.w,
                vertical: 15.88.h,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0xFF1D7FC2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(49.40.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Return to Login',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.white,
                      fontSize: 14.12.sp,

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
    );
  }
}
