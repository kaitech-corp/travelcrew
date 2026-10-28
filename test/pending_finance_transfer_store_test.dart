import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/pending_finance_transfer_store.dart';

void main() {
  final values = <String, String>{};
  final store = PendingFinanceTransferStore(
    read: (key) async => values[key],
    write: (key, value) async => values[key] = value,
    delete: (key) async => values.remove(key),
  );
  PendingFinanceTransfer pending(String requestId) => PendingFinanceTransfer(
    ownerId: 'payer',
    tripId: 'trip',
    requestId: requestId,
    toUserId: 'recipient',
    amount: '12.34',
    currencyCode: 'USD',
    currencyPrecision: 2,
  );

  setUp(values.clear);

  test(
    'restart restores exact input and request ID for an uncertain payment',
    () async {
      await store.save(pending('request-one'));
      final restored = await store.load('payer', 'trip');
      expect(restored?.requestId, 'request-one');
      expect(restored?.toUserId, 'recipient');
      expect(restored?.amount, '12.34');
      await store.save(restored!);
      expect((await store.load('payer', 'trip'))?.requestId, 'request-one');
    },
  );

  test('a new request cannot replace an unresolved payment', () async {
    await store.save(pending('request-one'));
    expect(() => store.save(pending('request-two')), throwsFormatException);
    expect((await store.load('payer', 'trip'))?.requestId, 'request-one');
    await store.delete('payer', 'trip');
    await store.save(pending('request-two'));
  });

  test(
    'checkpoint is account and trip scoped and rejects corrupt data',
    () async {
      await store.save(pending('request-one'));
      expect(await store.load('payer', 'other'), isNull);
      expect(await store.load('other', 'trip'), isNull);
      expect(
        () => PendingFinanceTransfer.decode(
          pending('request-one').encode(),
          ownerId: 'other',
          tripId: 'trip',
        ),
        throwsFormatException,
      );
      expect(
        () => store.save(
          PendingFinanceTransfer(
            ownerId: 'payer',
            tripId: 'trip',
            requestId: 'request-one',
            toUserId: 'recipient',
            amount: '13.00',
            currencyCode: 'USD',
            currencyPrecision: 2,
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => PendingFinanceTransfer(
          ownerId: 'payer',
          tripId: 'trip',
          requestId: 'id',
          toUserId: 'recipient',
          amount: '1.001',
          currencyCode: 'USD',
          currencyPrecision: 2,
        ),
        throwsFormatException,
      );
    },
  );
}
