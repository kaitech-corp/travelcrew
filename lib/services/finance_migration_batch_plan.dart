const financeMigrationBatchSize = 100;
const financeMigrationBatchSourceLimit = 1000;

List<List<Map<String, dynamic>>> buildFinanceMigrationBatches(
  List<Map<String, dynamic>> sources,
  Map<String, Map<String, dynamic>> decisions,
) {
  if (sources.length <= 200 ||
      sources.length > financeMigrationBatchSourceLimit ||
      decisions.length != sources.length) {
    throw const FormatException(
      'Review every supported source before staging.',
    );
  }
  final seen = <String>{};
  final batches = <List<Map<String, dynamic>>>[];
  for (
    var start = 0;
    start < sources.length;
    start += financeMigrationBatchSize
  ) {
    final batch = <Map<String, dynamic>>[];
    for (final source in sources.skip(start).take(financeMigrationBatchSize)) {
      final sourceId = source['sourceId'];
      final decision = decisions[sourceId];
      if (sourceId is! String ||
          !seen.add(sourceId) ||
          decision == null ||
          decision['sourceId'] != sourceId ||
          decision['rawDigest'] != source['rawDigest'] ||
          !['migrate', 'exclude'].contains(decision['action']) ||
          !['embedded', 'nested', 'top'].contains(source['source']) ||
          source['sourceRecordId'] is! String) {
        throw const FormatException(
          'Review source changed. Reload before staging.',
        );
      }
      batch.add({
        ...decision,
        'source': source['source'],
        'sourceRecordId': source['sourceRecordId'],
      });
    }
    batches.add(batch);
  }
  return batches;
}
