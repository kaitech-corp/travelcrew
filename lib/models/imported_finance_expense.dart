import 'package:intl/intl.dart';
import 'package:travel_crew/models/finance_amount.dart';
import 'package:uuid/uuid.dart';

/// A validated import draft. The request ID remains stable if a save is retried.
class ImportedFinanceExpense {
  ImportedFinanceExpense({
    required this.requestId,
    required this.name,
    required this.amount,
    required this.date,
    required this.currencyCode,
    this.localDateTime,
  });

  final String requestId, name, amount, date, currencyCode;
  final String? localDateTime;

  factory ImportedFinanceExpense.fromMap(
    Map<String, dynamic> data, {
    required String currencyCode,
    required int precision,
    String? requestId,
  }) {
    if (data.keys.toSet().difference({
          'name',
          'amount',
          'date',
          'split_type',
        }).isNotEmpty ||
        data['name'] is! String ||
        (data['name'] as String).trim().isEmpty ||
        (data['name'] as String).trim().length > 200 ||
        data['amount'] is! num ||
        data['date'] is! String ||
        (data['split_type'] != null && data['split_type'] != 'equally')) {
      throw const FormatException('Invalid imported expense.');
    }
    final amount = (data['amount'] as num).toString();
    FinanceAmount.parseMinor(amount, precision);
    final rawDate = data['date'] as String;
    String date;
    String? localDateTime;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate)) {
      date = rawDate;
    } else if (RegExp(
      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:[+-]\d{2}:\d{2})?$',
    ).hasMatch(rawDate)) {
      date = rawDate.substring(0, 10);
      localDateTime = rawDate.substring(0, 19);
    } else {
      throw const FormatException('Use a local expense date or clock time.');
    }
    final day = DateTime.tryParse('${date}T00:00:00Z');
    if (day == null || DateFormat('yyyy-MM-dd').format(day.toUtc()) != date) {
      throw const FormatException('Invalid imported expense date.');
    }
    if (localDateTime != null) {
      final clock = DateTime.tryParse('${localDateTime}Z');
      if (clock == null ||
          DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(clock.toUtc()) !=
              localDateTime) {
        throw const FormatException('Invalid imported expense time.');
      }
    }
    return ImportedFinanceExpense(
      requestId: requestId ?? const Uuid().v4(),
      name: (data['name'] as String).trim(),
      amount: amount,
      date: date,
      localDateTime: localDateTime,
      currencyCode: currencyCode,
    );
  }

  Map<String, dynamic> requestFor(String tripId, String ownerId) => {
    'tripId': tripId,
    'requestId': requestId,
    'name': name,
    'date': date,
    if (localDateTime != null) 'localDateTime': localDateTime,
    'amount': amount,
    'currencyCode': currencyCode,
    'splitType': 'equally',
    'participants': [ownerId],
  };
}
