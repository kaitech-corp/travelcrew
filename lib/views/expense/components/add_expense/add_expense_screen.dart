import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_field.dart';
import 'package:travel_crew/views/expense/components/add_expense/controller/add_expense_controller.dart';

import '../../../../utils/app_styles.dart';
import '../../../../utils/common_code.dart';
import '../../../custom_widgets/custom_scaffold.dart';
import '../../../custom_widgets/date_range_picker/range_picker_dialogue.dart';

class AddExpenseScreen extends GetView<AddExpenseController> {
  const AddExpenseScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: 'Add Expense',
      isBackIcon: true,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      centerTitle: true,
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
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
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Please enter expense name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 27.h),
              Text(
                'Amount Paid',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: 20.sp,

                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                hintText: 'Enter Total Cost',
                controller: controller.amountController,
                prefixIconConstraints: BoxConstraints(maxWidth: 40.w),
                prefixIcon: Image.asset(AppImages.kDollarIcon, scale: 4),
              ),
              SizedBox(height: 27.h),
              Text(
                'Date',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: 20.sp,

                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () async {
                  CommonCode().removeTextFieldFocus();
                  showDialog(
                    context: context,
                    builder:
                        (c) => RangeCalendarDialog(
                          focusedDay:
                              controller.expenceDate.value ?? DateTime.now(),
                          initialDate: DateTime(DateTime.now().year - 1),
                          lastDate: DateTime(DateTime.now().year + 4),
                          onDateSelected: (d) {
                            controller.expenceDate.value = d;
                          },
                        ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17.44,
                    vertical: 15.70,
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.kLightGreyColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27.91),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.expenceDate.value != null
                            ? DateFormat(
                              'EEE, dd MMM',
                            ).format(controller.expenceDate.value!)
                            : 'Select Date',
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black,
                          fontSize: 13.95,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Image.asset(
                        AppImages.kCalendarIcon,
                        scale: 4,
                        color: AppColors.kBlackColor,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 27.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: CustomElevatedButton(
          width: Get.width,
          height: Get.height * 0.06,
          title: 'Save Expense',
          onPressed: () {
            if (controller.formKey.currentState!.validate()) {
              controller.addExpense();
            }
          },
        ),
      ),
    );
  }
}
