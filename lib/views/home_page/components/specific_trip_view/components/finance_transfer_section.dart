import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/finance_amount.dart';
import 'package:travel_crew/models/finance_balance.dart';
import 'package:travel_crew/models/finance_expense_model.dart';
import 'package:travel_crew/models/finance_transfer_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/finance_service.dart';
import 'package:travel_crew/services/pending_finance_transfer_store.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:uuid/uuid.dart';

class FinanceTransferSection extends StatefulWidget {
  const FinanceTransferSection({
    super.key,
    required this.trip,
    required this.expenses,
    required this.currencyCode,
    required this.currencyPrecision,
  });

  final TripModel trip;
  final List<FinanceExpenseModel> expenses;
  final String? currencyCode;
  final int currencyPrecision;

  @override
  State<FinanceTransferSection> createState() => _FinanceTransferSectionState();
}

class _FinanceTransferSectionState extends State<FinanceTransferSection> {
  final Map<String, String> _requestIds = {};
  final Set<String> _busy = {};
  String? _error;

  String _name(String uid) {
    if (uid == GlobalVariables.currentUid) return 'You';
    if (uid == widget.trip.createdBy) {
      return widget.trip.createdByUser?.displayName ?? 'Trip owner';
    }
    for (final user in widget.trip.joindUsersList ?? []) {
      if (user.uid == uid) {
        return user.displayName.isEmpty ? uid : user.displayName;
      }
    }
    return 'Former traveler ($uid)';
  }

  String _money(int minor) => NumberFormat.currency(
    name: widget.currencyCode ?? '',
    decimalDigits: widget.currencyPrecision,
  ).format(minor / BigInt.from(10).pow(widget.currencyPrecision).toInt());

  bool _isBusy(String transferId) =>
      _busy.any((busyKey) => busyKey.startsWith('$transferId:'));

  Future<void> _answer(FinanceTransferModel transfer, String action) async {
    final key = '${transfer.id}:$action';
    if (_isBusy(transfer.id)) {
      return;
    }
    _busy.add(key);
    final requestId = _requestIds.putIfAbsent(key, () => const Uuid().v6());
    setState(() => _error = null);
    try {
      await FinanceService.answerTransfer({
        'tripId': widget.trip.id,
        'transferId': transfer.id,
        'requestId': requestId,
        'expectedRevision': transfer.revision,
        'action': action,
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              error is FirebaseFunctionsException
                  ? error.message ?? 'Unable to update transfer.'
                  : '$error';
        });
      }
    } finally {
      _busy.remove(key);
      if (mounted) setState(() {});
    }
  }

  void _record(Map<String, int> balances) {
    final currency = widget.currencyCode;
    if (currency == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => _RecordTransferSheet(
            trip: widget.trip,
            currencyCode: currency,
            currencyPrecision: widget.currencyPrecision,
            balances: balances,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currencyCode == null) return const SizedBox.shrink();
    return StreamBuilder<List<FinanceTransferModel>>(
      stream: FinanceService.watchTransfers(widget.trip.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Unable to load transfers: ${snapshot.error}');
        }
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final transfers = snapshot.data!;
        late final Map<String, int> balances;
        try {
          balances = FinanceBalance.compute(
            currencyCode: widget.currencyCode!,
            expenses: widget.expenses,
            transfers: transfers,
          );
        } catch (error) {
          return Text('Unable to calculate balances: $error');
        }
        final uid = GlobalVariables.currentUid;
        final hasAnotherTraveler =
            widget.trip.createdBy != uid ||
            (widget.trip.joindUsersList ?? []).any((user) => user.uid != uid);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text('Balances', style: Theme.of(context).textTheme.titleMedium),
            for (final entry in balances.entries.where(
              (entry) => entry.value != 0,
            ))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '${_name(entry.key)}: ${entry.value > 0 ? '+' : '-'}${_money(entry.value.abs())}',
                ),
              ),
            if (balances.values.every((value) => value == 0))
              const Text('Everyone is settled.'),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed:
                  uid.isNotEmpty && hasAnotherTraveler
                      ? () => _record(balances)
                      : null,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Record payment'),
            ),
            const Text(
              'Payments happen outside Travel Crew. The recipient confirms a recorded payment before balances change.',
            ),
            if (transfers.isNotEmpty) ...[
              const Divider(),
              Text('Payments', style: Theme.of(context).textTheme.titleMedium),
              for (final transfer in transfers)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${_name(transfer.fromUserId)} → ${_name(transfer.toUserId)} · ${_money(transfer.amountMinor)}',
                  ),
                  subtitle: Text(
                    '${transfer.status} · ${DateFormat.yMMMd().format(transfer.createdAt.toDate())}',
                  ),
                  trailing:
                      transfer.status == 'pending' && transfer.toUserId == uid
                          ? Wrap(
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed:
                                    _isBusy(transfer.id)
                                        ? null
                                        : () => _answer(transfer, 'confirm'),
                                child: const Text('Confirm'),
                              ),
                              TextButton(
                                onPressed:
                                    _isBusy(transfer.id)
                                        ? null
                                        : () => _answer(transfer, 'reject'),
                                child: const Text('Reject'),
                              ),
                            ],
                          )
                          : transfer.status == 'pending' &&
                              transfer.fromUserId == uid
                          ? TextButton(
                            onPressed:
                                _isBusy(transfer.id)
                                    ? null
                                    : () => _answer(transfer, 'cancel'),
                            child: const Text('Cancel'),
                          )
                          : null,
                ),
            ],
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        );
      },
    );
  }
}

class _RecordTransferSheet extends StatefulWidget {
  const _RecordTransferSheet({
    required this.trip,
    required this.currencyCode,
    required this.currencyPrecision,
    required this.balances,
  });

  final TripModel trip;
  final String currencyCode;
  final int currencyPrecision;
  final Map<String, int> balances;

  @override
  State<_RecordTransferSheet> createState() => _RecordTransferSheetState();
}

class _RecordTransferSheetState extends State<_RecordTransferSheet> {
  final TextEditingController _amount = TextEditingController();
  final PendingFinanceTransferStore _store = PendingFinanceTransferStore();
  late final Map<String, String> _recipients;
  String? _recipient;
  PendingFinanceTransfer? _pending;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final uid = GlobalVariables.currentUid;
    _recipients = {
      if (widget.trip.createdBy != uid)
        widget.trip.createdBy:
            widget.trip.createdByUser?.displayName ?? 'Trip owner',
      for (final user in widget.trip.joindUsersList ?? [])
        if (user.uid != uid)
          user.uid: user.displayName.isEmpty ? user.uid : user.displayName,
    };
    _recipient = _recipients.keys.firstOrNull;
    if ((widget.balances[uid] ?? 0) < 0) {
      for (final entry in widget.balances.entries) {
        if (entry.key != uid &&
            entry.value > 0 &&
            _recipients.containsKey(entry.key)) {
          _recipient = entry.key;
          final suggested = (-widget.balances[uid]!).clamp(0, entry.value);
          _amount.text = FinanceAmount.toDecimal(
            suggested,
            widget.currencyPrecision,
          );
          break;
        }
      }
    }
    _loadPending();
  }

  Future<void> _loadPending() async {
    try {
      final pending = await _store.load(
        GlobalVariables.currentUid,
        widget.trip.id,
      );
      if (!mounted) return;
      if (pending != null) {
        if (!_recipients.containsKey(pending.toUserId)) {
          _recipients[pending.toUserId] =
              'Former traveler (${pending.toUserId})';
        }
        _recipient = pending.toUserId;
        _amount.text = pending.amount;
        _pending = pending;
      }
    } catch (error) {
      if (mounted) _error = 'Unable to restore payment attempt: $error';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || _loading || _error?.startsWith('Unable to restore') == true) {
      return;
    }
    final recipient = _recipient;
    if (recipient == null) {
      setState(() => _error = 'Choose another traveler.');
      return;
    }
    if (_pending == null) {
      try {
        FinanceAmount.parseMinor(_amount.text.trim(), widget.currencyPrecision);
      } on FormatException catch (error) {
        setState(() => _error = error.message);
        return;
      }
    }
    final pending =
        _pending ??
        PendingFinanceTransfer(
          ownerId: GlobalVariables.currentUid,
          tripId: widget.trip.id,
          requestId: const Uuid().v6(),
          toUserId: recipient,
          amount: _amount.text.trim(),
          currencyCode: widget.currencyCode,
          currencyPrecision: widget.currencyPrecision,
        );
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _store.save(pending);
      _pending = pending;
      await FinanceService.recordTransfer({
        'tripId': pending.tripId,
        'requestId': pending.requestId,
        'toUserId': pending.toUserId,
        'amount': pending.amount,
      });
      await _store.delete(pending.ownerId, pending.tripId);
      _pending = null;
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (error is FirebaseFunctionsException &&
          {
            'invalid-argument',
            'failed-precondition',
            'permission-denied',
            'already-exists',
          }.contains(error.code)) {
        try {
          await _store.delete(pending.ownerId, pending.tripId);
          _pending = null;
        } catch (_) {
          // Keep the checkpoint and require the same-ID retry if cleanup fails.
        }
      }
      if (_pending == null && error is FormatException && mounted) {
        await _loadPending();
      }
      if (mounted) {
        setState(() {
          _error =
              error is FirebaseFunctionsException
                  ? error.message ?? 'Unable to record payment.'
                  : '$error';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Record payment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _recipient,
              decoration: const InputDecoration(labelText: 'Paid to'),
              items:
                  _recipients.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
              onChanged:
                  _busy || _loading || _pending != null
                      ? null
                      : (value) => setState(() {
                        _recipient = value;
                      }),
            ),
            TextField(
              controller: _amount,
              enabled: !_busy && !_loading && _pending == null,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount (${widget.currencyCode})',
              ),
            ),
            const Text(
              'Record only a payment you have made. The recipient must confirm it.',
            ),
            if (_pending != null)
              const Text(
                'An earlier payment attempt needs a retry. Its amount and recipient are locked to prevent a duplicate.',
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed:
                  _busy ||
                          _loading ||
                          _error?.startsWith('Unable to restore') == true
                      ? null
                      : _save,
              child: Text(
                _busy
                    ? 'Recording…'
                    : _loading
                    ? 'Loading…'
                    : _pending != null
                    ? 'Retry payment attempt'
                    : 'Record payment',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
