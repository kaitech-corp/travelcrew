import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/custom_widgets/text_widget.dart';

import 'controller/all_expense_cont.dart';
import 'widgets/expense_card_shimmer.dart';

class AllExpensesScreen extends GetView<AllExpensesController> {
  const AllExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: 'Expenses',
      isBackIcon: false,
      centerTitle: true,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Obx(
              () =>
                  controller.isLoading.value
                      ? ListView.builder(
                        itemCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, __) => const ExpenseTripCardShimmer(),
                      )
                      : controller.trips.isEmpty
                      ? const Center(child: Text('No expenses found'))
                      : tripList(),
            ),
          ],
        ),
      ),
    );
  }

  ListView tripList() {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(height: 17.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.trips.length,
      itemBuilder: (context, index) {
        final trip = controller.trips[index];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 10,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFFAFAFA),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFE7E7E7)),
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Total Expense Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    labelText: trip.title ?? 'N/A',

                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: 23.95,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Column(
                    children: [
                      TextWidget(
                        labelText: 'Total Expense',
                        style: AppStyles.labelTextStyle().copyWith(
                          fontSize: 10.64.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 4.5.h),
                      TextWidget(
                        labelText:
                            '\$${trip.expenses!.fold(0.0, (previousValue, element) => (previousValue ?? 0) + element.amount)}',
                        style: AppStyles.labelTextStyle().copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),

                        // '\$${trip.expenses!.fold(0.0, (previousValue, element) => (previousValue ?? 0) + element.amount)}',
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Participants Row
              Row(
                children:
                    (trip.joindUsersList?.isEmpty ?? false)
                        ? [
                          TextWidget(
                            labelText: 'No participants',
                            style: AppStyles.labelTextStyle().copyWith(
                              fontSize: 10.64.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ]
                        : [
                          ...trip.joindUsersList!
                              .take(4)
                              .map(
                                (user) => Padding(
                                  padding: EdgeInsets.only(right: 4.w),
                                  child: const AnyImageView(
                                    url:'', //user.profileImage ?? '',
                                    isCircle: true,
                                  ),
                                ),
                              ),
                          if (trip.joindUsersList!.length > 4)
                            Container(
                              width: 24.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withAlpha(179),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+${trip.joindUsersList!.length - 4}',
                                style: AppStyles.labelTextStyle().copyWith(
                                  fontSize: AppStyles.fontSize10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
              ),
              SizedBox(height: 12.h),
              // View Expense Button
              CustomElevatedButton(
                width: Get.width,
                height: Get.height * 0.06,
                title: 'View Expense',
                onPressed: () {
                  Get.toNamed(kExpenseScreenRoute, arguments: trip);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
