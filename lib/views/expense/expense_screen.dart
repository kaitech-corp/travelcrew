import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/expense/controller/expense_conrtoller.dart';
import 'package:travel_crew/views/expense/widgets/expense_details_widget.dart';

import '../../utils/app_styles.dart';
import '../custom_widgets/custom_scaffold.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key, this.fromMainView = false});
  final bool fromMainView;

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseController controller = Get.find<ExpenseController>();

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      controller.tripModel.value = Get.arguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.expenses,
      isBackIcon: false,
      centerTitle: true,
      actions: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                final trip = controller.tripModel.value;
                if (trip == null) {
                  return;
                }

                Get.toNamed(
                  kAddExpenseScreenRoute,
                  arguments: {
                    'tripId': trip.id,
                    'trip': trip,
                    'tripMembers': trip.joindUsersList ?? [],
                    'onAdd': (ExpenseModel expense) {
                      controller.tripModel.value?.expenses ??= [];
                      controller.tripModel.value?.expenses?.add(expense);
                      controller.tripModel.refresh();
                    },
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: Image.asset(AppImages.kAddExpenseIcon, scale: 4),
              ),
            ),
          ],
        ),
      ],
      scaffoldKey: controller.scaffoldKey,
      className: widget.runtimeType.toString(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Stack(
              children: [
                Image.asset(
                  AppImages.kTotalCostImage,

                  width: context.width,
                  fit: BoxFit.fill,
                  scale: 4,
                ),
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  bottom: 16.h,
                  right: 16.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalCost,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.white,
                          fontSize: AppStyles.fontSize20,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '\$ ${0 + (controller.tripModel.value?.expenses?.fold(0.0, (previousValue, element) => (previousValue ?? 0) + element.amount) ?? 0)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppStyles.fontSize20,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.whoOwesWhat,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize18,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              final settlements = controller.optimalSettlements;
              final currentUid = GlobalVariables.loggedInUser.value?.uid ?? '';
              final users = controller.tripModel.value?.joindUsersList ?? [];

              String nameFor(String uid) {
                if (uid == currentUid) return 'You';
                return users
                    .firstWhere((u) => u.uid == uid, orElse: () => users.first)
                    .displayName;
              }

              if (settlements.isEmpty) {
                return Text(
                  'All settled up!',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: const Color(0xFF4AD10B),
                    fontSize: AppStyles.fontSize13,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: settlements.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final s = settlements[index];
                  final isCurrentUserPaying = s.fromUserId == currentUid;
                  return Row(
                    children: [
                      Image.asset(AppImages.kMemberIcon, scale: 4),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          '${nameFor(s.fromUserId)} → ${nameFor(s.toUserId)}',
                          style: AppStyles.labelTextStyle().copyWith(
                            color:
                                isCurrentUserPaying
                                    ? const Color(0xFFD9534F)
                                    : const Color(0xFF1F1F1F),
                            fontSize: AppStyles.fontSize13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '\$${s.amount.toStringAsFixed(2)}',
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
              );
            }),
            SizedBox(height: 20.h),
            Text(
              l10n.expenseDetails,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            Obx(
              () =>
                  controller.tripModel.value?.expenses?.isEmpty ?? true
                      ? Center(child: Text(l10n.noExpenses))
                      : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            controller.tripModel.value?.expenses?.length ?? 0,
                        separatorBuilder:
                            (context, index) => SizedBox(height: 20.h),
                        itemBuilder: (context, index) {
                          return ExpenseDetailsWidget(
                            controller: controller,
                            usersWithHavingDues: getUsersWithHavingDues(
                              controller.tripModel.value!.expenses![index],
                              controller.tripModel.value!,
                            ),
                            isPending:
                                (controller
                                        .tripModel
                                        .value
                                        ?.joinedUsers
                                        ?.length ??
                                    0) !=
                                (controller
                                        .tripModel
                                        .value
                                        ?.expenses?[index]
                                        .paidByUsers
                                        .length ??
                                    0),
                            tripModel: controller.tripModel.value!,
                            expenseModel:
                                controller.tripModel.value!.expenses![index],
                          );
                        },
                      ),
            ),

            SizedBox(height: widget.fromMainView ? 120.h : 30.h),
          ],
        ),
      ),
    );
  }
}
