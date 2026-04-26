import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/notifications/notfication_services.dart';
import 'package:travel_crew/utils/error_handler.dart';
import 'package:travel_crew/utils/logger.dart';

import '../models/user_model.dart';
import '../utils/app_strings.dart';
import '../utils/custom_snackbar.dart';
import 'session_services.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = firestore;

  static Future<void> validateUser({bool fromSplash = false}) async {
    final user = _auth.currentUser;
    if (user != null) {
      GlobalVariables.loggedInUser.value = await AuthService.getUser();
      if (GlobalVariables.loggedInUser.value == null) {
        Get.offAllNamed(kOnboardingScreenRoute);
        return;
      }

      // Check for public profile and create if it doesn't exist
      await _createPublicProfileIfNeeded(GlobalVariables.loggedInUser.value);

      await _syncEmailVerification(user);
      if (!_canAccessApp(user)) {
        if (!fromSplash) {
          showCustomSnackBar(
            contentType: ContentType.warning,
            title: 'Email Verification Required',
            content: 'Please verify your email to continue. Check your inbox.',
          );
        }
        Get.offAllNamed(kLoginScreenRoute);
        return;
      }

      await FirebasePushNotificationApi().saveTokenForCurrentUser();

      // User is verified and logged in successfully
      Get.offAllNamed(kMainViewScreenRoute);
      if (!fromSplash) {
        showCustomSnackBar(title: 'Success', content: 'Logged in successfully');
      }
    } else {
      Get.offAllNamed(kOnboardingScreenRoute);
    }
  }

  static Future<UserModel?> getUser({String? userId}) async {
    try {
      final String? userid = userId ?? _auth.currentUser?.uid;
      if (userid != null) {
        AppLogger.debug('Fetching user with ID: $userid');

        final DocumentSnapshot userDoc =
            await _firestore.collection(kUsersCollection).doc(userid).get();
        if (userDoc.exists) {
          AppLogger.debug('User document exists for ID: $userid');

          final UserModel user = UserModel.fromMap(
            userDoc.data()! as Map<String, dynamic>,
          );
          if (userId == null && user.isDeleted == true) {
            AppLogger.warning('User account is deleted: $userid');
            return null;
          }
          GlobalVariables.loggedInUser.value = user;
          AppLogger.info('Successfully retrieved user: $userid');
          return user;
        } else {
          AppLogger.info(
            'User document does not exist, creating new user: $userid',
          );

          // Create a new user if the document does not exist
          final UserModel newUser = UserModel(
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
            uid: userid,
            email: _auth.currentUser?.email ?? '',
            displayName:
                _auth.currentUser?.displayName ??
                'User${userid.substring(0, 5)}',
            phone: _auth.currentUser?.phoneNumber ?? '',
            emailConfirmed: false, // Default to false
          );
          await _firestore
              .collection(kUsersCollection)
              .doc(userid)
              .set(newUser.toMap());
          GlobalVariables.loggedInUser.value = newUser;
          AppLogger.info('Successfully created new user: $userid');
          return newUser;
        }
      } else {
        AppLogger.warning('No user ID available for getUser');
      }
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'getUser',
      );
    }
    return null;
  }

  static Future<PublicUserModel?> getUserPublicProfile({String? userId}) async {
    try {
      final String? userid = userId ?? _auth.currentUser?.uid;
      if (userid != null) {
        AppLogger.debug('Fetching public profile for user ID: $userid');

        final DocumentSnapshot userDoc =
            await _firestore
                .collection(kUsersPublicProfileCollection)
                .doc(userid)
                .get();
        if (userDoc.exists) {
          AppLogger.debug('Public profile document exists for ID: $userid');

          final PublicUserModel user = PublicUserModel.fromMap(
            userDoc.data()! as Map<String, dynamic>,
          );
          AppLogger.info('Successfully retrieved public profile: $userid');
          return user;
        } else {
          AppLogger.warning(
            'Public profile document not found for ID: $userid',
          );
        }
      } else {
        AppLogger.warning('No user ID provided for getUserPublicProfile');
        return null;
      }
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'getUserPublicProfile',
      );
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

      // Check for public profile and create if it doesn't exist
      await _createPublicProfileIfNeeded(GlobalVariables.loggedInUser.value);
      await _syncEmailVerification(credential.user);
      if (!_canAccessApp(credential.user)) {
        showCustomSnackBar(
          contentType: ContentType.warning,
          title: 'Email Verification Required',
          content: 'Please verify your email to continue. Check your inbox.',
        );
        GlobalVariables.showLoader.value = false;
        return false;
      }
      await FirebasePushNotificationApi().saveTokenForCurrentUser();

      GlobalVariables.showLoader.value = false;
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
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'login',
      );
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

      await userCredential.user!.sendEmailVerification();
      showCustomSnackBar(
        title: 'Success',
        content: 'Account created successfully. Please verify your email.',
      );
      Get.offAllNamed(kLoginScreenRoute);
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'signUp',
      );
      GlobalVariables.showLoader.value = false;
      if (error is FirebaseAuthException) {
        if (error.code == 'email-already-in-use') {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: 'Email already in use.',
          );
        } else if (error.code == 'invalid-email') {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: 'Invalid email address.',
          );
        } else {
          showCustomSnackBar(
            contentType: ContentType.failure,
            title: 'Error',
            content: error.message ?? 'An unknown error occurred.',
          );
        }
      } else {
        showCustomSnackBar(content: error.toString());
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
      if (kDebugMode) {
        print('Error in validateUserExistance: $e');
      }
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
    } catch (e) {
      if (kDebugMode) {
        print('Error in updateUserAttributes: $e');
      }
    }
    return false;
  }

  static Future<void> signOut() async {
    try {
      GlobalVariables.showLoader.value = true;
      await _auth.signOut();
      Get.offAllNamed(kLoginScreenRoute);
    } catch (e) {
      if (kDebugMode) {
        print('Error in signOut: $e');
      }
      showCustomSnackBar(
        contentType: ContentType.failure,
        title: 'Error',
        content: e.toString(),
      );
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  static Future<bool> updatePasword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-email',
            message: 'Current user does not have an email password credential.',
          );
        }
        final credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        GlobalVariables.showLoader.value = false;
        showCustomSnackBar(
          title: 'Success',
          content: 'Password updated successfully',
        );
        Get.offAllNamed(kLoginScreenRoute);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in updatePasword: $e');
      }
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

  static bool isCurrentUserEmailVerified() {
    final user = _auth.currentUser;
    return user == null || _canAccessApp(user);
  }

  static bool _canAccessApp(User? user) {
    if (user == null) return false;
    if (user.isAnonymous) return true;
    final providerIds = user.providerData.map((p) => p.providerId).toSet();
    if (!providerIds.contains(EmailAuthProvider.PROVIDER_ID)) return true;
    return user.emailVerified;
  }

  static Future<void> _syncEmailVerification(User? user) async {
    if (user == null) return;
    await user.reload();
    final refreshed = _auth.currentUser ?? user;
    if (GlobalVariables.loggedInUser.value?.emailConfirmed !=
        refreshed.emailVerified) {
      GlobalVariables.loggedInUser.value = GlobalVariables.loggedInUser.value
          ?.copyWith(emailConfirmed: refreshed.emailVerified);
      await _firestore.collection(kUsersCollection).doc(refreshed.uid).update({
        'emailConfirmed': refreshed.emailVerified,
      });
    }
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
    } catch (e) {
      if (kDebugMode) {
        print('Error in getTripUsers: $e');
      }
    }
    return [];
  }

  static Future<void> deleteAccount() async {
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
    } catch (e) {
      if (kDebugMode) {
        print('Error in deleteAccount: $e');
      }
    }
    GlobalVariables.showLoader.value = false;
  }

  static Future<bool> followUser(String targetUserId) async {
    try {
      final String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      // Add targetUserId to currentUser's 'following' list
      await _firestore
          .collection(kUsersPublicProfileCollection)
          .doc(currentUserId)
          .update({
            'following': FieldValue.arrayUnion([targetUserId]),
          });

      // Add currentUserId to targetUser's 'followers' list
      await _firestore
          .collection(kUsersPublicProfileCollection)
          .doc(targetUserId)
          .update({
            'followers': FieldValue.arrayUnion([currentUserId]),
          });

      return true;
    } catch (e) {
      AppLogger.error('Error in followUser: $e');
      return false;
    }
  }

  static Future<bool> unfollowUser(String targetUserId) async {
    try {
      final String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      // Remove targetUserId from currentUser's 'following' list
      await _firestore
          .collection(kUsersPublicProfileCollection)
          .doc(currentUserId)
          .update({
            'following': FieldValue.arrayRemove([targetUserId]),
          });

      // Remove currentUserId from targetUser's 'followers' list
      await _firestore
          .collection(kUsersPublicProfileCollection)
          .doc(targetUserId)
          .update({
            'followers': FieldValue.arrayRemove([currentUserId]),
          });

      return true;
    } catch (e) {
      AppLogger.error('Error in unfollowUser: $e');
      return false;
    }
  }

  static Future<List<PublicUserModel>> getFollowers(String userId) async {
    try {
      final userDoc =
          await _firestore
              .collection(kUsersPublicProfileCollection)
              .doc(userId)
              .get();
      if (userDoc.exists) {
        final user = PublicUserModel.fromMap(userDoc.data()!);
        if (user.followers != null && user.followers!.isNotEmpty) {
          final followersDocs =
              await _firestore
                  .collection(kUsersPublicProfileCollection)
                  .where(FieldPath.documentId, whereIn: user.followers)
                  .get();
          return followersDocs.docs
              .map((doc) => PublicUserModel.fromMap(doc.data()))
              .toList();
        }
      }
    } catch (e) {
      AppLogger.error('Error in getFollowers: $e');
    }
    return [];
  }

  static Future<List<PublicUserModel>> getFollowing(String userId) async {
    try {
      final userDoc =
          await _firestore
              .collection(kUsersPublicProfileCollection)
              .doc(userId)
              .get();
      if (userDoc.exists) {
        final user = PublicUserModel.fromMap(userDoc.data()!);
        if (user.following != null && user.following!.isNotEmpty) {
          final followingDocs =
              await _firestore
                  .collection(kUsersPublicProfileCollection)
                  .where(FieldPath.documentId, whereIn: user.following)
                  .get();
          return followingDocs.docs
              .map((doc) => PublicUserModel.fromMap(doc.data()))
              .toList();
        }
      }
    } catch (e) {
      AppLogger.error('Error in getFollowing: $e');
    }
    return [];
  }

  static Future<void> _createPublicProfileIfNeeded(UserModel? user) async {
    if (user == null) return;

    final publicProfileRef = _firestore
        .collection(kUsersPublicProfileCollection)
        .doc(user.uid);
    final publicProfileDoc = await publicProfileRef.get();

    if (!publicProfileDoc.exists) {
      final publicProfile = PublicUserModel(
        displayName: user.displayName ?? user.uid.substring(0, 5),
        email: user.email,
        uid: user.uid,
        profileImage: user.profileImage ?? '',
        followers: [],
        following: [],
        tripsCreated: 0,
        tripsJoined: 0,
      );
      await publicProfileRef.set(publicProfile.toMap());
    }
  }
}
