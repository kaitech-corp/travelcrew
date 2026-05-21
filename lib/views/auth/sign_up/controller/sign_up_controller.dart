import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/app_utils.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/session_services.dart';
import '../../login/controller/login_controller.dart';

class SignUpController extends GetxController {
  Rxn<Country?> selectedCountry = Rxn();
  GlobalKey<FormState> profileSetupFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxString selectedImage = ''.obs;
  TextEditingController emailController = TextEditingController(),
      phoneController = TextEditingController(),
      userNameController = TextEditingController(
        text: GlobalVariables.loggedInUser.value?.displayName ?? '',
      ),
      passwordController = TextEditingController();
  FocusNode emailFocus = FocusNode(),
      phoneFocus = FocusNode(),
      userNameFocus = FocusNode(),
      passwordFocus = FocusNode(),
      confirmPasswordFocus = FocusNode();
  RxBool agreedToTerms = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (GlobalVariables.loggedInUser.value == null) return;
    GlobalVariables.loggedInUser.value?.phone =
        GlobalVariables.loggedInUser.value?.phone?.replaceAll('+', '') ?? '';
    if (GlobalVariables.loggedInUser.value?.phone != null &&
        GlobalVariables.loggedInUser.value?.phone != '') {
      detectCountryFromNumber(GlobalVariables.loggedInUser.value?.phone ?? '');
    }
  }

  Future<void> createAccount() async {
    try {
      GlobalVariables.showLoader.value = true;
      final newUser = UserModel(
        displayName: userNameController.text.trim(),
        email: emailController.text.trim().toLowerCase(),
        uid: const Uuid().v4(),
        emailConfirmed: false,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        phone: '',
      );
      GlobalVariables.loggedInUser.value = newUser;
      await AuthService.signUp(
        user: newUser,
        password: passwordController.text,
      );
      emailController.clear();
      passwordController.clear();
      phoneController.clear();
      userNameController.clear();
    } catch (e) {
      AppLogger.error('Error during account creation: $e');
      GlobalVariables.showLoader.value = false;
      showCustomSnackBar(
        contentType: ContentType.failure,
        content: 'Failed to create account. Please try again.',
      );
    }
  }

  void detectCountryFromNumber(String number) {
    // Extract the dial code, e.g., +92
    for (final country in countries) {
      if (number.startsWith(country.dialCode)) {
        selectedCountry.value = country;
        phoneController.text = number
            .replaceFirst(country.dialCode, '')
            .replaceFirst('+', '');
        break;
      }
    }
  }

  void onGoogleSignIn() {
    Get.find<LoginController>().loginWithGoogle();
  }

  void onFacebookSignIn() {
    showCustomSnackBar(
      contentType: ContentType.warning,
      content: 'Facebook sign-in is not available yet.',
    );
  }

  void onAppleSignIn() {
    Get.find<LoginController>().loginWithApple();
  }

  Future<void> updateProfile() async {
    try {
      GlobalVariables.showLoader.value = true;
      String? image;
      if (selectedImage.value.isNotEmpty) {
        image = await uploadImageToFirebaseStorage(
          imagePath: selectedImage.value,
          title: 'Uploading profile image',
          subtitle: 'Uploading profile image',
          imageName:
              '${GlobalVariables.loggedInUser.value?.uid ?? const Uuid().v4()}_profile_image',
        );
      }

      await AuthService.updateUserAttributes(
        attributes: {
          'profileImage':
              image ?? GlobalVariables.loggedInUser.value?.profileImage ?? '',
          'phone':
              '${selectedCountry.value?.dialCode ?? '1'}${phoneController.text}',
          'displayName': userNameController.text,
        },
      ).then((v) {
        GlobalVariables.showLoader.value = false;
        if (v) {
          selectedImage.value = '';
          GlobalVariables
              .loggedInUser
              .value = GlobalVariables.loggedInUser.value?.copyWith(
            profileImage:
                image ?? GlobalVariables.loggedInUser.value?.profileImage,
            phone:
                '${selectedCountry.value?.dialCode ?? '1'}${phoneController.text}',
            displayName: userNameController.text,
          );
          if (Get.arguments == 'fromProfile') {
            Get.back();
          } else {
            Get.offAllNamed(kMainViewScreenRoute);
            showCustomSnackBar(
              content:
                  'Profile ${Get.arguments == 'fromProfile' ? 'updated ' : 'completed'} successfully!',
            );
          }
        } else {
          showCustomSnackBar(
            contentType: ContentType.failure,
            content:
                'Failed to ${Get.arguments == 'fromProfile' ? 'update ' : 'complete'} profile',
          );
        }
      });
    } catch (e) {
      showCustomSnackBar(
        contentType: ContentType.failure,
        content:
            'Failed to ${Get.arguments == 'fromProfile' ? 'update ' : 'complete'} profile',
      );
    }

    GlobalVariables.showLoader.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    userNameFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}
