import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/finance_migration_draft_store.dart';

void main() {
  test(
    'review draft survives reload with the same owner, trip and request ID',
    () async {
      final data = <String, String>{};
      final store = FinanceMigrationDraftStore(
        read: (key) async => data[key],
        write: (key, value) async => data[key] = value,
        delete: (key) async => data.remove(key),
      );
      final decisions = <Map<String, dynamic>>[
        {
          'sourceId': 'source-a',
          'rawDigest': 'digest-a',
          'action': 'exclude',
          'reason': 'duplicate',
        },
      ];
      await store.save(
        'owner-a',
        'trip-a',
        revision: 1,
        currencyCode: 'USD',
        decisions: decisions,
        requestId: 'retry-id',
      );

      final saved = await store.load('owner-a', 'trip-a');
      expect(saved?['requestId'], 'retry-id');
      expect(saved?['decisions'], decisions);
      expect(await store.load('owner-b', 'trip-a'), isNull);
      expect(await store.load('owner-a', 'trip-b'), isNull);

      await store.delete('owner-a', 'trip-a');
      expect(await store.load('owner-a', 'trip-a'), isNull);
    },
  );

  test('cross-trip stored draft is rejected', () async {
    final store = FinanceMigrationDraftStore(
      read:
          (_) async =>
              '{"version":1,"ownerId":"owner-a","tripId":"trip-b","revision":1,"decisions":[]}',
    );
    expect(
      () => store.load('owner-a', 'trip-a'),
      throwsA(isA<FormatException>()),
    );
  });

  test('malformed decision is rejected before the review restores it', () async {
    final store = FinanceMigrationDraftStore(
      read:
          (_) async =>
              '{"version":1,"ownerId":"owner-a","tripId":"trip-a","revision":1,"decisions":["broken"]}',
    );
    expect(
      () => store.load('owner-a', 'trip-a'),
      throwsA(isA<FormatException>()),
    );
  });

  test('a 1000-source owner review survives a local restart', () async {
    final data = <String, String>{};
    final store = FinanceMigrationDraftStore(
      read: (key) async => data[key],
      write: (key, value) async => data[key] = value,
    );
    final decisions = [
      for (var index = 0; index < 1000; index++)
        <String, dynamic>{
          'sourceId': index.toString().padLeft(64, '0'),
          'rawDigest': List.filled(64, 'a').join(),
          'action': 'exclude',
          'reason': 'other',
          'note': List.filled(17, 'Reviewed historical record. ').join(),
        },
    ];
    await store.save(
      'owner-a',
      'trip-large',
      revision: 1,
      currencyCode: 'USD',
      decisions: decisions,
      requestId: 'stable-request-id',
    );
    final saved = await store.load('owner-a', 'trip-large');
    expect((saved?['decisions'] as List).length, 1000);
    expect(saved?['requestId'], 'stable-request-id');
  });
}
