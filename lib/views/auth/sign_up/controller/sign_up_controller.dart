import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/app_utils.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/session_services.dart';

class SignUpController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Rxn<Country?> selectedCountry = Rxn();
  GlobalKey<FormState> profileSetupFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxString selectedImage = ''.obs;
  GlobalKey<ScaffoldState> profileSetupKey = GlobalKey<ScaffoldState>();
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
  RxBool isRememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    GlobalVariables.loggedInUser.value?.phone =
        GlobalVariables.loggedInUser.value?.phone?.replaceAll('+', '') ?? '';
    if (GlobalVariables.loggedInUser.value?.phone != null &&
        GlobalVariables.loggedInUser.value?.phone != '') {
      detectCountryFromNumber(GlobalVariables.loggedInUser.value?.phone ?? '');
    }
  }

  void onSignIn() {
    // Implement sign in logic
  }

  Future<void> createAccount() async {
    try {
      GlobalVariables.showLoader.value = true;
      await AuthService.checkEmailExistence(emailController.text).then((
        v,
      ) async {
        GlobalVariables.showLoader.value = false;
        // if (!v) {
        final newUser = UserModel(
          displayName: userNameController.text,
          email: emailController.text,
          uid: const Uuid().v4(),
          emailConfirmed: false,
          // profileImage: '',
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
      });
    } catch (e) {
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

  void onForgotPassword() {}
  void onGoogleSignIn() {
    // Implement Google sign in
  }
  void onFacebookSignIn() {
    // Implement Facebook sign in
  }
  void onAppleSignIn() {
    // Implement Apple sign in
  }
  void onSignUp() {
    // Navigate to sign up screen
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
        GlobalVariables.showLoader.value = F;
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

    GlobalVariables.showLoader.value = F;
  }
}
