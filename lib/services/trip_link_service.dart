import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'notifications/notification_navigation.dart';

/// Links contain only an identifier. Firestore still enforces trip access.
String? tripIdFromLink(Uri uri) {
  if (uri.scheme != 'travelcrew' ||
      uri.host != 'trips' ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      uri.hasQuery ||
      uri.hasFragment ||
      uri.pathSegments.length != 1) {
    return null;
  }
  final id = uri.pathSegments.single;
  return RegExp(
        r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
      ).hasMatch(id)
      ? id
      : null;
}

class TripLinkService {
  static final AppLinks _links = AppLinks();
  static StreamSubscription<Uri>? _subscription;

  static Future<void> initialize() async {
    if (kIsWeb || _subscription != null) return;
    // uriLinkStream includes the initial link and links received while running.
    _subscription = _links.uriLinkStream.listen(
      (uri) {
        final id = tripIdFromLink(uri);
        if (id != null) {
          NotificationNavigation.receive({
            'type': 'Trip',
            'notificationForId': id,
          });
        }
      },
      onError: (Object error) {
        debugPrint('Unable to open trip link: ${error.runtimeType}');
      },
    );
  }
}
