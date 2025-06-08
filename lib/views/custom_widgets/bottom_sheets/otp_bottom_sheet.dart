import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pinput/pinput.dart';

import '../../../services/session_services.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_styles.dart';
import '../custom_elevated_button.dart';
import '../info_row.dart';
import '../text_widget.dart';

class OtpBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController otpController;
  final bool isTimerComplete;
  final String email;
  final VoidCallback onResend;
  final VoidCallback onVerify;
  final RxInt count;
  const OtpBottomSheet({
    super.key,
    required this.otpController,
    required this.isTimerComplete,
    required this.email,
    required this.onResend,
    required this.onVerify,
    required this.title,
    required this.description,
    required this.count,
  });
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: GlobalVariables.showLoader.value,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 15.h,
            children: [
              Row(
                spacing: 10.w,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back),
                  ),
                  TextWidget(
                    labelText: title,
                    style: AppStyles.appBarHeadingTextStyle().copyWith(
                      fontSize: 20.sp,
                      color: AppColors.kBlackColor,
                      fontWeight: FontWeight.w600,
                      height: 1.80,
                      letterSpacing: 0.20,
                    ),
                  ),
                ],
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: description,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Color(0x99141414),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                    ),
                    TextSpan(
                      text: ' ',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: AppColors.kBlackColor,
                      ),
                    ),
                    TextSpan(
                      text: email,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: AppColors.kPrimaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Pinput(
                  length: 4,
                  controller: otpController,
                  submittedPinTheme: PinTheme(
                    width: 56.w,
                    height: 56.h,
                    textStyle: AppStyles.labelTextStyle().copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kWhiteColor,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.kSecondaryColor),
                      color: AppColors.kSecondaryColor,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 56.w,
                    height: 56.h,
                    textStyle: AppStyles.labelTextStyle().copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.kSecondaryColor),
                      color: AppColors.kSecondaryColor,
                    ),
                  ),
                  defaultPinTheme: PinTheme(
                    width: 56.w,
                    height: 56.h,
                    textStyle: AppStyles.labelTextStyle().copyWith(
                      fontSize: 22,
                      color: AppColors.kSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              Center(
                child: Obx(
                  () => InfoRow(
                    text: "Resend again in ${count.value} secs",
                    icon: Icon(
                      Icons.restore_outlined,
                      size: 16.sp,
                      color: AppColors().klabeltextcolor,
                    ),
                  ),
                ),
              ),
              if (count.value == 0) ...{
                TextWidget(
                  labelText: 'Resend',
                  onTap: onResend,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: AppColors.kBlackColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              },
              CustomElevatedButton(
                isShadow: false,
                width: Get.width,
                height: Get.height * 0.07,
                title: 'Verify',
                onPressed: onVerify,
              ),
              Platform.isIOS ? SizedBox(height: 10.h) : SizedBox(height: 0.h),
            ],
          ),
        ),
      ),
    );
  }
}
