import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/services/image_upload_policy.dart';

import '../services/notifications/notfication_services.dart';
import 'custom_snackbar.dart';

class AppUtils {
  static Future<void> showConfirmationDialogue({
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
  String? tripId,
  int id = 0,
}) async {
  StreamSubscription<TaskSnapshot>? progressSubscription;
  var notifications = Future<void>.value();
  var completed = false;
  try {
    final path = ImageUploadPolicy.privateObjectPath(
      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
      folder: folderName,
      name: imageName,
      tripId: tripId,
    );
    final file = File(imagePath);
    final size = await file.length();
    final header = await file
        .openRead(0, min(size, 512))
        .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
    final type = ImageUploadPolicy.contentType(size, header);
    final fullRef = FirebaseStorage.instance.ref(path);
    final uploadTask = fullRef.putFile(
      file,
      SettableMetadata(contentType: type),
    );
    var lastProgress = -1;
    progressSubscription = uploadTask.snapshotEvents.listen(
      (snapshot) {
        if (snapshot.totalBytes <= 0) return;
        final progress =
            ((snapshot.bytesTransferred / snapshot.totalBytes) * 100).floor();
        if (progress == lastProgress) return;
        lastProgress = progress;
        // Notification availability must not change the outcome of an upload.
        notifications = notifications
            .then(
              (_) => FirebasePushNotificationApi().showProgressNotification(
                progress,
                id,
                title: title,
                subTitle: subtitle,
              ),
            )
            .catchError((Object error) {
              debugPrint(
                'Upload progress notification unavailable: ${error.runtimeType}',
              );
            });
      },
      onError: (Object error) {
        // The task Future below owns failure reporting.
      },
    );
    await uploadTask;
    final imageReference = 'gs://${fullRef.bucket}/${fullRef.fullPath}';
    await progressSubscription.cancel();
    progressSubscription = null;
    await notifications;
    await FirebasePushNotificationApi()
        .showCompletionNotification(id: id)
        .catchError((Object error) {
          debugPrint(
            'Upload completion notification unavailable: ${error.runtimeType}',
          );
        });
    completed = true;
    return imageReference;
  } on FormatException catch (error) {
    showCustomSnackBar(content: error.message);
    rethrow;
  } catch (error) {
    debugPrint(
      'Image upload failed: ${error is FirebaseException ? error.code : error.runtimeType}',
    );
    showCustomSnackBar(
      content: 'Could not upload the image. Please try again.',
    );
    rethrow;
  } finally {
    await progressSubscription?.cancel();
    if (!completed) {
      await notifications;
      try {
        await FirebasePushNotificationApi().cancelUploadNotification(id);
      } catch (error) {
        debugPrint(
          'Upload notification cleanup unavailable: ${error.runtimeType}',
        );
      }
    }
  }
}
