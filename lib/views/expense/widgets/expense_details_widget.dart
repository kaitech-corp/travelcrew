import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/expense/controller/expense_conrtoller.dart';

import '../../../utils/app_strings.dart';
import '../../../utils/app_styles.dart';

class ExpenseDetailsWidget extends StatelessWidget {
  const ExpenseDetailsWidget({
    super.key,
    required this.tripModel,
    this.isPending = false,
    required this.controller,
    required this.usersWithHavingDues,
    required this.expenseModel,
  });
  final bool isPending;
  final ExpenseModel expenseModel;
  final TripModel tripModel;
  final List<PublicUserModel> usersWithHavingDues;
  final ExpenseController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE7E7E7)),
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expenseModel.name,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black,
                      fontSize: AppStyles.fontSize20,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    DateFormat('dd MMM, hh:mma').format(expenseModel.date),
                    textAlign: TextAlign.center,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: AppStyles.fontSize12,

                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (tripModel.joindUsersList != null &&
                  tripModel.joindUsersList!.isNotEmpty)
                Container(
                  height: 23.57.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: ShapeDecoration(
                    color: Color(
                      isPending ? 0xFFC7AA01 : 0xFF4AD10B,
                    ).withValues(alpha: .2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35.77),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8.94,
                    children: [
                      Text(
                        tripModel.joindUsersList!.length !=
                                usersWithHavingDues.length
                            ? 'Pending'
                            : 'Paid',
                        style: AppStyles.labelTextStyle().copyWith(
                          color:
                              isPending
                                  ? const Color(0xFFC7AA01)
                                  : const Color(0xFF4AD10B),
                          fontSize: AppStyles.fontSize12,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(width: 20.w),
              Text(
                '\$${expenseModel.amount}',
                style: AppStyles.labelTextStyle().copyWith(
                  color: const Color(0xFF1D7FC2),
                  fontSize: AppStyles.fontSize20,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(),
          SizedBox(height: 8.h),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemCount: controller.tripModel.value?.joindUsersList?.length ?? 0,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  AnyImageView(
                    ontap: () {
                      Get.toNamed(kProfileScreenRoute);
                    },
                    url:
                        controller
                            .tripModel
                            .value
                            ?.joindUsersList?[index]
                            .profileImage ??
                        '',
                    width: 50.w,
                    padding: EdgeInsets.zero,
                    height: 50.h,
                    isCircle: true,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '${controller.tripModel.value?.joindUsersList?[index].displayName} ${'owes you'}',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF1F1F1F),
                      fontSize: AppStyles.fontSize13,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${expenseModel.amount}',
                    textAlign: TextAlign.right,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF1D7FC2),
                      fontSize: AppStyles.fontSize13,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () {
              controller.expenseToSettle = expenseModel;
              Get.toNamed(kSettleUpScreenRoute);
            },
            child: Container(
              width: 311.w,
              height: 34.68,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
              decoration: ShapeDecoration(
                color: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFCFCFCF)),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    'Settle Up',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black,
                      fontSize: AppStyles.fontSize13,

                      fontWeight: FontWeight.w500,
                      height: 1.19,
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
