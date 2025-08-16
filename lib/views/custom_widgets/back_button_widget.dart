import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key, this.onTap});
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 44.h,
      left: 15.w,
      child: GestureDetector(
        onTap: onTap ?? () => Get.back(),
        child: Container(
          width: 51.36.w,
          height: 51.36.h,
          padding: EdgeInsets.symmetric(horizontal: 18.34.h, vertical: 14.67.w),
          decoration: const BoxDecoration(
            color: Color(0xFFF4F4F4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.kGreyColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}
