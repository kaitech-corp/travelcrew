import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/auth/login/widgets/social_button.dart';

import '../../../utils/app_images.dart';
import '../../custom_widgets/custom_elevated_button.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/custom_text_field.dart';
import 'controller/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      isFullBody: true,
      leadingWidth: 0,
      centerTitle: true,
      scaffoldKey: controller.scaffoldKey,
      className: 'Profile',
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50.h),
                Image.asset(AppImages.kAppLogo, height: 206.h, width: 206.w),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: AppColors.kGreyColor.withValues(alpha: 0.2),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.email_outlined,
                          color: Colors.black.withValues(alpha: 140),
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Email',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: 14.67,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  controller: controller.emailController,
                  hintText: 'Email',
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
                      'Password',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: 14.67,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Obx(
                  () => CustomTextField(
                    textInputAction: TextInputAction.done,
                    controller: controller.passwordController,
                    hintText: 'Enter Password',
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    suffixIcon: GestureDetector(
                      onTap: () {
                        controller.isPasswordVisible.toggle();
                      },
                      child: Icon(
                        controller.isPasswordVisible.isTrue
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.w,
                        color: Colors.grey[600],
                      ),
                    ),
                    obscureText: controller.isPasswordVisible.value,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: controller.isRememberMe.toggle,
                      child: Row(
                        children: [
                          Obx(
                            () => DottedBorder(
                              color:
                                  controller.isRememberMe.isTrue
                                      ? AppColors.kPrimaryColor
                                      : const Color(0xFF666666),
                              borderType: BorderType.Circle,
                              child: Icon(
                                Icons.check_circle,
                                color:
                                    controller.isRememberMe.isTrue
                                        ? AppColors.kPrimaryColor
                                        : Color(0xFF666666),
                                size: 18.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'Remember Me',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: const Color(0xFF666666),
                              fontSize: 14.sp,

                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: controller.onForgotPassword,
                      child: Text(
                        'Forgot password?',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: AppColors.kPrimaryColor,
                          fontSize: 14.67,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                CustomElevatedButton(
                  width: Get.width,
                  title: 'Sign In',
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      controller.login();
                    }
                  },
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Container(
                      width: 109.31.w,
                      decoration: ShapeDecoration(
                        color: AppColors.kLightGreyColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.92.w,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: AppColors.kLightGreyColor,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Or Sign In with',
                      style: AppStyles.labelTextStyle().copyWith(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 109.31.w,
                      decoration: ShapeDecoration(
                        color: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.92.w,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: AppColors.kLightGreyColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButton(icon: AppImages.kFaceBookIcon, onTap: () {}),
                    SizedBox(width: 24.w),
                    SocialButton(
                      icon: AppImages.kGoogleIcon,
                      onTap: controller.loginWithGoogle,
                    ),
                    SizedBox(width: 24.w),
                    SocialButton(
                      icon: AppImages.kAppleIcon,
                      onTap: controller.loginWithApple,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don’t have an account?',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: const Color(0xFF333333),
                        fontSize: 14,

                        fontWeight: FontWeight.w500,
                        height: 1.29,
                      ),
                    ),
                    const SizedBox(width: 4), // spacing
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(kSignUpScreenRoute);
                      },
                      child: Text(
                        'Sign Up',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: AppColors.kPrimaryColor,
                          fontSize: 14.sp,

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
      ),
    );
  }
}
