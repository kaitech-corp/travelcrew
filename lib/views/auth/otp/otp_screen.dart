import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';

import '../../../utils/app_images.dart';
import '../../custom_widgets/back_button_widget.dart';
import '../../custom_widgets/custom_elevated_button.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'controller/otp_controller.dart';

class OtpScreen extends GetView<OtpController> {
  OtpScreen({super.key});
  bool firstTime = true;
  @override
  Widget build(BuildContext context) {
    if (firstTime) {
      firstTime = false;
      Future.microtask(() {
        controller.startTimer();
      });
    }
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      appBarSize: 0,
      isFullBody: true,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15.h),
                AnyImageView(
                  url:
                      Get.arguments == 'phone'
                          ? AppImages.kCheckYourPhoneOtpScreen
                          : AppImages.kOtpBgImage,
                  width: Get.width,
                  fileType: SourceType.asset,
                  height: Get.height * 0.42,
                ),
                SizedBox(height: 5.h),
                Center(
                  child: Text(
                    'Check Your ${Get.arguments == 'phone' ? 'Phone' : 'Email'}',
                    textAlign: TextAlign.center,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black,
                      fontSize: 24.sp,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                SizedBox(
                  width: Get.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'We have sent a confirmation code for password recovery to ',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: Colors.black.withValues(alpha: 140),
                              fontSize: 14.95,

                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                          TextSpan(
                            text:
                                Get.arguments == 'phone'
                                    ? '+1******90'
                                    : '${GlobalVariables.loggedInUser.value?.email[0] ?? ''}*********@${GlobalVariables.loggedInUser.value?.email.split('@').last ?? ''}',
                            style: AppStyles.labelTextStyle().copyWith(
                              color: const Color(0xFF1D7FC2),
                              fontSize: 14.95,

                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Pinput(
                    length: 5,
                    controller: controller.otpController,
                    focusNode: controller.focusNode,
                    defaultPinTheme: controller.defaultPinTheme,
                    focusedPinTheme: controller.focusedPinTheme,
                    submittedPinTheme: controller.submittedPinTheme,
                    pinAnimationType: PinAnimationType.fade,
                    onChanged: controller.onOtpChanged,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    showCursor: true,
                    cursor: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 7.w),
                        Container(
                          // margin: const EdgeInsets.only(bottom: 12),
                          width: 2,
                          height: 22,
                          color: const Color(0xFF1D7FC2),
                        ),
                      ],
                    ),
                    separatorBuilder: (index) => SizedBox(width: 16.w),
                  ),
                ),
                SizedBox(height: 22.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 1.5,
                        backgroundColor: Colors.black.withValues(alpha: .4),
                      ),
                      Obx(
                        () => Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '  The code will expire in: ',

                                style: AppStyles.labelTextStyle().copyWith(
                                  color: Colors.black.withValues(alpha: 140),
                                  fontSize: 14.95,

                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                              TextSpan(
                                text: controller.remainingTime.value,
                                style: AppStyles.labelTextStyle().copyWith(
                                  color: Colors.black,
                                  fontSize: 14.95,

                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                          // textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 1.5,
                        backgroundColor: Colors.black.withValues(alpha: .4),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '  You didn´t receive the code? ',
                              style: AppStyles.labelTextStyle().copyWith(
                                color: Colors.black.withValues(alpha: 0.55),
                                fontSize: 14.95,

                                fontWeight: FontWeight.w500,
                                height: 1.25,
                              ),
                            ),
                            TextSpan(
                              text: 'Resend',
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      controller.resendOtp();
                                    },
                              style: AppStyles.labelTextStyle().copyWith(
                                color: const Color(0xFF1D7FC2),
                                fontSize: 14.sp,

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                CustomElevatedButton(
                  width: Get.width * 0.85,
                  height: Get.height * 0.06,
                  title: 'Verify',
                  onPressed: () {
                    controller.verifyOtp();
                    // if (controller.isOtpComplete.value) {
                    //   controller.verifyOtp();
                    //   Get.toNamed(kMainViewScreenRoute);
                    // }
                  },
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.kInfoIcon, scale: 4),
                    SizedBox(width: 10.h),
                    Text(
                      'Need help?',
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
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Please send any feedback or bug reports to\n',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.black.withValues(alpha: 140),
                            fontSize: 13.08,

                            fontWeight: FontWeight.w500,
                            height: 1.29,
                          ),
                        ),
                        TextSpan(
                          text: 'RoamAI@asistant.com',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: const Color(0xFF1D7FC2),
                            fontSize: 13.08,

                            fontWeight: FontWeight.w500,
                            height: 1.29,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
