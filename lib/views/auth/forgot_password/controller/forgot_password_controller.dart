import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_strings.dart';

import '../../../../services/otp_service.dart';
import '../../../../utils/custom_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedOption = 0.obs;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();

  void selectOption(int index) {
    selectedOption.value = index;
  }

  void onContinue() {
    if (selectedOption.value == 0) {
      String email = emailController.text.trim();
      if (email.isNotEmpty && GetUtils.isEmail(email)) {}
    } else {
      String phone = phoneController.text.trim();
      if (phone.isNotEmpty) {}
    }
  }

  void onBack() {
    Get.back();
  }

  sendOtp() async {
    try {
      GlobalVariables.showLoader.value = true;
      String code = SendGridEmailService.generateOtp();
      await SendGridEmailService.sendEmailWithSendGrid(
        toEmail: emailController.text,
        subject: 'Password Reset Code',
        message: 'Your password reset code is: $code',
      ).then((response) async {
        GlobalVariables.toVerify = emailController.text;
        GlobalVariables.isEmail = true;
        if (response) {
          showCustomSnackBar(content: 'OTP sent successfully');
          SendGridEmailService.addOtp(email: emailController.text, otp: code);
          Get.toNamed(kOtpScreenRoute, arguments: 'email');
        } else {
          showCustomSnackBar(content: 'Failed to send OTP');
        }
      });
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }
}
