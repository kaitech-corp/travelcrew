import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:travel_crew/services/notifications/notfication_services.dart';
import 'package:travel_crew/services/secure_storage_service.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/session_services.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/custom_snackbar.dart';

class LoginController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;
  @override
  void onInit() {
    super.onInit();
    // Check if remember me data exists in secure storage
    SecureStorageService.readByKey(key: 'rememberMeEmail').then((data) {
      if (data != null) {
        final credentials = jsonDecode(data);
        emailController.text = credentials['email'] ?? '';
        rememberMe.value = true;
      }
    });
    SecureStorageService.deleteKey(key: 'rememberMe');
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Future<void> login() async {
    try {
      GlobalVariables.showLoader.value = true;
      // Login logic
      final bool loginSuccess = await AuthService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (loginSuccess) {
        if (!AuthService.isCurrentUserEmailVerified()) {
          GlobalVariables.showLoader.value = false;
          showCustomSnackBar(
            contentType: ContentType.warning,
            title: 'Email Verification Required',
            content:
                'Please verify your email to continue. Check your inbox for a verification link.',
          );
          return;
        }

        GlobalVariables.showLoader.value = false;
        if (rememberMe.isTrue) {
          await SecureStorageService.saveInStorage(
            key: 'rememberMeEmail',
            data: jsonEncode({'email': emailController.text}),
          );
        } else {
          await SecureStorageService.deleteKey(key: 'rememberMeEmail');
        }
        Get.offAllNamed(kMainViewScreenRoute);
      } else {
        GlobalVariables.showLoader.value = false;
      }
    } catch (e) {
      GlobalVariables.showLoader.value = false;
      String message;
      if (e is FirebaseAuthException) {
        message = e.message ?? 'An unknown authentication error occurred.';
      } else {
        message = e.toString();
      }
      showCustomSnackBar(
        contentType: ContentType.failure,
        title: 'Error',
        content: message,
      );
      // Consider if validateError logic needs to be adapted for Firebase
      // validateError(message, email: emailController.text);
    }
    GlobalVariables.showLoader.value = false;
  }

  static Future<void> validateError(String message, {String? email}) async {
    if (message == 'Email not confirmed') {
      // This was Supabase specific. For Firebase, you might trigger
      // FirebaseAuth.instance.currentUser?.sendEmailVerification()
      // or navigate to a screen that prompts the user to verify their email.
      // The exact implementation depends on your app's flow.
      // try {
      //   // Example: If you want to resend verification email
      //   // User? user = FirebaseAuth.instance.currentUser;
      //   // if (user != null && !user.emailVerified && user.email == email) {
      //   //   await user.sendEmailVerification();
      //   //   showCustomSnackBar(content: 'Verification email sent.');
      //   // }
      //   GlobalVariables.toVerify = email;
      //   GlobalVariables.isEmail = true;
      //   // Potentially update user model or navigate
      //   Get.toNamed(kOtpScreenRoute, arguments: 'fromSignUp');
      // } catch (e) {
      //   showCustomSnackBar(
      //     contentType: ContentType.failure,
      //     title: 'Error',
      //     content: e.toString(),
      //   );
      // }
      debugPrint(
        'Email not confirmed. Original email: $email. Implement Firebase email verification resend if needed.',
      );
      // For now, just showing a snackbar
      showCustomSnackBar(
        contentType: ContentType.warning,
        title: 'Email Verification',
        content: 'Please verify your email address.',
      );
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      GlobalVariables.showLoader.value = true;
      final UserCredential? response = await _googleSignIn();
      if (response != null) {
        await AuthService.getUser();
        await FirebasePushNotificationApi().saveTokenForCurrentUser();
        showCustomSnackBar(content: 'Login Successful');
        Get.offAllNamed(kMainViewScreenRoute);
      }
    } on FirebaseAuthException catch (e) {
      showCustomSnackBar(
        title: 'Error',
        contentType: ContentType.failure,
        content: e.message ?? 'Google sign-in error.',
      );
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        contentType: ContentType.failure,
        content: 'An unexpected error occurred',
      );
    }
    GlobalVariables.showLoader.value = false;
  }

  Future<UserCredential?> _googleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
    }
    return null;
  }

  Future<void> continueAsGuest() async {
    try {
      GlobalVariables.showLoader.value = true;
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      if (userCredential.user != null) {
        await AuthService.getUser();
        await FirebasePushNotificationApi().saveTokenForCurrentUser();
        GlobalVariables.showLoader.value = false;
        Get.toNamed(kMainViewScreenRoute);
      } else {
        GlobalVariables.showLoader.value = false;
        showCustomSnackBar(
          title: 'Error',
          contentType: ContentType.failure,
          content: 'Could not sign in as guest.',
        );
      }
    } on FirebaseAuthException catch (e) {
      GlobalVariables.showLoader.value = false;
      showCustomSnackBar(
        title: 'Error',
        contentType: ContentType.failure,
        content: e.message ?? 'Anonymous sign-in error.',
      );
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        contentType: ContentType.failure,
        content: 'An unexpected error occurred',
      );
    }
    GlobalVariables.showLoader.value = false;
  }

  RxBool isRememberMe = false.obs;

  RxBool isPasswordVisible = true.obs;

  Future<void> loginWithApple() async {
    try {
      GlobalVariables.showLoader.value = true;
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        oAuthCredential,
      );

      if (userCredential.user != null) {
        await AuthService.getUser();
        await FirebasePushNotificationApi().saveTokenForCurrentUser();
        showCustomSnackBar(content: 'Login Successful');
        Get.offAllNamed(kMainViewScreenRoute);
      }
    } catch (e) {
      showCustomSnackBar(
        title: 'Error',
        contentType: ContentType.failure,
        content: 'An unexpected error occurred during Apple sign-in.',
      );
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void onForgotPassword() {
    Get.toNamed(kForgotPasswordScreenRoute);
  }
}
