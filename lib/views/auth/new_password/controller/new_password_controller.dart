import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/logger.dart';

class NewPasswordController extends GetxController {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isPasswordValid = false.obs;
  final RxBool isConfirmPasswordValid = false.obs;
  final RxBool doPasswordsMatch = false.obs;
  final RxBool canSubmit = false.obs;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();

    // Listen to password changes
    passwordController.addListener(() {
      final password = passwordController.text;
      isPasswordValid.value = _isValidPassword(password);
      _checkPasswordsMatch();
      _updateSubmitStatus();
    });

    // Listen to confirm password changes
    confirmPasswordController.addListener(() {
      _checkPasswordsMatch();
      _updateSubmitStatus();
    });
  }

  void _checkPasswordsMatch() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (confirmPassword.isEmpty) {
      isConfirmPasswordValid.value = false;
      doPasswordsMatch.value = false;
    } else {
      isConfirmPasswordValid.value = true;
      doPasswordsMatch.value = password == confirmPassword;
    }
  }

  void _updateSubmitStatus() {
    canSubmit.value = isPasswordValid.value && doPasswordsMatch.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> resetPassword() async {
    try {
      GlobalVariables.showLoader.value = true;
      final email =
          GlobalVariables.loggedInUser.value?.email.trim().toLowerCase() ??
          FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase();
      if (email == null || email.isEmpty) {
        showCustomSnackBar(
          content:
              'Use the forgot password screen to send a password reset email.',
        );
        Get.offNamed(kForgotPasswordScreenRoute);
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      await FirebaseAuth.instance.signOut();
      GlobalVariables.loggedInUser.value = null;
      GlobalVariables.userProfile.value = null;
      showCustomSnackBar(
        content: 'Password reset email sent. Please check your inbox.',
      );
      Get.offAllNamed(kLoginScreenRoute);
    } catch (e) {
      AppLogger.error('Password reset failed: $e');
      showCustomSnackBar(content: 'Password reset email failed');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 && RegExp(r'[\d\W]').hasMatch(password);
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }
}
