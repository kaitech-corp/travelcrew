import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/back_button_widget.dart';
import 'package:travel_crew/views/custom_widgets/custom_textfield.dart';

import '../../../utils/app_images.dart';
import '../../../utils/custom_snackbar.dart';
import '../../custom_widgets/any_image_view.dart';
import '../../custom_widgets/custom_elevated_button.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'controller/forgot_password_controller.dart';
import 'widgets/reset_option_tile.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      appBarSize: 0,
      isFullBody: true,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 18.w),
        child: CustomElevatedButton(
          width: Get.width,
          title: 'Continue',
          height: 52.02.h,
          onPressed: () {
            if (controller.emailController.text.isEmail) {
              controller.sendOtp();
            } else {
              showCustomSnackBar(content: 'Please enter a valid email');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                AnyImageView(
                  url: AppImages.kForgotPasswordBgImage,
                  width: Get.width,
                  fileType: SourceType.asset,
                  fit: BoxFit.fitHeight,
                  height: Get.height * 0.36,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18.w, right: 18.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Forgot password?',
                          textAlign: TextAlign.center,
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.black,
                            fontSize: 24.95,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'In order to help you select the contact information that we must use to reset your password',
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black.withValues(alpha: 140),
                          fontSize: 14.sp,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Obx(
                        () => Column(
                          children: [
                            ResetOptionTile(
                              title: 'Send to your email',
                              subtitle: 'Get a password reset link via email',
                              icon: Icon(
                                Icons.email_outlined,
                                color:
                                    controller.selectedOption.value == 0
                                        ? AppColors.kPrimaryColor
                                        : AppColors.kBlackColor,
                                size: 20,
                              ),
                              isSelected: controller.selectedOption.value == 0,
                              onTap: () => controller.selectOption(0),
                            ),
                            SizedBox(height: 16.h),

                            // ResetOptionTile(
                            //   title: 'Send to your phone number',
                            //   subtitle:
                            //       'Get a security code via SMS to +1******90',
                            //   icon: Padding(
                            //     padding: EdgeInsets.all(10),
                            //     child: Image.asset(
                            //       AppImages.kPhoneIcon,
                            //       color:
                            //           controller.selectedOption.value == 1
                            //               ? AppColors.kPrimaryColor
                            //               : AppColors.kBlackColor,
                            //     ),
                            //   ),
                            //   isSelected: controller.selectedOption.value == 1,
                            //   onTap: () => controller.selectOption(1),
                            // ),
                            // SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                      CustomTextFormField(
                        focusNode: controller.emailFocusNode,
                        controller: controller.emailController,
                        hintText: 'Enter your email',
                        textInputType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator:
                            (p0) =>
                                p0!.isEmpty
                                    ? 'Please enter your email'
                                    : GetUtils.isEmail(p0)
                                    ? null
                                    : 'Please enter a valid email',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BackButtonWidget(),
        ],
      ),
    );
  }
}
