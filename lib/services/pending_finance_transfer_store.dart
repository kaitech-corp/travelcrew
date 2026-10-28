import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travel_crew/models/finance_amount.dart';

/// A same-device checkpoint for one payment whose callable result is uncertain.
/// Keep the request ID and input together so a retry cannot create a second
/// transfer for the same attempted payment.
class PendingFinanceTransfer {
  PendingFinanceTransfer({
    required this.ownerId,
    required this.tripId,
    required this.requestId,
    required this.toUserId,
    required this.amount,
    required this.currencyCode,
    required this.currencyPrecision,
  }) {
    if (ownerId.isEmpty ||
        tripId.isEmpty ||
        requestId.isEmpty ||
        toUserId.isEmpty ||
        ownerId == toUserId ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode)) {
      throw const FormatException('Invalid pending payment.');
    }
    FinanceAmount.parseMinor(amount, currencyPrecision);
  }

  final String ownerId;
  final String tripId;
  final String requestId;
  final String toUserId;
  final String amount;
  final String currencyCode;
  final int currencyPrecision;

  String encode() => jsonEncode({
    'version': 1,
    'ownerId': ownerId,
    'tripId': tripId,
    'requestId': requestId,
    'toUserId': toUserId,
    'amount': amount,
    'currencyCode': currencyCode,
    'currencyPrecision': currencyPrecision,
  });

  factory PendingFinanceTransfer.decode(
    String source, {
    required String ownerId,
    required String tripId,
  }) {
    if (source.length > 4096) {
      throw const FormatException('Pending payment is too large.');
    }
    final data = jsonDecode(source) as Map<String, dynamic>;
    if (data['version'] != 1 ||
        data['ownerId'] != ownerId ||
        data['tripId'] != tripId) {
      throw const FormatException('Pending payment belongs to another trip.');
    }
    return PendingFinanceTransfer(
      ownerId: ownerId,
      tripId: tripId,
      requestId: data['requestId'] as String,
      toUserId: data['toUserId'] as String,
      amount: data['amount'] as String,
      currencyCode: data['currencyCode'] as String,
      currencyPrecision: data['currencyPrecision'] as int,
    );
  }
}

class PendingFinanceTransferStore {
  PendingFinanceTransferStore({
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

  String _key(String ownerId, String tripId) {
    if (ownerId.isEmpty || tripId.isEmpty) {
      throw const FormatException('Sign in and open a trip to record payment.');
    }
    final scope = base64Url.encode(utf8.encode(jsonEncode([ownerId, tripId])));
    return 'pendingFinanceTransfer.v1.$scope';
  }

  Future<PendingFinanceTransfer?> load(String ownerId, String tripId) async {
    final source = await _read(_key(ownerId, tripId));
    return source == null
        ? null
        : PendingFinanceTransfer.decode(
          source,
          ownerId: ownerId,
          tripId: tripId,
        );
  }

  Future<void> save(PendingFinanceTransfer pending) async {
    final key = _key(pending.ownerId, pending.tripId);
    final existing = await _read(key);
    if (existing != null && existing != pending.encode()) {
      PendingFinanceTransfer.decode(
        existing,
        ownerId: pending.ownerId,
        tripId: pending.tripId,
      );
      throw const FormatException(
        'Finish the earlier payment attempt before recording another.',
      );
    }
    await _write(key, pending.encode());
  }

  Future<void> delete(String ownerId, String tripId) =>
      _delete(_key(ownerId, tripId));
}
