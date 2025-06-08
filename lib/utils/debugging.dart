import 'package:flutter/foundation.dart';
void kLogging(String message) {
  if (kDebugMode) {
    print(message);
  }
}
