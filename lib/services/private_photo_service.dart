import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PrivatePhotoService {
  static const _maxBytes = 20 * 1024 * 1024;
  static const _local = bool.fromEnvironment('TRAVEL_CREW_FIREBASE_EMULATORS');
  static const _host = String.fromEnvironment(
    'TRAVEL_CREW_FIREBASE_EMULATOR_HOST',
    defaultValue: 'localhost',
  );

  static const int _functionsPort = int.fromEnvironment(
    'TRAVEL_CREW_FUNCTIONS_EMULATOR_PORT',
    defaultValue: 5001,
  );

  static bool isPrivateReference(String value) =>
      value.startsWith('gs://') && value.contains('/private_uploads/');

  static Uri endpoint(String reference, {String? projectId}) {
    if (!isPrivateReference(reference)) {
      throw const FormatException('Invalid private photo reference.');
    }
    if (_local &&
        (!kDebugMode ||
            !{'localhost', '127.0.0.1', '10.0.2.2'}.contains(_host))) {
      throw StateError('A debug loopback emulator is required.');
    }
    final project = projectId ?? Firebase.app().options.projectId;
    final base =
        _local
            ? 'http://$_host:$_functionsPort/$project/us-central1/privatePhotoV3'
            : 'https://us-central1-$project.cloudfunctions.net/privatePhotoV3';
    return Uri.parse(base).replace(queryParameters: {'ref': reference});
  }

  static Future<Uint8List> load(String reference, {http.Client? client}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in to view this photo.');
    final uri = endpoint(reference);
    final ownedClient = client == null;
    final httpClient = client ?? http.Client();
    try {
      for (var attempt = 0; attempt < 2; attempt++) {
        final token = await user.getIdToken(attempt == 1);
        if (token == null || token.isEmpty) {
          throw StateError('Sign in to view this photo.');
        }
        final response = await httpClient
            .get(uri, headers: {'Authorization': 'Bearer $token'})
            .timeout(const Duration(seconds: 30));
        if (response.statusCode == 401 && attempt == 0) continue;
        if (response.statusCode != 200 ||
            response.bodyBytes.isEmpty ||
            response.bodyBytes.length > _maxBytes ||
            !(response.headers['content-type']?.startsWith('image/') ??
                false)) {
          throw StateError('Photo unavailable (${response.statusCode}).');
        }
        return response.bodyBytes;
      }
      throw StateError('Photo unavailable.');
    } finally {
      if (ownedClient) httpClient.close();
    }
  }
}
