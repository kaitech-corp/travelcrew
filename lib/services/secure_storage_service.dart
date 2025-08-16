import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travel_crew/utils/app_strings.dart';

import '../utils/custom_snackbar.dart';

class SecureStorageService {
  static Future<bool> verifyOldPassword({
    bool toDelete = false,
    required String passwordToCheck,
  }) async {
    try {
      if (readByKey(key: kPasswordKey) == passwordToCheck) {
        return true;
      } else {
        showCustomSnackBar(
          title: 'Error',
          contentType: ContentType.failure,
          content: "Password doesn't match with old password.",
        );
      }
    } catch (e) {}
    return false;
  }

  static AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  static Future<void> saveInStorage({required String key, required String data}) async {
    try {
      final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

      await storage.write(key: key, value: data);
    } catch (e) {
      if(kDebugMode){print(e);}
    }
  }

  static Future<String?> readByKey({required String key}) async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    return storage.read(key: key);
  }

  static Future<void> deleteKey({required String key}) async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    await storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    await storage.deleteAll();
  }

  static Future<Map<String, String>> readAll() async {
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    return storage.readAll();
  }
}
