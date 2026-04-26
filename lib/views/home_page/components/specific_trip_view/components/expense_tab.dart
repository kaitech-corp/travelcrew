import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/expense_service.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';

import '../../../../../utils/app_images.dart';
import '../../../../../utils/app_styles.dart';
import '../controller/specific_trip_view_controller.dart';

class ExpenseTab extends StatelessWidget {
  const ExpenseTab({super.key, required this.controller});
  final SpecificTripViewController controller;

  @override
  Widget build(BuildContext context) {
    final expenseService = ExpenseService();
    final trip = controller.tripModel.value!;
    final Map<String, double> userDebts = expenseService.calculateUserDebts(
      trip,
    );
    final expenseSummary = expenseService.getTripExpenseSummary(trip);

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE7E7E7)),
          borderRadius: BorderRadius.circular(26),
        ),
        shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 92.99)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Trip Cost',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: AppStyles.fontSize20,
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              Image.asset(AppImages.kDollarIcon, scale: 4),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${expenseSummary['totalExpenses'].toStringAsFixed(2)} Total Expenses',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black.withValues(alpha: 0.55),
                        fontSize: AppStyles.fontSize18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Budget: \$${trip.tripBudget.toStringAsFixed(2)} • Remaining: \$${expenseSummary['remainingBudget'].toStringAsFixed(2)}',
                      style: AppStyles.labelTextStyle().copyWith(
                        color:
                            expenseSummary['remainingBudget'] < 0
                                ? Colors.red
                                : Colors.green,
                        fontSize: AppStyles.fontSize12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // User's expense summary
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'You Spent',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.grey.shade600,
                        fontSize: AppStyles.fontSize12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '\$${expenseSummary['userSpent'].toStringAsFixed(2)}',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      'Your Share',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.grey.shade600,
                        fontSize: AppStyles.fontSize12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '\$${expenseSummary['userShare'].toStringAsFixed(2)}',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      'Net Balance',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.grey.shade600,
                        fontSize: AppStyles.fontSize12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${expenseSummary['netBalance'] >= 0 ? '+' : ''}\$${expenseSummary['netBalance'].toStringAsFixed(2)}',
                      style: AppStyles.labelTextStyle().copyWith(
                        color:
                            expenseSummary['netBalance'] >= 0
                                ? Colors.green
                                : Colors.red,
                        fontSize: AppStyles.fontSize16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 15.h),
          Text(
            'Who Owes What?',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: AppStyles.fontSize20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),

          // Show debt information
          if (userDebts.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'All expenses are settled!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: AppStyles.fontSize16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              separatorBuilder:
                  (context, index) =>
                      const Divider(color: Color(0xFFE7E7E7), thickness: 1),
              itemCount: userDebts.length,
              itemBuilder: (context, index) {
                final userId = userDebts.keys.elementAt(index);
                final amount = userDebts.values.elementAt(index);
                final user = controller.tripModel.value?.joindUsersList
                    ?.firstWhere(
                      (u) => u.uid == userId,
                      orElse:
                          () => PublicUserModel(
                            displayName: 'Unknown User',
                            email: '',
                            uid: userId,
                            profileImage: '',
                            followers: [],
                            following: [],
                            tripsCreated: 0,
                            tripsJoined: 0,
                          ),
                    );

                if (user == null || amount == 0) return const SizedBox.shrink();

                final isOwedToCurrentUser = amount > 0;
                final displayAmount = amount.abs();

                return Row(
                  children: [
                    AnyImageView(
                      ontap: () {
                        // Get.toNamed(kProfileScreenRoute);
                      },
                      url: user.profileImage ?? '',
                      width: 50.w,
                      padding: EdgeInsets.zero,
                      height: 50.h,
                      isCircle: true,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        isOwedToCurrentUser
                            ? '${user.displayName} owes you'
                            : 'You owe ${user.displayName}',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: const Color(0xFF1F1F1F),
                          fontSize: AppStyles.fontSize13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '\$${displayAmount.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: AppStyles.labelTextStyle().copyWith(
                        color:
                            isOwedToCurrentUser
                                ? const Color(
                                  0xFF1D7FC2,
                                ) // Blue for money owed to you
                                : const Color(
                                  0xFFE74C3C,
                                ), // Red for money you owe
                        fontSize: AppStyles.fontSize13,
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
                        fontSize: AppStyles.fontSize13,
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
                      'tripMembers': controller.tripModel.value?.joindUsersList,
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
                            fontSize: AppStyles.fontSize13,
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
