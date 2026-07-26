import 'dart:convert';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:travel_crew/services/notifications/notfication_services.dart';
import 'package:travel_crew/services/secure_storage_service.dart';
import 'package:travel_crew/utils/logger.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/session_services.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/custom_snackbar.dart';
import '../widgets/email_verification_dialog.dart';

class LoginController extends GetxController {
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
      final email = emailController.text.trim().toLowerCase();
      final result = await AuthService.login(
        email: email,
        password: passwordController.text,
      );

      switch (result) {
        case LoginResult.success:
          if (rememberMe.isTrue) {
            await SecureStorageService.saveInStorage(
              key: 'rememberMeEmail',
              data: jsonEncode({'email': email}),
            );
          } else {
            await SecureStorageService.deleteKey(key: 'rememberMeEmail');
          }
          Get.offAllNamed(kMainViewScreenRoute);
        case LoginResult.emailUnverified:
          GlobalVariables.showLoader.value = false;
          FocusManager.instance.primaryFocus?.unfocus();
          await Get.dialog<void>(
            const EmailVerificationDialog(),
            barrierDismissible: false,
          );
        case LoginResult.failed:
          break;
      }
    } catch (e) {
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
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      GlobalVariables.showLoader.value = true;
      final UserCredential? response = await _googleSignIn();
      if (response != null) {
        await _completeSocialSignIn();
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
      // final authz =
      //     await googleUser.authorizationClient.authorizationForScopes([
      //       'email',
      //       'profile',
      //     ]) ??
      //     await googleUser.authorizationClient.authorizeScopes([
      //       'email',
      //       'profile',
      //     ]);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        // accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      AppLogger.error('Google sign-in failed: $e');
    }
    return null;
  }

  RxBool isPasswordVisible = true.obs;

  Future<void> loginWithApple() async {
    try {
      GlobalVariables.showLoader.value = true;
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oAuthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        oAuthCredential,
      );

      if (userCredential.user != null) {
        final displayName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
        await _completeSocialSignIn(displayName: displayName);
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

  Future<void> _completeSocialSignIn({String? displayName}) async {
    final appUser = await AuthService.getUser();
    var publicProfileUser = appUser;
    final name = displayName?.trim() ?? '';
    final currentName = appUser?.displayName?.trim() ?? '';
    if (appUser != null &&
        name.isNotEmpty &&
        (currentName.isEmpty || currentName.startsWith('User'))) {
      await AuthService.updateUserAttributes(attributes: {'displayName': name});
      publicProfileUser = appUser.copyWith(displayName: name);
      GlobalVariables.loggedInUser.value = publicProfileUser;
    }
    await AuthService.createPublicProfileIfNeeded(publicProfileUser);
    await FirebasePushNotificationApi().saveTokenForCurrentUser();
    showCustomSnackBar(content: 'Login Successful');
    Get.offAllNamed(kMainViewScreenRoute);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void onForgotPassword() {
    Get.toNamed(kForgotPasswordScreenRoute);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
