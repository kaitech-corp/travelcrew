import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';

class CustomLockToggle extends StatelessWidget {
  const CustomLockToggle({super.key, required this.isLocked});
  final RxBool isLocked;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          isLocked.value = !isLocked.value;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 87.21.w,
          height: 50.h,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1F1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment:
                    isLocked.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD3E5F5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      AppImages.kUnlockedIcon,
                      scale: 4,
                      color:
                          isLocked.value
                              ? Colors.grey
                              : AppColors.kPrimaryColor,
                    ),
                    Image.asset(
                      AppImages.kLockedIcon,
                      scale: 4,
                      color:
                          isLocked.value
                              ? AppColors.kPrimaryColor
                              : Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
