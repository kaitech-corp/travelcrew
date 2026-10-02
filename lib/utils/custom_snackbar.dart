import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';

void showCustomSnackBar({
  required String content,
  String? title,
  ContentType contentType = ContentType.success,
  Function()? onTap,
  Duration duration = const Duration(seconds: 2),
  Color backgroundColor = AppColors.kPrimaryColor,
}) {
  if (Get.context == null) {
    debugPrint('Get.context is null. Cannot show snackbar.');
    return;
  }
  if (Get.isSnackbarOpen) {
    Get.closeCurrentSnackbar();
  }
  Future.delayed(const Duration(milliseconds: 100), () {
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.transparent,
        duration: duration,
        // margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        borderRadius: 8.0,
        messageText: GestureDetector(
          onTap: onTap,
          child: Container(
            // padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
            child: AwesomeSnackbarContent(
              color: backgroundColor,
              title: title ?? '',
              message: content,
              contentType: contentType,
            ),
          ),
        ),
      ),
    );
  });
}
