import 'package:awesome_snackbar_content/awesome_snackbar_content.dart'
    show ContentType;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/secure_storage_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

class ChangePasswordController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FocusNode currentPasswordFocus = FocusNode(),
      newPasswordFocus = FocusNode(),
      confirmPasswordFocus = FocusNode();

  Future<void> updatePasssword() async {
    try {
      GlobalVariables.showLoader.value = true;
      await SecureStorageService.verifyOldPassword(
        passwordToCheck: currentPasswordController.text,
      ).then((value) async {
        if (value) {
          if (newPasswordController.text == confirmPasswordController.text) {
            await AuthService.updatePasword(
              newPassword: newPasswordController.text,
            );
          } else {
            showCustomSnackBar(
              title: 'Error',
              contentType: ContentType.failure,
              content: "New password and confirm password doesn't match.",
            );
          }
        }
        GlobalVariables.showLoader.value = false;
      });
    } catch (e) {
      GlobalVariables.showLoader.value = false;
    }
  }
}
