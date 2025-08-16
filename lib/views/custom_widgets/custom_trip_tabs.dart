import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_styles.dart';

class CustomTripTabs extends StatelessWidget {
  const CustomTripTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.height = 40,
    this.tabBorderRadius = 100,
    this.selectedTabColor = Colors.white,
    this.unselectedTabColor = const Color(0xFFF2F2F2),
    this.selectedTextColor = Colors.black,
    this.unselectedTextColor = Colors.black,
    this.selectedBorderColor = Colors.blue,
    this.tabSpacing = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabChanged;
  final double height;
  final double tabBorderRadius;
  final Color selectedTabColor;
  final Color unselectedTabColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color selectedBorderColor;
  final double tabSpacing;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(
            tabs.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                right: index < tabs.length - 1 ? tabSpacing.w : 0,
              ),
              child: _buildTab(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final bool isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedTabColor : unselectedTabColor,
          borderRadius: BorderRadius.circular(tabBorderRadius.r),
          border:
              isSelected
                  ? Border.all(color: selectedBorderColor, width: 1.5)
                  : null,
        ),
        child: Text(
          tabs[index],
          style: AppStyles.labelTextStyle().copyWith(
            color: isSelected ? selectedTextColor : unselectedTextColor,
            fontSize: 12.73,

            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}
