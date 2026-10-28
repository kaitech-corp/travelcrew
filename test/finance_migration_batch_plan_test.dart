import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/finance_migration_batch_plan.dart';

void main() {
  test('201 reviewed sources produce exact, ordered retry batches', () {
    final sources = [
      for (var index = 0; index < 201; index++)
        <String, dynamic>{
          'sourceId': 'source-$index',
          'rawDigest': 'digest-$index',
          'source': 'nested',
          'sourceRecordId': 'record-$index',
        },
    ];
    final decisions = {
      for (final source in sources)
        source['sourceId'] as String: <String, dynamic>{
          'sourceId': source['sourceId'],
          'rawDigest': source['rawDigest'],
          'action': 'exclude',
          'reason': 'invalid',
        },
    };
    final batches = buildFinanceMigrationBatches(sources, decisions);
    expect(batches.map((batch) => batch.length), [100, 100, 1]);
    expect(
      batches.expand((batch) => batch).map((entry) => entry['sourceRecordId']),
      [for (var index = 0; index < 201; index++) 'record-$index'],
    );
    expect(batches.first.first['action'], 'exclude');
  });

  test('missing or changed decisions fail before staging any batch', () {
    final sources = [
      for (var index = 0; index < 201; index++)
        <String, dynamic>{
          'sourceId': 'source-$index',
          'rawDigest': 'digest-$index',
          'source': 'top',
          'sourceRecordId': 'record-$index',
        },
    ];
    final decisions = {
      for (final source in sources)
        source['sourceId'] as String: <String, dynamic>{
          'sourceId': source['sourceId'],
          'rawDigest': source['rawDigest'],
          'action': 'exclude',
          'reason': 'invalid',
        },
    };
    decisions.remove('source-200');
    expect(
      () => buildFinanceMigrationBatches(sources, decisions),
      throwsFormatException,
    );
    decisions['source-200'] = {
      'sourceId': 'source-200',
      'rawDigest': 'stale',
      'action': 'exclude',
      'reason': 'invalid',
    };
    expect(
      () => buildFinanceMigrationBatches(sources, decisions),
      throwsFormatException,
    );
  });
}
