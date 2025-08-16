import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/expense/controller/expense_conrtoller.dart';

import '../../../../../utils/app_images.dart';
import '../../../../../utils/app_styles.dart';
import '../controller/specific_trip_view_controller.dart';

class ExpenseTab extends StatelessWidget {
  const ExpenseTab({super.key, required this.controller});
  final SpecificTripViewController controller;
  @override
  Widget build(BuildContext context) {
    final List<UserWithDues> dues = getUsersWithHavingDuesForTrip(
      controller.tripModel.value!,
    );
    return Container(
      // height: Get.height*0.4,
      margin: EdgeInsets.only(bottom: 15.h),
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE7E7E7)),
          borderRadius: BorderRadius.circular(26),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 92.99,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Trip Cost',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.93,

              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              Image.asset(AppImages.kDollarIcon, scale: 4),
              SizedBox(width: 10.w),
              Text(
                '${controller.tripModel.value?.expenses?.fold(0.0, (prev, ele) => prev + ele.amount) ?? 0} Total Expenses',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black.withValues(alpha: 140),
                  fontSize: 18.sp,

                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'Who Owes What?',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.sp,

              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 10.h),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            separatorBuilder:
                (context, index) =>
                    const Divider(color: Color(0xFFE7E7E7), thickness: 1),
            itemCount: dues.length,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Image.network(
                    controller
                            .tripModel
                            .value
                            ?.joindUsersList?[index]
                            .urlToImage ??
                        '',
                    scale: 4,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '${dues[index].user.displayName} ${'owes you'}',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF1F1F1F),
                      fontSize: 13,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${dues[index].dues}',
                    textAlign: TextAlign.right,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF1D7FC2),
                      fontSize: 13.sp,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap:
                    () => Get.toNamed(
                      kExpenseScreenRoute,
                      arguments: controller.tripModel.value!,
                    ),
                child: Container(
                  width: 150.w,
                  height: 34.h,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.46,
                    vertical: 5,
                  ),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 0.68,
                        color: Color(0xFF7B7B7B),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'View Expense',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: const Color(0xFF151515),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(
                    kAddExpenseScreenRoute,
                    arguments: {
                      'tripId': controller.tripModel.value?.id,
                      'onAdd': (ExpenseModel expense) {
                        controller.tripModel.value?.expenses?.add(expense);
                        controller.tripModel.refresh();
                      },
                    },
                  );
                },
                child: Container(
                  width: 150.w,
                  height: 34.68.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 5.h,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF1D7FC2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add Expense',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.white,
                            fontSize: 13,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Image.asset(AppImages.kAdExpenseIcon, scale: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
