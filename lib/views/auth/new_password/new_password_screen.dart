import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_field.dart';

import '../../../utils/app_images.dart';
import '../../custom_widgets/back_button_widget.dart';
import '../../custom_widgets/custom_elevated_button.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'controller/new_password_controller.dart';

class NewPasswordScreen extends GetView<NewPasswordController> {
  const NewPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      appBarSize: 0,
      isFullBody: true,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      body: Stack(
        children: [
          Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AnyImageView(
                    url: AppImages.kForgotPasswordBgImage,
                    width: Get.width,
                    fileType: SourceType.asset,
                    height: Get.height * 0.4,
                  ),
                  Center(
                    child: Text(
                      l10n.createNewPassword,
                      textAlign: TextAlign.center,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: 24.sp,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    width: Get.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        l10n.newPasswordSubtitle,
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black.withAlpha(140),
                          fontSize: 14.95,

                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(AppImages.kPasswordIcon, scale: 4),
                            SizedBox(width: 10.w),
                            Text(
                              l10n.password,
                              style: AppStyles.labelTextStyle().copyWith(
                                color: Colors.black,
                                fontSize: 14.67,

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Password Fieldm
                        CustomTextField(
                          hintText: 'Enter password',
                          controller: controller.passwordController,
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (p0.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          focusNode: controller.passwordFocusNode,
                        ),
                        SizedBox(height: 22.h),
                        Row(
                          children: [
                            Image.asset(AppImages.kPasswordIcon, scale: 4),
                            SizedBox(width: 10.w),
                            Text(
                              l10n.confirmPassword,
                              style: AppStyles.labelTextStyle().copyWith(
                                color: Colors.black,
                                fontSize: 14.67,

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        CustomTextField(
                          hintText: 'Confirm password',
                          controller: controller.confirmPasswordController,
                          focusNode: controller.confirmPasswordFocusNode,
                          validator:
                              (p0) =>
                                  controller.doPasswordsMatch.value
                                      ? null
                                      : 'Passwords do not match',
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 24.w),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'Password must contain:',
                  //         style:AppStyles.labelTextStyle().copyWith(
                  //           color: Colors.black.withValues(alpha:0.7),
                  //           fontSize: 14.sp,
                  //
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //       SizedBox(height: 8.h),
                  //       Row(
                  //         children: [
                  //           Obx(() => Icon(
                  //             controller.isPasswordValid.value
                  //                 ? Icons.check_circle
                  //                 : Icons.circle_outlined,
                  //             color: controller.isPasswordValid.value
                  //                 ? Colors.green
                  //                 : Colors.grey,
                  //             size: 16.sp,
                  //           )),
                  //           SizedBox(width: 8.w),
                  //           Text(
                  //             'At least 8 characters',
                  //             style:AppStyles.labelTextStyle().copyWith(
                  //               color: Colors.black.withValues(alpha:0.7),
                  //               fontSize: 14.sp,
                  //
                  //               fontWeight: FontWeight.w400,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       SizedBox(height: 8.h),
                  //       Row(
                  //         children: [
                  //           Obx(() => Icon(
                  //             controller.doPasswordsMatch.value && controller.isConfirmPasswordValid.value
                  //                 ? Icons.check_circle
                  //                 : Icons.circle_outlined,
                  //             color: controller.doPasswordsMatch.value && controller.isConfirmPasswordValid.value
                  //                 ? Colors.green
                  //                 : Colors.grey,
                  //             size: 16.sp,
                  //           )),
                  //           SizedBox(width: 8.w),
                  //           Text(
                  //             'Passwords match',
                  //             style:AppStyles.labelTextStyle().copyWith(
                  //               color: Colors.black.withValues(alpha:0.7),
                  //               fontSize: 14.sp,
                  //
                  //               fontWeight: FontWeight.w400,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  //
                  SizedBox(height: 20.h),

                  CustomElevatedButton(
                    width: Get.width * 0.85,
                    height: Get.height * 0.06,
                    title: l10n.continueText,
                    onPressed: () {
                      if (controller.formKey.currentState?.validate() ==
                          false) {
                        return;
                      }
                      controller.resetPassword();

                      // controller.canSubmit.value?
                      //   Get.dialog(
                      //     Center(
                      //       child: CongratulationsDialog(),
                      //     ),
                      //   ): null;
                    },
                  ),

                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.kInfoIcon, scale: 4),
                      SizedBox(width: 10.h),
                      Text(
                        l10n.needHelp,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black,
                          fontSize: 14.95,

                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: Get.width,
                    child: Text(
                      l10n.feedbackRequest,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          const BackButtonWidget(),
        ],
      ),
    );
  }
}
