import 'package:intl/intl.dart';

/// Finance v2 values are stored in the currency's smallest unit. A share is
/// fixed when an expense is saved; later trip membership changes do not alter it.
class FinanceExpenseModel {
  const FinanceExpenseModel({
    required this.id,
    required this.tripId,
    required this.createdBy,
    required this.name,
    required this.date,
    this.localDateTime,
    required this.currencyCode,
    required this.currencyPrecision,
    required this.amountMinor,
    required this.payerAmountsMinor,
    required this.sharesMinor,
    required this.splitType,
    required this.revision,
  });

  final String id, tripId, createdBy, name, date, currencyCode, splitType;
  final String? localDateTime;
  final int currencyPrecision, amountMinor, revision;
  final Map<String, int> payerAmountsMinor, sharesMinor;

  factory FinanceExpenseModel.fromMap(
    String id,
    String tripId,
    Map<String, dynamic> data,
  ) {
    String stringField(String key) =>
        data[key] is String ? data[key] as String : '';
    if (data['financeSchemaVersion'] != 2 ||
        data['isDeleted'] != false ||
        data['id'] != id ||
        data['tripId'] != tripId ||
        data['amountMinor'] is! int ||
        data['currencyPrecision'] is! int ||
        data['revision'] is! int) {
      throw const FormatException('Invalid finance expense record.');
    }
    Map<String, int> amounts(String key) {
      final raw = data[key];
      if (raw is! Map) {
        throw const FormatException('Invalid finance expense allocation.');
      }
      return raw.map((key, value) {
        if (key is! String || value is! int || value < 0) {
          throw const FormatException('Invalid finance expense allocation.');
        }
        return MapEntry(key, value);
      });
    }

    final expense = FinanceExpenseModel(
      id: id,
      tripId: tripId,
      createdBy: stringField('createdBy'),
      name: stringField('name'),
      date: stringField('date'),
      localDateTime:
          data['localDateTime'] is String
              ? data['localDateTime'] as String
              : null,
      currencyCode: stringField('currencyCode'),
      currencyPrecision: data['currencyPrecision'] as int,
      amountMinor: data['amountMinor'] as int,
      payerAmountsMinor: amounts('payerAmountsMinor'),
      sharesMinor: amounts('sharesMinor'),
      splitType: stringField('splitType'),
      revision: data['revision'] as int,
    );
    if (expense.issue != null) throw FormatException(expense.issue!);
    return expense;
  }

  int get scale => _scale(currencyPrecision);
  double get amount => amountMinor / scale;

  String formatMinor(int minor) => NumberFormat.currency(
    name: currencyCode,
    decimalDigits: currencyPrecision,
  ).format(minor / scale);

  String get formattedAmount => formatMinor(amountMinor);

  String? get issue {
    if (id.isEmpty ||
        tripId.isEmpty ||
        createdBy.isEmpty ||
        name.trim().isEmpty ||
        revision < 1 ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currencyCode) ||
        currencyPrecision < 0 ||
        currencyPrecision > 4 ||
        amountMinor < 1 ||
        amountMinor > 1000000000000 ||
        !['equally', 'custom'].contains(splitType)) {
      return 'Invalid expense details.';
    }
    final parsed = DateTime.tryParse('${date}T00:00:00Z');
    if (parsed == null || DateFormat('yyyy-MM-dd').format(parsed) != date) {
      return 'Invalid expense date.';
    }
    if (localDateTime != null) {
      if (!RegExp(
            r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$',
          ).hasMatch(localDateTime!) ||
          localDateTime!.substring(0, 10) != date) {
        return 'Invalid local expense time.';
      }
      final clock = DateTime.tryParse('${localDateTime!}Z');
      if (clock == null ||
          DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(clock.toUtc()) !=
              localDateTime) {
        return 'Invalid local expense time.';
      }
    }
    bool validAmounts(Map<String, int> allocation) =>
        allocation.isNotEmpty &&
        allocation.length <= 100 &&
        allocation.entries.every(
          (entry) => entry.key.isNotEmpty && entry.value >= 0,
        ) &&
        allocation.values.fold<int>(0, (sum, value) => sum + value) ==
            amountMinor;
    if (!validAmounts(payerAmountsMinor) || !validAmounts(sharesMinor)) {
      return 'Expense allocations do not match the total.';
    }
    return null;
  }

  static int _scale(int precision) {
    var value = 1;
    for (var i = 0; i < precision; i++) {
      value *= 10;
    }
    return value;
  }
}
