import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordController controller =
      Get.find<ForgotPasswordController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      appBarSize: 0,
      isFullBody: true,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 18.w),
        child: CustomElevatedButton(
          width: Get.width,
          title: l10n.continueText,
          height: 52.02.h,
          onPressed: () {
            if (controller.emailController.text.isEmail) {
              controller.sendPasswordResetEmail();
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
                          l10n.forgotPasswordTitle,
                          textAlign: TextAlign.center,
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.black,
                            fontSize: AppStyles.fontSize24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        l10n.forgotPasswordSubtitle,
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black.withAlpha(140),
                          fontSize: AppStyles.fontSize14,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Obx(
                        () => Column(
                          children: [
                            ResetOptionTile(
                              title: l10n.sendToEmail,
                              subtitle: l10n.resetLinkViaEmail,
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
          const BackButtonWidget(),
        ],
      ),
    );
  }
}
