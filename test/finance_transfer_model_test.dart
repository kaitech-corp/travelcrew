import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/finance_transfer_model.dart';

Map<String, dynamic> saved({String status = 'pending'}) => {
  'id': 'transfer',
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
};

void main() {
  test('pending transfer preserves exact amount and status', () {
    final transfer = FinanceTransferModel.fromMap('transfer', 'trip', saved());
    expect(transfer.amountMinor, 250);
    expect(transfer.formattedAmount, contains('2.50'));
    expect(transfer.status, 'pending');
  });

  test('malformed or forged transfer records fail closed', () {
    for (final data in [
      {...saved(), 'id': 'other'},
      {...saved(), 'tripId': 'other'},
      {...saved(), 'toUserId': 'member'},
      {...saved(), 'amountMinor': 0},
      {...saved(), 'currencyCode': 'invalid'},
      {...saved(), 'revision': 0},
      {...saved(), 'status': 'paid'},
      {...saved(), 'createdAt': 'not a timestamp'},
    ]) {
      expect(
        () => FinanceTransferModel.fromMap('transfer', 'trip', data),
        throwsFormatException,
        reason: data.toString(),
      );
    }
  });
}
