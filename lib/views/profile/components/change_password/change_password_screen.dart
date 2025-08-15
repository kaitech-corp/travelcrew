import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_field.dart';
import 'package:travel_crew/views/profile/components/change_password/controller/change_password_controller.dart';

import '../../../../utils/app_styles.dart';
import '../../../custom_widgets/custom_scaffold.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.changePassword,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      centerTitle: true,
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30.h),
              Row(
                children: [
                  Image.asset(AppImages.kLockIcon, scale: 4),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.oldPassword,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black.withAlpha(140),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CustomTextField(
                hintText: l10n.enterOldPassword,
                controller: controller.currentPasswordController,
                focusNode: controller.currentPasswordFocus,
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 27.h),
              Row(
                children: [
                  Image.asset(AppImages.kLockIcon, scale: 4),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.password,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black.withAlpha(140),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CustomTextField(
                hintText: l10n.enterNewPassword,
                controller: controller.newPasswordController,
                focusNode: controller.newPasswordFocus,
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return 'Please enter password';
                  } else if (p0.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 27.h),
              Row(
                children: [
                  Image.asset(AppImages.kLockIcon, scale: 4),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.confirmPassword,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black.withAlpha(140),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CustomTextField(
                hintText: l10n.confirmPasswordHint,
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return 'Please enter password';
                  } else if (p0 != controller.newPasswordController.text) {
                    return "Password doesn't match";
                  }
                  return null;
                },
                controller: controller.confirmPasswordController,
                focusNode: controller.confirmPasswordFocus,
              ),
              SizedBox(height: 43.h),
              CustomElevatedButton(
                width: Get.width,
                title: l10n.continueText,
                onPressed: () {
                  if (controller.formKey.currentState!.validate()) {
                    controller.updatePasssword();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
