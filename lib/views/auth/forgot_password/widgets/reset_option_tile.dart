import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_crew/utils/app_styles.dart';

import '../../../../utils/app_colors.dart';

class ResetOptionTile extends StatelessWidget {
  const ResetOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.kPrimaryColor.withAlpha(51)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.kPrimaryColor.withAlpha(51)
                    : Colors.grey[100]!,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: icon,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 20.w),
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.kPrimaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.kPrimaryColor : Colors.grey,
                  width: 1.5.w,
                ),
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16.w)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
