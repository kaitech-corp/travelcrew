import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

import '../../../custom_widgets/dialogs/well_done_dialog.dart';

class NewPasswordController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
      isPasswordValid.value = password.length >= 8;
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

      /// use firebase cloud function to reset password
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        kResetUserPasswordFunction,
      );
      final result = await callable.call({
        'email': GlobalVariables.loggedInUser.value?.email ?? '',
        'newPassword': passwordController.text,
      });
      // To check the result:
      if (result.data['success'] == true) {
        Get.dialog(const Center(child: WellDoneDialog()), barrierColor: Colors.grey);
      } else {
        // Password reset failed
        showCustomSnackBar(content: 'Password reset failed');
      }
    } catch (e) {}
    GlobalVariables.showLoader.value = F;
  }
}
