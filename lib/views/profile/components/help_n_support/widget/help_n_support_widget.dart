import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_crew/utils/app_colors.dart';

import '../../../../../utils/app_styles.dart';

class HelpSupportExpansionTile extends StatelessWidget {
  const HelpSupportExpansionTile({
    super.key,
    required this.title,
    required this.description,
  });
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.kLightGreyColor,
      elevation: 0,
      child: ExpansionTile(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.kLightGreyColor, width: 0),
        ),
        iconColor: AppColors.kBlackColor,
        title: Text(
          title,
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: 12.sp,
            letterSpacing: 0.36,
            fontWeight: FontWeight.w400,
          ),
        ),
        childrenPadding: EdgeInsets.symmetric(horizontal: 10.w),
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Divider(
            color: Colors.black.withValues(alpha: 0.5),
            thickness: 1,
            height: 2.h,
          ),
          SizedBox(height: 9.h),
          Text(
            description,
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.30,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
