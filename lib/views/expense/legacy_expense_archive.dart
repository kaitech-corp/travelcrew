import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/utils/app_strings.dart';

class LegacyExpenseSource {
  const LegacyExpenseSource({
    required this.source,
    required this.name,
    required this.amount,
    required this.date,
  });

  final String source;
  final String name;
  final String amount;
  final String date;

  factory LegacyExpenseSource.fromRaw(String source, dynamic raw) {
    final data = raw is Map ? raw : const <String, dynamic>{};
    final name = data['name'];
    final amount = data['amount'];
    final date = data['date'];
    return LegacyExpenseSource(
      source: source.length > 200 ? '${source.substring(0, 200)}…' : source,
      name:
          name is String && name.trim().isNotEmpty
              ? (name.trim().length > 200
                  ? '${name.trim().substring(0, 200)}…'
                  : name.trim())
              : 'Unnamed historical record',
      amount:
          amount is num && amount.isFinite
              ? amount.toString()
              : amount is String && amount.length <= 40
              ? amount
              : 'Unknown amount',
      date:
          date is Timestamp
              ? date.toDate().toIso8601String()
              : date is String && date.length <= 40
              ? date
              : 'Date unknown',
    );
  }
}

Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _readArchivePages(
  Query<Map<String, dynamic>> query,
  int maxDocs,
) async {
  final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  QueryDocumentSnapshot<Map<String, dynamic>>? cursor;
  while (true) {
    final page =
        await (cursor == null ? query : query.startAfterDocument(cursor))
            .limit((maxDocs - docs.length + 1).clamp(1, 100))
            .get();
    docs.addAll(page.docs);
    if (docs.length > maxDocs) {
      throw StateError(
        'Historical expense archive exceeds the supported preview size.',
      );
    }
    if (page.docs.length < 100) return docs;
    cursor = page.docs.last;
  }
}

Future<List<LegacyExpenseSource>> loadLegacyExpenseArchive(
  String tripId,
) async {
  final tripRef = firestore.collection(kTripTable).doc(tripId);
  final trip = await tripRef.get();
  if (!trip.exists) throw StateError('Trip unavailable.');
  final data = trip.data()!;
  final embedded =
      data['expenses'] is List
          ? data['expenses'] as List
          : data['expenses'] == null
          ? <dynamic>[]
          : [data['expenses']];
  final sources = <LegacyExpenseSource>[
    for (var index = 0; index < embedded.length; index++)
      LegacyExpenseSource.fromRaw('Trip record #${index + 1}', embedded[index]),
  ];
  if (sources.length > 1000) {
    throw StateError(
      'Historical expense archive exceeds the supported preview size.',
    );
  }
  final nested = await _readArchivePages(
    tripRef.collection(kTripExpensesSubCollection),
    1000 - sources.length,
  );
  final top = await _readArchivePages(
    firestore.collection(kExpenseTable).where('tripId', isEqualTo: tripId),
    1000 - sources.length - nested.length,
  );
  sources.addAll(
    nested.map(
      (doc) =>
          LegacyExpenseSource.fromRaw('Trip expense ${doc.id}', doc.data()),
    ),
  );
  sources.addAll(
    top.map(
      (doc) => LegacyExpenseSource.fromRaw(
        'Historical expense ${doc.id}',
        doc.data(),
      ),
    ),
  );
  return sources;
}

class LegacyExpenseArchive extends StatefulWidget {
  const LegacyExpenseArchive({
    super.key,
    required this.tripId,
    this.reviewInProgress = false,
  });
  final String tripId;
  final bool reviewInProgress;

  @override
  State<LegacyExpenseArchive> createState() => _LegacyExpenseArchiveState();
}

class _LegacyExpenseArchiveState extends State<LegacyExpenseArchive> {
  late Future<List<LegacyExpenseSource>> _source;

  @override
  void initState() {
    super.initState();
    _source = loadLegacyExpenseArchive(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LegacyExpenseSource>>(
      future: _source,
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load historical expenses.'),
                TextButton(
                  onPressed:
                      () => setState(() {
                        _source = loadLegacyExpenseArchive(widget.tripId);
                      }),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final sources = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sources.isEmpty ? 2 : sources.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    widget.reviewInProgress
                        ? 'Historical expenses are under owner review. '
                            'The amounts below have no verified currency, payer or settlement status.'
                        : 'Original historical records are preserved. '
                            'These amounts have no verified currency, payer or settlement status.',
                  ),
                ),
              );
            }
            if (sources.isEmpty) {
              return const Text('No historical expense sources were found.');
            }
            final source = sources[index - 1];
            return Card(
              child: ListTile(
                title: Text(source.name),
                subtitle: Text(
                  '${source.source}\n${source.date}\n'
                  '${source.amount} (currency unverified)',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
