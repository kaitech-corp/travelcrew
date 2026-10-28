import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/finance_expense_model.dart';

Map<String, dynamic> saved({
  String code = 'USD',
  int precision = 2,
  int amount = 1001,
  String date = '2027-04-10',
}) => {
  'id': 'train',
  'tripId': 'trip',
  'createdBy': 'amy',
  'name': 'Train tickets',
  'date': date,
  'currencyCode': code,
  'currencyPrecision': precision,
  'amountMinor': amount,
  'payerAmountsMinor': {'amy': amount},
  'sharesMinor': {'amy': 334, 'leo': 334, 'zoe': 333},
  'splitType': 'equally',
  'revision': 1,
  'financeSchemaVersion': 2,
  'isDeleted': false,
};

void main() {
  test('minor units and frozen shares render in the selected currency', () {
    final expense = FinanceExpenseModel.fromMap('train', 'trip', saved());
    expect(expense.amountMinor, 1001);
    expect(expense.amount, 10.01);
    expect(expense.formattedAmount, contains('10.01'));
    expect(expense.sharesMinor, {'amy': 334, 'leo': 334, 'zoe': 333});
    final timed = FinanceExpenseModel.fromMap('train', 'trip', {
      ...saved(),
      'localDateTime': '2027-04-10T10:00:00',
    });
    expect(timed.localDateTime, '2027-04-10T10:00:00');
    final yen = FinanceExpenseModel.fromMap('train', 'trip', {
      ...saved(code: 'JPY', precision: 0, amount: 1001),
      'sharesMinor': {'amy': 1001},
    });
    expect(yen.amount, 1001);
    expect(yen.formattedAmount, isNot(contains('.')));
  });

  test(
    'corrupt identities, dates and allocations never become displayed money',
    () {
      for (final data in [
        {...saved(), 'id': 'other'},
        {...saved(), 'date': '2027-02-30'},
        {...saved(), 'amountMinor': 1002},
        {
          ...saved(),
          'sharesMinor': {'amy': -1, 'leo': 1002},
        },
        {...saved(), 'revision': 0},
        {...saved(), 'localDateTime': '2027-04-11T10:00:00'},
        {...saved(), 'localDateTime': '2027-04-10T25:00:00'},
        {...saved(), 'financeSchemaVersion': 1},
        {...saved(), 'isDeleted': true},
      ]) {
        expect(
          () => FinanceExpenseModel.fromMap('train', 'trip', data),
          throwsFormatException,
          reason: data.toString(),
        );
      }
    },
  );
}
