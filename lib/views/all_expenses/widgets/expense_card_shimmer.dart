import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ExpenseTripCardShimmer extends StatelessWidget {
  const ExpenseTripCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 17.h),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFFE7E7E7)),
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Total Expense Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 60.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 4.5.h),
                    Container(
                      width: 80.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Participants Row (4 circles + optional more)
            Row(
              children: List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                );
              })..add(
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // View Expense Button Placeholder
            Container(
              width: double.infinity,
              height: Get.height * 0.06,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
