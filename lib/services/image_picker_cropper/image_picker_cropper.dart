import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../functions/cloud_functions.dart';

class ImagePickerAndCropper {
  Future<File> uploadImage(ValueNotifier<File> urlToImage) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File? croppedFile = await _cropImage(pickedFile.path);
        return croppedFile ?? File(pickedFile.path);
      }
    } catch (e) {
      CloudFunction().logError('Error Picking signup image: $e');
    }
    return urlToImage.value;
  }

  Future<File?> _cropImage(String imagePath) async {
    final CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imagePath,
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
    return croppedImage != null ? File(croppedImage.path) : null;
  }
}
