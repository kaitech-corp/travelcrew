import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/otp_service.dart';
import 'package:travel_crew/services/secure_storage_service.dart';

import '../models/user_model.dart';
import '../utils/app_strings.dart';
import '../utils/custom_snackbar.dart';
import 'session_services.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = firestore;

  static Future<void> validateUser({fromSplash = false}) async {
    final user = _auth.currentUser;
    if (user != null) {
      GlobalVariables.loggedInUser.value = await AuthService.getUser();
      if (GlobalVariables.loggedInUser.value == null) {
        Get.offAllNamed(kOnboardingScreenRoute);
        return;
      }
      if (GlobalVariables.loggedInUser.value != null &&
          GlobalVariables.loggedInUser.value?.email_confirmed == false) {
        GlobalVariables.fromLoginScreen = true;
        try {
          String code = SendGridEmailService.generateOtp(); // Generate OTP code
          await SendGridEmailService.sendEmailWithSendGrid(
            toEmail: user.email ?? '',
            subject: 'Email Verification',
            message: 'Your verification code is: $code',
          ).then((value) async {
            if (value) {
              SendGridEmailService.addOtp(email: user.email ?? '', otp: code);
              showCustomSnackBar(
                contentType: ContentType.warning,
                content: 'Verify your email to continue',
              );
              GlobalVariables.fromLoginScreen = false;
              Get.toNamed(kOtpScreenRoute, arguments: 'fromSignUp');
            } else {
              showCustomSnackBar(
                contentType: ContentType.failure,
                title: 'Error',
                content: 'Failed to send verification email.',
              );
              if (fromSplash) {
                // Get.offAllNamed(kOnboardingScreenRoute);
                Get.offAllNamed(kMainViewScreenRoute);
              } else {
                Get.offAllNamed(kLoginScreenRoute);
              }
              return;
            }
          });

          return;
        } catch (e) {
          GlobalVariables.fromLoginScreen = false;
          return;
        }
      }
      Get.offAllNamed(kMainViewScreenRoute);
      if (!fromSplash) {
        showCustomSnackBar(
          contentType: ContentType.success,
          title: 'Success',
          content: 'Logged in successfully',
        );
      }
    }
  }

  static Future<UserModel?> getUser({String? userId}) async {
    try {
      String? userid = userId ?? _auth.currentUser?.uid;
      if (userid != null) {
        print('Fetching user with ID: $userid');
        DocumentSnapshot userDoc =
            await _firestore.collection(kUsersCollection).doc(userid).get();
        if (userDoc.exists) {
          print('User document exists: ${userDoc.data()}');
          UserModel user = UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
          );
          if (userId == null && user.isDeleted) {
            // showCustomSnackBar(
            //   contentType: ContentType.failure,
            //   title: 'Error',
            //   content: 'Account deleted. Please contact support.',
            // );
            return null;
          }
          return user;
        } else {
          // Create a new user if the document does not exist
          UserModel newUser = UserModel(
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            uid: userid,
            email: _auth.currentUser?.email ?? '',
            displayName:
                _auth.currentUser?.displayName ??
                'User' + userid.substring(0, 5),
            phone: _auth.currentUser?.phoneNumber ?? '',
            isDeleted: false, // Default to false
            email_confirmed: false, // Default to false
          );
          await _firestore
              .collection(kUsersCollection)
              .doc(userid)
              .update(newUser.toMap());
          GlobalVariables.loggedInUser.value = newUser;
          return newUser;
        }
      }
    } catch (e) {}
    return null;
  }

  static Future<PublicUserModel?> getUserPublicProfile({String? userId}) async {
    try {
      String? userid = userId ?? _auth.currentUser?.uid;
      if (userid != null) {
        print('Fetching user with ID: $userid');
        DocumentSnapshot userDoc =
            await _firestore.collection(kUsersCollection).doc(userid).get();
        if (userDoc.exists) {
          print('User document exists: ${userDoc.data()}');
          PublicUserModel user = PublicUserModel.fromMap(
            userDoc.data() as Map<String, dynamic>,
          );
          return user;
        }
      } else {
        print('No user ID provided, returning mock data');
        return null;
      }
    } catch (e) {
      print('Error fetching user public profile: $e');
      return null;
    }
    return null;
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      GlobalVariables.showLoader.value = true;
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      GlobalVariables.loggedInUser.value = await AuthService.getUser(
        userId: credential.user?.uid,
      );
      if (GlobalVariables.loggedInUser.value == null) {
        showCustomSnackBar(content: 'Credentials not valid or account deleted');
        return false;
      }
      GlobalVariables.showLoader.value = false;
      // SecureStorageService.saveInStorage(key: kPasswordKey, data: password);
      // await FirebaseMessaging.instance.subscribeToTopic(_auth.currentUser!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      GlobalVariables.showLoader.value = false;
      if (e.code == 'user-not-found') {
        showCustomSnackBar(
          contentType: ContentType.failure,
          title: 'Error',
          content: 'No user found for that email.',
        );
      } else if (e.code == 'wrong-password') {
        showCustomSnackBar(
          contentType: ContentType.failure,
          title: 'Error',
          content: 'Wrong password provided for that user.',
        );
      } else if (e.code == 'invalid-credential') {
        showCustomSnackBar(content: e.message.toString());
      } else {
        showCustomSnackBar(
          contentType: ContentType.failure,
          title: 'Error',
          content: e.message ?? 'An unknown error occurred.',
        );
      }
      return false;
    } catch (e) {
      GlobalVariables.showLoader.value = false;
      return false;
    }
  }

  static Future<void> signUp({
    required UserModel user,
    required String password,
  }) async {
    try {
      GlobalVariables.showLoader.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );
      user.uid = userCredential.user!.uid;
      await _firestore
          .collection(kUsersCollection)
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      // await userCredential.user!.sendEmailVerification();
      String code = SendGridEmailService.generateOtp(); // Generate OTP code
      await SendGridEmailService.sendEmailWithSendGrid(
        toEmail: user.email,
        subject: 'Email Verification',
        message: 'Your verfication code is: $code',
      ).then((value) async {
        if (value) {
          SendGridEmailService.addOtp(email: user.email, otp: code);
          showCustomSnackBar(
            contentType: ContentType.success,
            title: 'Success',
            content: 'Account created successfully',
          );
          Get.toNamed(kOtpScreenRoute, arguments: 'fromSignUp');
        } else {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: 'Failed to send verification email.',
          );
        }
      });
    } catch (e) {
      GlobalVariables.showLoader.value = false;
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: 'Email already in use.',
          );
        } else if (e.code == 'invalid-email') {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: 'Invalid email address.',
          );
        } else {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: e.message ?? 'An unknown error occurred.',
          );
        }
      } else {
        showCustomSnackBar(content: e.toString());
      }
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  static Future<bool> checkEmailExistence(String email) async {
    final result =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
    return result.docs.isNotEmpty;
  }

  static Future<Map<String, dynamic>> checkUserExistence(
    String email,
    String phone,
  ) async {
    final emailCheck =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

    final phoneCheck =
        await _firestore
            .collection('users')
            .where('phone', isEqualTo: phone)
            .get();

    return {
      'email_exists': emailCheck.docs.isNotEmpty,
      'phone_exists': phoneCheck.docs.isNotEmpty,
    };
  }

  static Future<bool> validateUserExistance({
    required String email,
    required String phone,
  }) async {
    try {
      final result = await checkUserExistence(email, phone);

      if (result['email_exists'] && result['phone_exists']) {
        showCustomSnackBar(
          title: 'Error',
          content: 'Both email and phone are already in use.',
        );
        return false;
      } else if (result['email_exists']) {
        showCustomSnackBar(
          title: 'Error',
          content: 'This email is already registered.',
        );
        return false;
      } else if (result['phone_exists']) {
        showCustomSnackBar(
          title: 'Error',
          content: 'This phone number is already registered.',
        );
        return false;
      }
      return true;
    } catch (e) {
      showCustomSnackBar(
        contentType: ContentType.failure,
        title: 'Error',
        content: e.toString(),
      );
      return false;
    }
  }

  static Future<bool> updateUserAttributes({
    required Map<String, dynamic> attributes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update(attributes);
        return true;
      }
    } catch (e) {}
    return false;
  }

  static Future<void> signOut() async {
    try {
      GlobalVariables.showLoader.value = true;
      await _auth.signOut();
      Get.offAllNamed(kLoginScreenRoute);
    } catch (e) {
      showCustomSnackBar(
        contentType: ContentType.failure,
        title: 'Error',
        content: e.toString(),
      );
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  static Future<bool> updatePasword({required String newPassword}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword).then((_) async {
          await SecureStorageService.saveInStorage(
            key: kPasswordKey,
            data: newPassword,
          );
          GlobalVariables.showLoader.value = false;
          showCustomSnackBar(
            contentType: ContentType.success,
            title: 'Success',
            content: 'Password updated successfully',
          );
          Get.offAllNamed(kLoginScreenRoute);
        });
        return true;
      }
    } catch (e) {
      GlobalVariables.showLoader.value = false;
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: 'The password provided is too weak.',
          );
        } else if (e.code == 'requires-recent-login') {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content:
                'Please reauthenticate to update your password. Try logging in again.',
          );
        } else {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: e.message ?? 'An unknown error occurred.',
          );
        }
      }
    }
    return false;
  }

  static Future<List<PublicUserModel>> getTripUsers({
    required List<String> userIds,
  }) async {
    try {
      final tripUsers =
          await _firestore
              .collection(kUsersCollection)
              .where(FieldPath.documentId, whereIn: userIds)
              .get();

      if (tripUsers.docs.isNotEmpty) {
        return tripUsers.docs
            .map((user) => PublicUserModel.fromMap(user.data()))
            .toList();
      }
    } catch (e) {}
    return [];
  }

  static deleteAccount() async {
    try {
      GlobalVariables.showLoader.value = true;
      await updateUserAttributes(attributes: {'isDeleted': true}).then((
        value,
      ) async {
        if (value) {
          showCustomSnackBar(content: 'Account deleted successfully');
          Get.offAllNamed(kLoginScreenRoute);
        } else {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: 'Failed to delete account. Please try again later.',
          );
        }
      });
    } catch (e) {}
    GlobalVariables.showLoader.value = false;
  }
}
