import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';

import '../services/notifications/notfication_services.dart';
import 'custom_snackbar.dart';

class AppUtils {
  static showConfirmationDialogue({
    required String title,
    String? description,
    String btnYesText = 'YES',
    String btnNoText = 'NO',
    required Function() onPressedYes,
    Function()? onPressedNo,
  }) async {
    await showCupertinoDialog(
      barrierDismissible: true,
      context: Get.context!,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: description != null ? Text(description) : null,
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: onPressedYes,
                child: Text(btnYesText),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.kPrimaryColor,
                ),
                onPressed:
                    onPressedNo ??
                    () {
                      Get.back();
                    },
                child: Text(btnNoText),
              ),
            ],
          ),
    );
  }
}

Future<String> uploadImageToFirebaseStorage({
  required String imagePath,
  required String imageName,
  String? title,
  String? subtitle,
  String folderName = 'users_profile',
  id = 0,
}) async {
  try {
    // Correctly construct the full path
    final baseRef = FirebaseStorage.instance.ref().child(
      '$folderName',
    );

    // Append user ID if folder is 'users_profile'
    final fullRef =
        folderName == 'users'
            ? baseRef
                .child(GlobalVariables.loggedInUser.value!.uid)
                .child(imageName)
            : baseRef.child(imageName);

    final uploadTask = fullRef.putFile(File(imagePath));

    // Listen to upload progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      FirebasePushNotificationApi().showProgressNotification(
        progress.toInt(),
        id,
        title: title,
        subTitle: subtitle,
      );
    });

    // Wait for completion
    // final snapshot = 
    await uploadTask.whenComplete(() {
      FirebasePushNotificationApi().showCompletionNotification(id: id);
    });

    // Get download URL
    final imageUrl = await fullRef.getDownloadURL();
    return imageUrl;
  } catch (e) {
    debugPrint('Upload Error: $e');
    showCustomSnackBar(content: 'Failed to upload image');
    return '';
  }
}
