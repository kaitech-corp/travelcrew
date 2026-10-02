import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/continent_model.dart';

class CommonCode {
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain atleast one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain atleast one number.';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain atleast one special characters.';
    }
    return null;
  }

  static String? isValidConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (confirmPassword.isEmpty) {
      return 'You need to confirm password before proceeding';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match. Please enter again!';
    }
    return null;
  }

  static String? validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegExp = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format';
    }
    return null;
  }

  bool removeTextFieldFocus() {
    final FocusScopeNode currentFocus = FocusScope.of(Get.context!);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
      return true;
    }
    return false;
  }

  static bool isValidEmail(String email) {
    final bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
    log('=====================is email valid $emailValid');
    return emailValid;
  }

  bool isValidPhone(String? inputString, {bool isRequired = false}) {
    bool isInputStringValid = false;
    if (!isRequired && (inputString == null ? true : inputString.isEmpty)) {
      isInputStringValid = true;
    }
    if (inputString != null && inputString.isNotEmpty) {
      if (inputString.length > 16 || inputString.length < 6) return false;
      const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
      final regExp = RegExp(pattern);
      isInputStringValid = regExp.hasMatch(inputString);
    }
    return isInputStringValid;
  }

  static String getGreeting() {
    final hour = DateTime.now().toLocal().hour; // Get the current hour (0-23)
    if (hour >= 5 && hour < 12) {
      return 'Good Morning 🌄';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon ☀️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening 🌇';
    } else {
      return 'Good Night 🌙';
    }
  }

  static String timeAgo(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  static bool isVideo({required String url}) {
    return url.toLowerCase().endsWith('.mp4') ||
        url.toLowerCase().endsWith('.mov') ||
        url.toLowerCase().endsWith('.wmv') ||
        url.toLowerCase().endsWith('.flv') ||
        url.toLowerCase().endsWith('.avi') ||
        url.toLowerCase().endsWith('.mkv');
  }

  static Map<String, dynamic> parseFirestoreMap(
    Map<String, dynamic>? firestoreData,
  ) {
    if (firestoreData == null) {
      return {};
    }

    final Map<String, dynamic> result = {};

    firestoreData.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        if (value.containsKey('stringValue')) {
          result[key] = value['stringValue'];
        } else if (value.containsKey('doubleValue')) {
          result[key] = value['doubleValue'];
        } else if (value.containsKey('integerValue')) {
          result[key] = int.tryParse(value['integerValue'].toString());
        } else if (value.containsKey('booleanValue')) {
          result[key] = value['booleanValue'];
        } else if (value.containsKey('arrayValue')) {
          // Handle array values
          result[key] =
              (value['arrayValue']['values'] as List?)
                  ?.map((e) => parseFirestoreMap(e as Map<String, dynamic>))
                  .toList() ??
              [];
        } else {
          result[key] = value; // fallback
        }
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  static String getContinentFromLatLng(double lat, double lng) {
    for (final box in kContinentBoxes) {
      if (box.contains(lat, lng)) {
        return box.name;
      }
    }
    return '';
  }

  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  static String formatMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
