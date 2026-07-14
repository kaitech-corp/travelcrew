import 'package:flutter_app_badge/flutter_app_badge.dart';

class NotificationBadgeService {
  static Future<void> setCount(int count) {
    return FlutterAppBadge.count(count);
  }

  static Future<void> clear() {
    return FlutterAppBadge.count(0);
  }
}
