import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
    required this.navItems,
    required this.onTap,
    required this.selectedIndex,
    this.backgroundColor = AppColors.kBlackColor,
    this.selectedIconColor = Colors.white,
    this.unselectedIconColor = AppColors.kGreenColor,
    this.selectedLabelColor = AppColors.kGreenColor,
    this.unselectedLabelColor = AppColors.kWhiteColor,
  });
  final List<BottomNavigationBarItem> navItems;
  final Function(int) onTap;
  final int selectedIndex;
  final Color backgroundColor;
  final Color selectedIconColor;
  final Color unselectedIconColor;
  final Color selectedLabelColor;
  final Color unselectedLabelColor;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: Container(
        height: 90.h,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        padding: EdgeInsets.only(
          left: 15.w,
          right: 15.w,
          bottom: 19.h,
          top: 10.h,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(38),
              blurRadius: 10.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final isSelected = selectedIndex == index;
            final item = navItems[index];
            if (index == 2) {
              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: const BoxDecoration(
                    color: AppColors.kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 25.sp),
                ),
              );
            }
            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10.h),
                  IconTheme(
                    data: IconThemeData(
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.white.withAlpha(179),
                      size: AppStyles.fontSize24,
                    ),
                    child: item.icon,
                  ),
                  SizedBox(height: 4.h),
                  if (item.label != null)
                    Text(
                      item.label!,
                      style: AppStyles.labelTextStyle().copyWith(
                        color:
                            isSelected
                                ? Colors.white
                                : Colors.white.withAlpha(179),
                        fontSize: AppStyles.fontSize12,

                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
