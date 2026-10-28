import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:travel_crew/models/finance_amount.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/finance_migration_draft_store.dart';
import 'package:travel_crew/services/finance_migration_batch_plan.dart';
import 'package:travel_crew/services/finance_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:uuid/uuid.dart';

class FinanceMigrationReview extends StatefulWidget {
  const FinanceMigrationReview({
    super.key,
    required this.trip,
    required this.onCompleted,
  });

  final TripModel trip;
  final void Function(String currencyCode, int precision) onCompleted;

  @override
  State<FinanceMigrationReview> createState() => _FinanceMigrationReviewState();
}

class _FinanceMigrationReviewState extends State<FinanceMigrationReview> {
  final _store = FinanceMigrationDraftStore();
  List<Map<String, dynamic>>? _sources;
  Map<String, int>? _currencies;
  final Map<String, Map<String, dynamic>> _decisions = {};
  int? _revision;
  String? _currency;
  String? _requestId;
  String? _activeBatchPlanId;
  String? _batchProgress;
  String? _error;
  bool _busy = false;

  late final String _ownerId;

  void _requireOwnerSession() {
    if (_ownerId.isEmpty ||
        _ownerId != widget.trip.createdBy ||
        GlobalVariables.currentUid != _ownerId) {
      throw StateError('Sign in as the trip owner to continue review.');
    }
  }

  @override
  void initState() {
    super.initState();
    _ownerId = GlobalVariables.currentUid;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
      _sources = null;
    });
    try {
      _requireOwnerSession();
      final values = await Future.wait([
        FinanceService.previewMigrationReview(widget.trip.id),
        FinanceService.getCurrencyOptions(),
      ]);
      final preview = values[0];
      final currencies = values[1] as Map<String, int>;
      final sources =
          (preview['sources'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
      final revision = (preview['revision'] as num).toInt();
      final batchPlan = preview['batchPlan'] as Map?;
      final activePlanId = batchPlan?['requestId'] as String?;
      _requireOwnerSession();
      Map<String, dynamic>? saved;
      try {
        saved = await _store.load(_ownerId, widget.trip.id);
      } on FormatException {
        // A damaged local checkpoint cannot replace the server preview.
        await _store.delete(_ownerId, widget.trip.id);
      }
      final restored = <String, Map<String, dynamic>>{};
      String? currency;
      String? requestId;
      if (saved != null && saved['revision'] == revision) {
        final byId = {for (final source in sources) source['sourceId']: source};
        for (final raw in saved['decisions'] as List) {
          final decision = Map<String, dynamic>.from(raw as Map);
          final source = byId[decision['sourceId']];
          if (source != null && source['rawDigest'] == decision['rawDigest']) {
            restored[decision['sourceId'] as String] = decision;
          }
        }
        currency = saved['currencyCode'] as String?;
        if (!currencies.containsKey(currency)) currency = null;
        if (restored.length == (saved['decisions'] as List).length) {
          requestId = saved['requestId'] as String?;
        }
      }
      if (saved == null) requestId = activePlanId;
      if (!mounted) return;
      _requireOwnerSession();
      setState(() {
        _sources = sources;
        _revision = revision;
        _currencies = currencies;
        _currency = currency;
        _requestId = requestId;
        _activeBatchPlanId = activePlanId;
        _batchProgress = null;
        _decisions
          ..clear()
          ..addAll(restored);
      });
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(Object error) =>
      error is FirebaseFunctionsException
          ? error.message ?? error.code
          : error.toString();

  Future<void> _saveDraft() async {
    _requireOwnerSession();
    await _store.save(
      _ownerId,
      widget.trip.id,
      revision: _revision!,
      currencyCode: _currency,
      decisions: _decisions.values.toList(),
      requestId: _requestId,
    );
  }

  Future<void> _changeCurrency(String? value) async {
    if (value == null || value == _currency) return;
    setState(() {
      _currency = value;
      _requestId = null;
      _decisions.removeWhere((_, decision) => decision['action'] == 'migrate');
    });
    try {
      await _saveDraft();
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    }
  }

  Map<String, String> _travelers(Map<String, dynamic> source) {
    final names = <String, String>{
      widget.trip.createdBy:
          widget.trip.createdByUser?.displayName.isNotEmpty == true
              ? widget.trip.createdByUser!.displayName
              : 'Trip owner',
      for (final user in widget.trip.joindUsersList ?? [])
        user.uid: user.displayName.isEmpty ? user.uid : user.displayName,
    };
    for (final uid in widget.trip.joinedUsers ?? <String>[]) {
      names.putIfAbsent(uid, () => 'Traveler ($uid)');
    }
    for (final item in _sources ?? [source]) {
      for (final uid in item['unverifiedTravelerHints'] as List? ?? []) {
        if (uid is String) {
          names.putIfAbsent(uid, () => 'Historical ID, verify ($uid)');
        }
      }
    }
    names.removeWhere((key, _) => key.isEmpty);
    return names;
  }

  Future<void> _migrate(Map<String, dynamic> source) async {
    final currency = _currency;
    final precision = _currencies?[currency];
    if (currency == null || precision == null) {
      setState(() => _error = 'Choose the verified trip currency first.');
      return;
    }
    final decision = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder:
            (_) => _SourceEditor(
              source: source,
              existing: _decisions[source['sourceId']],
              travelers: _travelers(source),
              currency: currency,
              precision: precision,
            ),
      ),
    );
    if (decision == null || !mounted) return;
    try {
      _requireOwnerSession();
    } catch (error) {
      setState(() => _error = _message(error));
      return;
    }
    setState(() {
      _decisions[source['sourceId'] as String] = decision;
      _requestId = null;
      _error = null;
    });
    try {
      await _saveDraft();
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    }
  }

  Future<void> _exclude(Map<String, dynamic> source) async {
    String? reason;
    String note = '';
    try {
      final accepted = await showDialog<bool>(
        context: context,
        builder:
            (dialogContext) => StatefulBuilder(
              builder:
                  (dialogContext, update) => AlertDialog(
                    title: const Text('Exclude historical record'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('The original record stays in the archive.'),
                        DropdownButtonFormField<String>(
                          initialValue: reason,
                          decoration: const InputDecoration(
                            labelText: 'Reason',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'duplicate',
                              child: Text('Duplicate'),
                            ),
                            DropdownMenuItem(
                              value: 'invalid',
                              child: Text('Invalid record'),
                            ),
                            DropdownMenuItem(
                              value: 'not_trip_expense',
                              child: Text('Not a trip expense'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) => update(() => reason = value),
                        ),
                        TextFormField(
                          onChanged: (value) => note = value,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            labelText: 'Review note (optional)',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed:
                            reason == null
                                ? null
                                : () => Navigator.pop(dialogContext, true),
                        child: const Text('Exclude'),
                      ),
                    ],
                  ),
            ),
      );
      if (accepted != true || !mounted) return;
      _requireOwnerSession();
      setState(() {
        _decisions[source['sourceId'] as String] = {
          'sourceId': source['sourceId'],
          'rawDigest': source['rawDigest'],
          'action': 'exclude',
          'reason': reason!,
          if (note.trim().isNotEmpty) 'note': note.trim(),
        };
        _requestId = null;
        _error = null;
      });
      await _saveDraft();
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    }
  }

  Future<void> _commit() async {
    try {
      _requireOwnerSession();
    } catch (error) {
      setState(() => _error = _message(error));
      return;
    }
    final sources = _sources;
    final currency = _currency;
    if (sources == null ||
        currency == null ||
        _decisions.length != sources.length ||
        _revision == null) {
      setState(() => _error = 'Choose a currency and review every record.');
      return;
    }
    if (_activeBatchPlanId != null && _activeBatchPlanId != _requestId) {
      setState(
        () =>
            _error =
                'A previous batch has staged decisions. Restart staged review before approving changes.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _requestId ??= const Uuid().v4();
    });
    try {
      // Persist the request ID before calling the server. A lost response can
      // safely retry the exact same atomic approval.
      await _saveDraft();
      final requestId = _requestId!;
      Map<String, dynamic> result;
      if (sources.length <= 200) {
        result = await FinanceService.commitMigrationReview({
          'tripId': widget.trip.id,
          'requestId': requestId,
          'expectedRevision': _revision,
          'currencyCode': currency,
          'decisions': [
            for (final source in sources) _decisions[source['sourceId']]!,
          ],
        });
      } else {
        final batches = buildFinanceMigrationBatches(sources, _decisions);
        for (var index = 0; index < batches.length; index++) {
          _requireOwnerSession();
          await FinanceService.stageMigrationBatch({
            'tripId': widget.trip.id,
            'requestId': requestId,
            'expectedRevision': _revision,
            'currencyCode': currency,
            'sourceCount': sources.length,
            'decisions': batches[index],
          });
          _requireOwnerSession();
          if (mounted) {
            setState(() {
              _activeBatchPlanId = requestId;
              _batchProgress =
                  '${((index + 1) * financeMigrationBatchSize).clamp(0, sources.length)} of ${sources.length} records staged';
            });
          }
        }
        _requireOwnerSession();
        result = await FinanceService.finishMigrationBatch({
          'tripId': widget.trip.id,
          'requestId': requestId,
          'expectedRevision': _revision,
        });
      }
      if (result['status'] != 'completed') {
        throw StateError('The review was not completed.');
      }
      _requireOwnerSession();
      try {
        await _store.delete(_ownerId, widget.trip.id);
      } catch (error) {
        debugPrint('Unable to clear completed finance review draft: $error');
      }
      if (mounted) widget.onCompleted(currency, _currencies![currency]!);
    } catch (error) {
      if (GlobalVariables.currentUid != _ownerId) {
        if (mounted) {
          setState(() {
            _sources = null;
            _decisions.clear();
            _error = 'Sign in as the trip owner to continue review.';
          });
        }
        return;
      }
      // A response can be lost after the transaction commits. Read the trip
      // before showing a failure so a completed ledger is not left in review.
      try {
        final current = await FirebaseTripService.getTripById(
          tripId: widget.trip.id,
        );
        if (current?.financeMigrationStatus == 'completed' &&
            current?.financeCurrency != null &&
            current?.financePrecision != null) {
          try {
            await _store.delete(_ownerId, widget.trip.id);
          } catch (cleanupError) {
            debugPrint(
              'Unable to clear completed finance review draft: $cleanupError',
            );
          }
          if (mounted) {
            widget.onCompleted(
              current!.financeCurrency!,
              current.financePrecision!,
            );
          }
          return;
        }
      } catch (_) {
        // Keep the saved request ID and original error for an offline retry.
      }
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _batchProgress = null;
        });
      }
    }
  }

  Future<void> _restartBatch() async {
    final planId = _activeBatchPlanId;
    if (planId == null || _revision == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _batchProgress = 'Removing staged decisions…';
    });
    try {
      for (var page = 0; page < 11; page++) {
        _requireOwnerSession();
        final result = await FinanceService.abortMigrationBatch({
          'tripId': widget.trip.id,
          'requestId': planId,
          'expectedRevision': _revision,
        });
        _requireOwnerSession();
        if (result['cleared'] == true) {
          _activeBatchPlanId = null;
          _requestId = null;
          await _saveDraft();
          if (mounted) setState(() => _error = null);
          return;
        }
      }
      throw StateError('Staged review is still being cleared. Retry.');
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _batchProgress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sources = _sources;
    final currencyCodes = _currencies?.keys.toList() ?? <String>[];
    currencyCodes.sort();
    if (sources == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_busy) const CircularProgressIndicator(),
            if (_error != null) Text(_error!),
            if (!_busy)
              TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final possibleDuplicates = <String, List<int>>{};
    for (var index = 0; index < sources.length; index++) {
      final source = sources[index];
      final name = (source['name'] as String?)?.trim().toLowerCase();
      final date = source['date'] as String?;
      final amount = source['amount'] as String?;
      if (name == null || name.isEmpty || date == null || amount == null) {
        continue;
      }
      final key = '$name\u001f$date\u001f$amount';
      possibleDuplicates.putIfAbsent(key, () => []).add(index + 1);
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList.list(
            children: [
              Text(
                'Historical expense review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Review each original record. Its amount has no verified currency, '
                'payer, share, or settlement history. Check duplicates and enter only '
                'amounts you can verify. Original records remain in the archive.',
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                TextButton(
                  onPressed: _busy ? null : _load,
                  child: const Text('Reload review'),
                ),
              ],
              if (_activeBatchPlanId != null)
                TextButton(
                  onPressed: _busy ? null : _restartBatch,
                  child: const Text('Discard staged decisions and restart'),
                ),
              if (_batchProgress != null) Text(_batchProgress!),
              if (_busy) const LinearProgressIndicator(),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(
                  labelText: 'Verified trip currency',
                ),
                items: [
                  for (final code in currencyCodes)
                    DropdownMenuItem(value: code, child: Text(code)),
                ],
                onChanged: _busy ? null : _changeCurrency,
              ),
              const SizedBox(height: 8),
              Text(
                '${_decisions.length} of ${sources.length} records reviewed',
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Record ${index + 1}: ${sources[index]['name'] ?? 'Unnamed'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SelectableText(
                        '${sources[index]['source']} / ${sources[index]['sourceRecordId']}\n'
                        'Original amount: ${sources[index]['amount'] ?? 'Unknown'} '
                        '(currency unverified)\n'
                        'Original date: ${sources[index]['date'] ?? 'Unknown'}',
                      ),
                      Builder(
                        builder: (_) {
                          final source = sources[index];
                          final name =
                              (source['name'] as String?)?.trim().toLowerCase();
                          final date = source['date'] as String?;
                          final amount = source['amount'] as String?;
                          final matches =
                              name == null || date == null || amount == null
                                  ? null
                                  : possibleDuplicates['$name\u001f$date\u001f$amount'];
                          return matches != null && matches.length > 1
                              ? Text(
                                'Possible duplicate of records ${matches.where((number) => number != index + 1).join(', ')}. Review both separately.',
                              )
                              : const SizedBox.shrink();
                        },
                      ),
                      if (_decisions[sources[index]['sourceId']] != null)
                        Text(
                          'Decision: ${_decisions[sources[index]['sourceId']]!['action']}',
                        ),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed:
                                _busy ? null : () => _migrate(sources[index]),
                            child: const Text('Review and include'),
                          ),
                          TextButton(
                            onPressed:
                                _busy ? null : () => _exclude(sources[index]),
                            child: const Text('Exclude'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              childCount: sources.length,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: FilledButton(
              onPressed:
                  _busy ||
                          sources.isEmpty ||
                          _decisions.length != sources.length
                      ? null
                      : _commit,
              child: const Text('Approve reviewed ledger'),
            ),
          ),
        ),
      ],
    );
  }
}

class _SourceEditor extends StatefulWidget {
  const _SourceEditor({
    required this.source,
    required this.existing,
    required this.travelers,
    required this.currency,
    required this.precision,
  });
  final Map<String, dynamic> source;
  final Map<String, dynamic>? existing;
  final Map<String, String> travelers;
  final String currency;
  final int precision;

  @override
  State<_SourceEditor> createState() => _SourceEditorState();
}

class _SourceEditorState extends State<_SourceEditor> {
  late final TextEditingController _name;
  late final TextEditingController _date;
  late final TextEditingController _amount;
  late final Map<String, TextEditingController> _payers;
  late final Map<String, TextEditingController> _shares;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final rawDate = widget.source['date'] as String? ?? '';
    _name = TextEditingController(
      text:
          existing?['name'] as String? ??
          widget.source['name'] as String? ??
          '',
    );
    _date = TextEditingController(
      text:
          existing?['date'] as String? ??
          (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate) ? rawDate : ''),
    );
    _amount = TextEditingController(text: existing?['amount'] as String? ?? '');
    final payerMinor = Map<String, dynamic>.from(
      existing?['payerAmountsMinor'] as Map? ?? {},
    );
    final shareMinor = Map<String, dynamic>.from(
      existing?['sharesMinor'] as Map? ?? {},
    );
    _payers = {
      for (final uid in widget.travelers.keys)
        uid: TextEditingController(
          text:
              payerMinor[uid] == null
                  ? ''
                  : FinanceAmount.toDecimal(
                    (payerMinor[uid] as num).toInt(),
                    widget.precision,
                  ),
        ),
    };
    _shares = {
      for (final uid in widget.travelers.keys)
        uid: TextEditingController(
          text:
              shareMinor[uid] == null
                  ? ''
                  : FinanceAmount.toDecimal(
                    (shareMinor[uid] as num).toInt(),
                    widget.precision,
                  ),
        ),
    };
  }

  @override
  void dispose() {
    _name.dispose();
    _date.dispose();
    _amount.dispose();
    for (final controller in [..._payers.values, ..._shares.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    try {
      final name = _name.text.trim();
      final date = _date.text.trim();
      final amount = _amount.text.trim();
      if (name.isEmpty ||
          name.length > 200 ||
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
          DateTime.tryParse(date)?.toIso8601String().substring(0, 10) != date) {
        throw const FormatException('Enter a name and valid YYYY-MM-DD date.');
      }
      final total = FinanceAmount.parseMinor(amount, widget.precision);
      Map<String, int> allocation(Map<String, TextEditingController> fields) {
        final values = <String, int>{};
        for (final entry in fields.entries) {
          final text = entry.value.text.trim();
          if (text.isEmpty) continue;
          final minor = FinanceAmount.parseShareMinor(text, widget.precision);
          if (minor > 0) values[entry.key] = minor;
        }
        return values;
      }

      final payers = allocation(_payers);
      final shares = allocation(_shares);
      if (payers.isEmpty ||
          shares.isEmpty ||
          payers.values.fold<int>(0, (a, b) => a + b) != total ||
          shares.values.fold<int>(0, (a, b) => a + b) != total) {
        throw const FormatException(
          'Payer contributions and traveler shares must each equal the expense amount.',
        );
      }
      Navigator.pop(context, <String, dynamic>{
        'sourceId': widget.source['sourceId'],
        'rawDigest': widget.source['rawDigest'],
        'action': 'migrate',
        'name': name,
        'date': date,
        'amount': amount,
        'payerAmountsMinor': payers,
        'sharesMinor': shares,
      });
    } catch (error) {
      setState(
        () => _error = error.toString().replaceFirst('FormatException: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Review historical expense')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SelectableText(
          'Source: ${widget.source['source']} / ${widget.source['sourceRecordId']}',
        ),
        Text(
          'Original amount: ${widget.source['amount'] ?? 'Unknown'} (currency unverified)',
        ),
        const Text(
          'Verify the amount, payer contributions and each traveler’s share from your records.',
        ),
        TextField(
          controller: _name,
          maxLength: 200,
          decoration: const InputDecoration(labelText: 'Expense name'),
        ),
        TextField(
          controller: _date,
          decoration: const InputDecoration(
            labelText: 'Expense date (YYYY-MM-DD)',
          ),
        ),
        TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Verified amount (${widget.currency})',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Payer contributions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final traveler in widget.travelers.entries)
          TextField(
            controller: _payers[traveler.key],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${traveler.value} paid (${widget.currency})',
            ),
          ),
        const SizedBox(height: 12),
        Text('Traveler shares', style: Theme.of(context).textTheme.titleMedium),
        for (final traveler in widget.travelers.entries)
          TextField(
            controller: _shares[traveler.key],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${traveler.value} owes (${widget.currency})',
            ),
          ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _save,
          child: const Text('Save reviewed record'),
        ),
      ],
    ),
  );
}
