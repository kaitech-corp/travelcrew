import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FinanceTransferModel {
  const FinanceTransferModel({
    required this.id,
    required this.tripId,
    required this.fromUserId,
    required this.toUserId,
    required this.amountMinor,
    required this.currencyCode,
    required this.currencyPrecision,
    required this.status,
    required this.revision,
    required this.createdAt,
  });

  final String id, tripId, fromUserId, toUserId, currencyCode, status;
  final int amountMinor, currencyPrecision, revision;
  final Timestamp createdAt;

  factory FinanceTransferModel.fromMap(
    String id,
    String tripId,
    Map<String, dynamic> data,
  ) {
    if (data['transferSchemaVersion'] != 1 ||
        data['id'] != id ||
        data['tripId'] != tripId ||
        data['fromUserId'] is! String ||
        data['toUserId'] is! String ||
        data['currencyCode'] is! String ||
        data['status'] is! String ||
        data['amountMinor'] is! int ||
        data['currencyPrecision'] is! int ||
        data['revision'] is! int ||
        data['createdAt'] is! Timestamp) {
      throw const FormatException('Invalid finance transfer record.');
    }
    final result = FinanceTransferModel(
      id: id,
      tripId: tripId,
      fromUserId: data['fromUserId'] as String,
      toUserId: data['toUserId'] as String,
      amountMinor: data['amountMinor'] as int,
      currencyCode: data['currencyCode'] as String,
      currencyPrecision: data['currencyPrecision'] as int,
      status: data['status'] as String,
      revision: data['revision'] as int,
      createdAt: data['createdAt'] as Timestamp,
    );
    if (result.issue != null) throw FormatException(result.issue!);
    return result;
  }

  String? get issue {
    if (id.isEmpty ||
        tripId.isEmpty ||
        fromUserId.isEmpty ||
        toUserId.isEmpty ||
        fromUserId == toUserId ||
        amountMinor < 1 ||
        amountMinor > 1000000000000 ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode) ||
        currencyPrecision < 0 ||
        currencyPrecision > 4 ||
        revision < 1 ||
        !['pending', 'confirmed', 'rejected', 'cancelled'].contains(status)) {
      return 'Invalid transfer details.';
    }
    return null;
  }

  String get formattedAmount => NumberFormat.currency(
    name: currencyCode,
    decimalDigits: currencyPrecision,
  ).format(amountMinor / _scale);

  int get _scale {
    var value = 1;
    for (var i = 0; i < currencyPrecision; i++) {
      value *= 10;
    }
    return value;
  }
}
