import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/custom_widgets/custom_drop_down_widget.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_field.dart';
import 'package:travel_crew/views/expense/controller/expense_conrtoller.dart';

import '../../../../utils/app_styles.dart';
import '../../../custom_widgets/custom_scaffold.dart';

class SettleUpScreen extends GetView<ExpenseController> {
  const SettleUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: 'Settle Up',
      isBackIcon: true,
      scaffoldKey: controller.expenseSettleScaffoldKey,
      className: runtimeType.toString(),
      centerTitle: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              'Expense Name',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 20.sp,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              hintText: 'Enter Expense Name',
              controller: controller.expenseNameController,
              readOnly: true,
            ),
            SizedBox(height: 27.h),
            Text(
              'Amount Owed',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 20.sp,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: controller.amountOwedController,
              readOnly: true,
              prefixIconConstraints: BoxConstraints(maxWidth: 50.w),
              hintText: 'Enter Cost Received',
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Image.asset(AppImages.kDollarIcon, scale: 4),
              ),
            ),
            SizedBox(height: 27.h),
            Text(
              'Paid By',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 20.sp,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            SimpleDropdown<PublicUserModel>(
              itemBuilder: (p0) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    p0.displayName.toString(),
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black87,
                      fontSize: 14.0,
                    ),
                  ),
                );
              },
              hintText: 'Select',
              items:
                  getUsersWithHavingDues(
                    controller.expenseToSettle!,
                    controller.tripModel.value!,
                  ).map((e) => e).toList(),

              onChanged: (selected) {
                controller.selectedUser.value = selected;
              },
            ),
            SizedBox(height: 27.h),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: CustomElevatedButton(
          width: Get.width,
          height: Get.height * 0.06,
          title: 'Confirm & Settle',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (c) => AlertDialog(
                    title: Text('Settle Up'),
                    content: Text(
                      'Are you sure you want to settle up with ${controller.selectedUser.value?.urlToImage}?',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.settleUp();
                          Get.back();
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  ),
            );
          },
        ),
      ),
    );
  }
}
