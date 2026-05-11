import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_strings.dart';

import '../../../../utils/custom_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final selectedOption = 0.obs;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();

  void selectOption(int index) {
    selectedOption.value = index;
  }

  void onContinue() {
    if (selectedOption.value == 0) {
      final String email = emailController.text.trim();
      if (email.isNotEmpty && GetUtils.isEmail(email)) {
        sendPasswordResetEmail();
      }
    } else {
      final String phone = phoneController.text.trim();
      if (phone.isNotEmpty) {}
    }
  }

  void onBack() {
    Get.back();
  }

  Future<void> sendPasswordResetEmail() async {
    try {
      GlobalVariables.showLoader.value = true;
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      showCustomSnackBar(
        content: 'Password reset email sent. Please check your inbox.',
      );
      Get.offAllNamed(kLoginScreenRoute);
    } on FirebaseAuthException catch (e) {
      showCustomSnackBar(content: e.message ?? 'An error occurred.');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    emailFocusNode.dispose();
    super.onClose();
  }
}
