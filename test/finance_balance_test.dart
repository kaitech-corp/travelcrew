import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/finance_balance.dart';
import 'package:travel_crew/models/finance_expense_model.dart';
import 'package:travel_crew/models/finance_transfer_model.dart';

void main() {
  final expense = FinanceExpenseModel.fromMap('expense', 'trip', {
    'id': 'expense',
    'tripId': 'trip',
    'createdBy': 'owner',
    'name': 'Dinner',
    'date': '2027-04-10',
    'currencyCode': 'USD',
    'currencyPrecision': 2,
    'amountMinor': 1000,
    'payerAmountsMinor': {'owner': 1000},
    'sharesMinor': {'owner': 500, 'member': 500},
    'splitType': 'equally',
    'revision': 1,
    'financeSchemaVersion': 2,
    'isDeleted': false,
  });
  FinanceTransferModel transfer(String status) =>
      FinanceTransferModel.fromMap(status, 'trip', {
        'id': status,
        'tripId': 'trip',
        'fromUserId': 'member',
        'toUserId': 'owner',
        'amountMinor': 250,
        'currencyCode': 'USD',
        'currencyPrecision': 2,
        'status': status,
        'revision': 1,
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(1800000000000),
        'transferSchemaVersion': 1,
      });

  test('only confirmed transfers change exact balances', () {
    expect(
      FinanceBalance.compute(
        currencyCode: 'USD',
        expenses: [expense],
        transfers: [transfer('pending')],
      ),
      {'owner': 500, 'member': -500},
    );
    expect(
      FinanceBalance.compute(
        currencyCode: 'USD',
        expenses: [expense],
        transfers: [transfer('confirmed')],
      ),
      {'owner': 250, 'member': -250},
    );
    expect(
      FinanceBalance.compute(
        currencyCode: 'USD',
        expenses: [expense],
        transfers: [transfer('rejected')],
      ),
      {'owner': 500, 'member': -500},
    );
    expect(
      FinanceBalance.compute(
        currencyCode: 'USD',
        expenses: [expense],
        transfers: [transfer('cancelled')],
      ),
      {'owner': 500, 'member': -500},
    );
  });

  test('a currency mismatch fails before showing misleading balances', () {
    expect(
      () => FinanceBalance.compute(
        currencyCode: 'JPY',
        expenses: [expense],
        transfers: [],
      ),
      throwsFormatException,
    );
  });
}
