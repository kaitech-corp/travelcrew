import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../services/common_services/image_services.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_styles.dart';

class ImagePickerBottomSheet {
  Future<List<String>> getImageFromCameraOrGallery(
    BuildContext context, {
    bool isMultiSelect = false,
  }) async {
    final Completer<List<String>> completer = Completer<List<String>>();
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: Container(
            width: context.width * 0.8,
            height:
                Platform.isIOS ? context.height * 0.23 : context.height * 0.2,
            padding: EdgeInsets.only(top: 20.h),
            decoration: BoxDecoration(
              color: AppColors.kWhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                Center(
                  child: Text(
                    'Choose your preference',
                    style: AppStyles.appBarHeadingTextStyle().copyWith(
                      fontSize: AppStyles.fontSize20,
                      color: AppColors.kPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera,
                    color: AppColors.kPrimaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'Camera',
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: AppStyles.fontSize16,
                      color: AppColors.kPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    if (isMultiSelect) {
                      final List<String> files =
                          await ImageServices().getMultiImages();
                      completer.complete(files);
                      return;
                    }
                    final String file = await ImageServices().getImageCamera();
                    completer.complete([file]);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.kPrimaryColor,
                    size: 20,
                  ),
                  title: Text(
                    'Gallery',
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: AppStyles.fontSize16,
                      color: AppColors.kPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final String file = await ImageServices().getImageGallery();
                    completer.complete([file]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    return completer.future;
  }
}
