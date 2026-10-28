import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Local review checkpoint. The server remains authoritative for source digests,
/// currency, allocations, and the final atomic approval.
class FinanceMigrationDraftStore {
  static const int maxEncodedBytes = 2000000;
  FinanceMigrationDraftStore({
    Future<String?> Function(String key)? read,
    Future<void> Function(String key, String value)? write,
    Future<void> Function(String key)? delete,
  }) : _read = read ?? ((key) => const FlutterSecureStorage().read(key: key)),
       _write =
           write ??
           ((key, value) =>
               const FlutterSecureStorage().write(key: key, value: value)),
       _delete =
           delete ?? ((key) => const FlutterSecureStorage().delete(key: key));

  final Future<String?> Function(String) _read;
  final Future<void> Function(String, String) _write;
  final Future<void> Function(String) _delete;

  String key(String ownerId, String tripId) {
    if (ownerId.isEmpty || tripId.isEmpty) {
      throw const FormatException('Sign in to review this trip.');
    }
    return 'financeMigrationDraft.v1.${base64Url.encode(utf8.encode(jsonEncode([ownerId, tripId])))}';
  }

  Future<Map<String, dynamic>?> load(String ownerId, String tripId) async {
    final encoded = await _read(key(ownerId, tripId));
    if (encoded == null) return null;
    if (utf8.encode(encoded).length > maxEncodedBytes) {
      throw const FormatException('Stored review is too large.');
    }
    final value = jsonDecode(encoded);
    if (value is! Map ||
        value['version'] != 1 ||
        value['ownerId'] != ownerId ||
        value['tripId'] != tripId ||
        value['revision'] is! int ||
        value['decisions'] is! List ||
        (value['currencyCode'] != null && value['currencyCode'] is! String) ||
        (value['requestId'] != null && value['requestId'] is! String)) {
      throw const FormatException('Stored review is invalid.');
    }
    for (final decision in value['decisions'] as List) {
      if (decision is! Map ||
          decision['sourceId'] is! String ||
          decision['rawDigest'] is! String ||
          (decision['action'] != 'migrate' &&
              decision['action'] != 'exclude')) {
        throw const FormatException('Stored review decision is invalid.');
      }
    }
    return Map<String, dynamic>.from(value);
  }

  Future<void> save(
    String ownerId,
    String tripId, {
    required int revision,
    required String? currencyCode,
    required List<Map<String, dynamic>> decisions,
    String? requestId,
  }) async {
    final encoded = jsonEncode({
      'version': 1,
      'ownerId': ownerId,
      'tripId': tripId,
      'revision': revision,
      'currencyCode': currencyCode,
      'decisions': decisions,
      'requestId': requestId,
    });
    if (utf8.encode(encoded).length > maxEncodedBytes) {
      throw const FormatException('Stored review is too large.');
    }
    await _write(key(ownerId, tripId), encoded);
  }

  Future<void> delete(String ownerId, String tripId) =>
      _delete(key(ownerId, tripId));
}
