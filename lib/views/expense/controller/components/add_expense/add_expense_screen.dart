import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_field.dart';
import 'package:travel_crew/views/expense/controller/components/add_expense/controller/add_expense_controller.dart';

import '../../../../../utils/app_styles.dart';
import '../../../../../utils/common_code.dart';
import '../../../../custom_widgets/custom_scaffold.dart';
import '../../../../custom_widgets/date_range_picker/range_picker_dialogue.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final AddExpenseController controller = Get.find<AddExpenseController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller.initializeFromArguments(Get.arguments);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.addExpense,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
      centerTitle: true,
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
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
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Please enter expense name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 27.h),
              Text(
                l10n.amountPaid,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              CustomTextField(
                hintText: l10n.enterTotalCost,
                controller: controller.amountController,
                prefixIconConstraints: BoxConstraints(maxWidth: 40.w),
                prefixIcon: Image.asset(AppImages.kDollarIcon, scale: 4),
              ),
              SizedBox(height: 27.h),
              Text(
                l10n.date,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize20,
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
                            : l10n.selectDate,
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black,
                          fontSize: AppStyles.fontSize13,
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
              Text(
                'Split Options',
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.splitType.value,
                  items: [
                    const DropdownMenuItem(
                      value: 'equally',
                      child: Text('Split Equally'),
                    ),
                    const DropdownMenuItem(
                      value: 'custom',
                      child: Text('Custom Split'),
                    ),
                  ],
                  onChanged: (value) {
                    controller.splitType.value = value!;
                  },
                ),
              ),
              SizedBox(height: 12.h),
              Obx(() {
                if (controller.splitType.value == 'custom') {
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.tripMembers.length,
                        itemBuilder: (context, index) {
                          final member = controller.tripMembers[index];
                          return GestureDetector(
                            onTap: () {
                              controller.toggleMemberSelection(member.uid);
                            },
                            child: CheckboxListTile(
                              title: Text(member.displayName),
                              value: controller.selectedMembers.contains(
                                member.uid,
                              ),
                              onChanged: (value) {
                                controller.toggleMemberSelection(member.uid);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomElevatedButton(
          width: Get.width,
          height: Get.height * 0.06,
          title: l10n.saveExpense,
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
