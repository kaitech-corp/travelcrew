import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/models/public_user_model.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.settleUp,
      scaffoldKey: controller.expenseSettleScaffoldKey,
      className: runtimeType.toString(),
      centerTitle: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              l10n.expenseName,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              hintText: l10n.enterExpenseName,
              controller: controller.expenseNameController,
              readOnly: true,
            ),
            SizedBox(height: 27.h),
            Text(
              l10n.amountOwed,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextField(
              controller: controller.amountOwedController,
              readOnly: true,
              prefixIconConstraints: BoxConstraints(maxWidth: 50.w),
              hintText: l10n.enterCostReceived,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Image.asset(AppImages.kDollarIcon, scale: 4),
              ),
            ),
            SizedBox(height: 27.h),
            Text(
              l10n.paidBy,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            SimpleDropdown<PublicUserModel>(
              itemBuilder: (p0) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    p0.displayName.toString(),
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black87,
                      fontSize: AppStyles.fontSize14,
                    ),
                  ),
                );
              },
              hintText: l10n.select,
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
        padding: const EdgeInsets.all(20),
        child: CustomElevatedButton(
          width: Get.width,
          height: Get.height * 0.06,
          title: l10n.confirmAndSettle,
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (c) => AlertDialog(
                    title: Text(l10n.settleUp),
                    content: Text(
                      l10n.confirmSettleUp.toString().replaceFirst('{userName}', controller.selectedUser.value?.displayName ?? ''),
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.settleUp();
                          Get.back();
                        },
                        child: Text(l10n.confirm),
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
