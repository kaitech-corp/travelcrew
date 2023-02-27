import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../functions/cloud_functions.dart';

class ImagePickerAndCropper {
  Future<File> uploadImage(ValueNotifier<File> urlToImage) async {
    try {
      final XFile? pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // urlToImage.value =  File(pickedFile.path);
        final File? croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          return croppedFile;
        } else {
          return File(pickedFile.path);
        }
      } else {
        return urlToImage.value;
      }
    } catch (e) {
      CloudFunction().logError('Error Picking signup image: $e');
      return urlToImage.value;
    }
  }

  Future<File?> _cropImage(File? pickedFile) async {
    if (pickedFile != null) {
      final CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: <CropAspectRatioPreset>[
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: <PlatformUiSettings>[
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedImage != null) {
        return File(croppedImage.path);
      } else {
        return pickedFile;
      }
    } else {
      return null;
    }
  }
}
