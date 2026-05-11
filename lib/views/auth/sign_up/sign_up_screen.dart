import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/auth/login/widgets/social_button.dart';
import 'package:travel_crew/views/auth/sign_up/controller/sign_up_controller.dart';

import '../../../utils/app_images.dart';
import '../../custom_widgets/custom_elevated_button.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController controller = Get.find<SignUpController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: '',
      // leadingWidth: ,
      centerTitle: true,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Text(
                l10n.signup,
                textAlign: TextAlign.center,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize28,

                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColors.kGreyColor.withAlpha(51),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.email_outlined,
                        color: Colors.black.withAlpha(140),
                        size: AppStyles.fontSize20,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.email,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black.withAlpha(140),
                      fontSize: AppStyles.fontSize14,

                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CustomTextField(
                controller: controller.emailController,
                focusNode: controller.emailFocus,
                hintText: 'Enter your email',
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Please enter your email';
                  } else if (!p0.isEmail) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Image.asset(AppImages.kPasswordIcon, scale: 4),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.password,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black.withAlpha(140),
                      fontSize: AppStyles.fontSize14,

                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CustomTextField(
                focusNode: controller.passwordFocus,
                hintText: 'Enter Password',
                controller: controller.passwordController,
                keyboardType: TextInputType.visiblePassword,
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Please enter your password';
                  } else if (p0.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Image.asset(AppImages.kPasswordIcon, scale: 4),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.confirmPassword,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black.withAlpha(140),
                      fontSize: AppStyles.fontSize14,

                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CustomTextField(
                textInputAction: TextInputAction.done,
                focusNode: controller.confirmPasswordFocus,
                hintText: 'Enter Confirm Password',
                keyboardType: TextInputType.visiblePassword,
                validator: (p0) {
                  if (controller.passwordController.text != p0) {
                    return 'Password and Confirm Password must be same';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: controller.isRememberMe.toggle,
                child: Row(
                  children: [
                    Obx(
                      () => DottedBorder(
                        options: CircularDottedBorderOptions(
                          color:
                              controller.isRememberMe.isTrue
                                  ? AppColors.kPrimaryColor
                                  : const Color(0xFF666666),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color:
                              controller.isRememberMe.isTrue
                                  ? AppColors.kPrimaryColor
                                  : const Color(0xFF666666),
                          size: AppStyles.fontSize18,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      l10n.agreeToTerms,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: const Color(0xFF666666),
                        fontSize: AppStyles.fontSize14,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomElevatedButton(
                width: Get.width,
                title: l10n.signup,
                backgroundColor: AppColors.kPrimaryColor,
                onPressed: () {
                  if (controller.isRememberMe.isTrue) {
                    if (controller.formKey.currentState!.validate()) {
                      controller.createAccount();
                    }
                  } else {
                    showCustomSnackBar(
                      contentType: ContentType.warning,
                      content: 'Please agree with the Terms of Service',
                    );
                  }
                },
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton(
                    icon: AppImages.kFaceBookIcon,
                    onTap: controller.onFacebookSignIn,
                  ),
                  SizedBox(width: 24.w),
                  SocialButton(
                    icon: AppImages.kGoogleIcon,
                    onTap: controller.onGoogleSignIn,
                  ),
                  SizedBox(width: 24.w),
                  SocialButton(
                    icon: AppImages.kAppleIcon,
                    onTap: controller.onAppleSignIn,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF333333),
                      fontSize: AppStyles.fontSize14,

                      fontWeight: FontWeight.w500,
                      height: 1.29,
                    ),
                  ),
                  const SizedBox(width: 4), // spacing
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      'Sign In',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: AppColors.kPrimaryColor,
                        fontSize: AppStyles.fontSize14,

                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
