import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:travel_crew/services/otp_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

import '../../../../services/auth_service.dart';
import '../../../../utils/app_strings.dart';
import '../../../custom_widgets/dialogs/congratulations_dialog.dart';

class OtpController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final otpController = TextEditingController();
  final focusNode = FocusNode();
  final RxString otpValue = ''.obs;
  final RxBool isOtpComplete = false.obs;

  // Default PIN theme
  // Define pin themes directly without late initialization
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: AppStyles.labelTextStyle().copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F4FA),
      borderRadius: BorderRadius.circular(16),
    ),
  );
  // Initialize other themes based on the default theme
  PinTheme get focusedPinTheme => defaultPinTheme.copyWith(
    decoration: defaultPinTheme.decoration!.copyWith(
      border: Border.all(color: const Color(0xFF1D7FC2), width: 2),
    ),
  );
  PinTheme get submittedPinTheme => defaultPinTheme.copyWith(
    decoration: defaultPinTheme.decoration!.copyWith(
      color: const Color(0xFFE8F4FA),
    ),
  );
  PinTheme get selectedPinTheme => defaultPinTheme.copyWith(
    decoration: defaultPinTheme.decoration!.copyWith(
      border: Border.all(color: const Color(0xFF1D7FC2), width: 2),
    ),
  );

  get resendTapGesture => null;

  void onOtpChanged(String value) {
    otpValue.value = value;
    isOtpComplete.value = value.length == 4;
  }

  Timer? timer;
  int timeInSeconds = 300;
  RxString remainingTime = ''.obs;
  startTimer({int timeInSecond = 300}) {
    timeInSeconds = timeInSecond;
    remainingTime.value =
        '${timeInSeconds ~/ 60}:${(timeInSeconds % 60).toString().padLeft(2, '0')}';
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeInSeconds > 0) {
        timeInSeconds--;
        remainingTime.value =
            '${timeInSeconds ~/ 60}:${(timeInSeconds % 60).toString().padLeft(2, '0')}';
      } else {
        remainingTime.value = '00:00';
        timer.cancel();
      }
    });
  }

  verifyOtp() async {
    // Add your OTP verification logic here
    try {
      if (otpController.length == 5) {
        GlobalVariables.showLoader.value = true;
        await SendGridEmailService.verifyOtp(
          email: GlobalVariables.loggedInUser.value?.email ?? "",
          otp: otpController.text,
        ).then((value) {
          if (value) {
            if (Get.arguments == 'fromSignUp') {
              GlobalVariables.loggedInUser.value?.email_confirmed = true;
              AuthService.updateUserAttributes(
                attributes: {'email_confirmed': true},
              );
              Get.offAndToNamed(kProfileSetUpScreenRoute);
            } else {
              Get.dialog(
                Center(
                  widthFactor: Get.width * 0.7,
                  child: CongratulationsDialog(),
                ),
                barrierColor: Colors.grey,
              );
            }
          }
        });
      } else {
        showCustomSnackBar(content: 'Please enter a valid OTP');
      }
    } catch (e) {
      showCustomSnackBar(content: 'Invalid OTP');
    }
    GlobalVariables.showLoader.value = false;
  }

  resendOtp() async {
    try {
      if (timeInSeconds > 0) {
        showCustomSnackBar(
          contentType: ContentType.warning,
          content: 'Please wait for ${remainingTime.value} to resend OTP',
        );
        return;
      }
      GlobalVariables.showLoader.value = true;
      String code = SendGridEmailService.generateOtp();
      SendGridEmailService.sendEmailWithSendGrid(
            toEmail: GlobalVariables.loggedInUser.value!.email,
            subject:
                Get.arguments == 'fromSignUp'
                    ? 'Email Verification'
                    : 'Password Reset',
            message: 'Your verification code is: $code',
          )
          .then((value) async {
            if (value) {
              SendGridEmailService.addOtp(
                email: GlobalVariables.loggedInUser.value!.email,
                otp: code,
              );
              timeInSeconds = 300;
              showCustomSnackBar(
                contentType: ContentType.warning,
                content: 'Verify your email to continue',
              );
            } else {
              showCustomSnackBar(
                contentType: ContentType.failure,
                title: 'Error',
                content: 'Failed to send verification email.',
              );
            }
          })
          .catchError((e) {
            showCustomSnackBar(
              contentType: ContentType.failure,
              title: 'Error',
              content: e.toString(),
            );
          });
    } catch (e) {}
    GlobalVariables.showLoader.value = false;
  }
}
