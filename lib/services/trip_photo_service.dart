import 'package:cloud_functions/cloud_functions.dart';

/// Suggested URLs are never rendered or stored directly by the client.
class TripPhotoService {
  static Future<Map<String, dynamic>?> prepare(String url) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable(
            'prepareSuggestedTripPhotoV3',
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 120),
            ),
          )
          .call<Map<String, dynamic>>({'image_url': url});
      final data = result.data;
      if (data['status'] != 'ready' || data['url'] is! String) return null;
      return data;
    } catch (_) {
      // Older deployments and failed image processing still allow trip saves.
      return null;
    }
  }
}
