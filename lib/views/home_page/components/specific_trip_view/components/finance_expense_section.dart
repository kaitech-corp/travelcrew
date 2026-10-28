import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/finance_amount.dart';
import 'package:travel_crew/models/finance_expense_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/finance_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/finance_transfer_section.dart';
import 'package:uuid/uuid.dart';

class FinanceExpenseSection extends StatelessWidget {
  const FinanceExpenseSection({super.key, required this.trip});
  final TripModel trip;

  String _name(String uid) {
    if (uid == trip.createdBy) {
      return trip.createdByUser?.displayName.isNotEmpty == true
          ? trip.createdByUser!.displayName
          : 'Trip owner';
    }
    for (final user in trip.joindUsersList ?? []) {
      if (user.uid == uid) {
        return user.displayName.isEmpty ? uid : user.displayName;
      }
    }
    return 'Former traveler ($uid)';
  }

  void _edit(
    BuildContext context,
    FinanceExpenseModel? expense, {
    String? selectedCurrency,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => _FinanceExpenseEditor(
            trip: trip,
            expense: expense,
            selectedCurrency: selectedCurrency,
          ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<List<FinanceExpenseModel>>(
    stream: FinanceService.watchExpenses(trip.id),
    initialData: trip.financeExpenses,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Unable to load expenses: ${snapshot.error}'),
        );
      }
      final expenses = snapshot.data ?? [];
      final currency =
          trip.financeCurrency ??
          (expenses.isNotEmpty ? expenses.first.currencyCode : null);
      final precision =
          trip.financePrecision ??
          (expenses.isNotEmpty ? expenses.first.currencyPrecision : 2);
      String money(int minor) => NumberFormat.currency(
        name: currency ?? '',
        decimalDigits: precision,
      ).format(minor / BigInt.from(10).pow(precision).toInt());
      final total = expenses.fold<int>(
        0,
        (sum, item) => sum + item.amountMinor,
      );
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add expense',
                    onPressed:
                        () => _edit(context, null, selectedCurrency: currency),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null)
                const Center(child: CircularProgressIndicator())
              else ...[
                Text(
                  expenses.isEmpty
                      ? 'Add the first expense to choose the trip currency.'
                      : 'Total: ${money(total)}',
                ),
                for (final expense in expenses)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(expense.name),
                    subtitle: Text(
                      '${expense.date}${expense.localDateTime == null ? '' : ' ${expense.localDateTime!.substring(11, 16)}'} · Paid by ${expense.payerAmountsMinor.keys.map(_name).join(', ')}',
                    ),
                    trailing: Text(expense.formattedAmount),
                    onTap: () => _edit(context, expense),
                  ),
                FinanceTransferSection(
                  trip: trip,
                  expenses: expenses,
                  currencyCode: currency,
                  currencyPrecision: precision,
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _FinanceExpenseEditor extends StatefulWidget {
  const _FinanceExpenseEditor({
    required this.trip,
    this.expense,
    this.selectedCurrency,
  });
  final TripModel trip;
  final FinanceExpenseModel? expense;
  final String? selectedCurrency;

  @override
  State<_FinanceExpenseEditor> createState() => _FinanceExpenseEditorState();
}

class _FinanceExpenseEditorState extends State<_FinanceExpenseEditor> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _localTime;
  late final Map<String, TextEditingController> _shares;
  late final Map<String, String> _names;
  late DateTime _date;
  late String _payer;
  late Set<String> _participants;
  late bool _custom;
  String? _currency;
  Map<String, int>? _currencies;
  String? _error;
  String? _requestId;
  String? _deleteRequestId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    final trip = widget.trip;
    final currentUid = GlobalVariables.currentUid;
    _names = {
      trip.createdBy: trip.createdByUser?.displayName ?? 'Trip owner',
      for (final user in trip.joindUsersList ?? []) user.uid: user.displayName,
      if (currentUid.isNotEmpty) currentUid: 'You',
    };
    for (final uid in expense?.sharesMinor.keys ?? <String>[]) {
      _names.putIfAbsent(uid, () => 'Former traveler ($uid)');
    }
    for (final uid in expense?.payerAmountsMinor.keys ?? <String>[]) {
      _names.putIfAbsent(uid, () => 'Former traveler ($uid)');
    }
    _name = TextEditingController(text: expense?.name ?? '');
    _amount = TextEditingController(
      text:
          expense == null
              ? ''
              : FinanceAmount.toDecimal(
                expense.amountMinor,
                expense.currencyPrecision,
              ),
    );
    _localTime = TextEditingController(
      text: expense?.localDateTime?.substring(11, 19) ?? '',
    );
    _date = DateTime.tryParse(expense?.date ?? '') ?? DateTime.now();
    _currency =
        widget.selectedCurrency ??
        trip.financeCurrency ??
        expense?.currencyCode;
    _payer = expense?.payerAmountsMinor.keys.firstOrNull ?? currentUid;
    _participants = expense?.sharesMinor.keys.toSet() ?? _names.keys.toSet();
    _custom = expense?.splitType == 'custom';
    _shares = {
      for (final uid in _names.keys)
        uid: TextEditingController(
          text:
              expense?.sharesMinor[uid] == null
                  ? ''
                  : FinanceAmount.toDecimal(
                    expense!.sharesMinor[uid]!,
                    expense.currencyPrecision,
                  ),
        ),
    };
    _name.addListener(_changed);
    _amount.addListener(_changed);
    _localTime.addListener(_changed);
    for (final controller in _shares.values) {
      controller.addListener(_changed);
    }
    FinanceService.getCurrencyOptions()
        .then((options) {
          if (mounted) setState(() => _currencies = options);
        })
        .catchError((Object error) {
          if (mounted) {
            setState(() => _error = 'Unable to load currencies: $error');
          }
        });
  }

  void _changed() {
    _requestId = null;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _localTime.dispose();
    for (final controller in _shares.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _label(String uid) =>
      _names[uid]?.trim().isNotEmpty == true ? _names[uid]! : uid;

  Future<void> _save() async {
    final currency = _currency;
    final precision = _currencies?[currency];
    if (currency == null || precision == null) {
      setState(() => _error = 'Choose a supported currency.');
      return;
    }
    try {
      final minor = FinanceAmount.parseMinor(_amount.text.trim(), precision);
      final localTime = _localTime.text.trim();
      if (localTime.isNotEmpty &&
          !RegExp(
            r'^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$',
          ).hasMatch(localTime)) {
        throw const FormatException('Use a local time such as 10:30.');
      }
      final date = DateFormat('yyyy-MM-dd').format(_date);
      if (_name.text.trim().isEmpty ||
          _name.text.trim().length > 200 ||
          _participants.isEmpty ||
          !_names.containsKey(_payer)) {
        throw const FormatException(
          'Enter a name, payer and at least one participant.',
        );
      }
      Map<String, int>? customShares;
      if (_custom) {
        customShares = {
          for (final uid in _participants)
            uid: FinanceAmount.parseShareMinor(
              _shares[uid]!.text.trim(),
              precision,
            ),
        };
        if (customShares.values.fold<int>(0, (sum, value) => sum + value) !=
            minor) {
          throw const FormatException(
            'Participant shares must equal the expense total.',
          );
        }
      }
      setState(() {
        _busy = true;
        _error = null;
      });
      _requestId ??= const Uuid().v4();
      await FinanceService.saveExpense({
        'tripId': widget.trip.id,
        'requestId': _requestId,
        if (widget.expense != null) 'expenseId': widget.expense!.id,
        if (widget.expense != null)
          'expectedRevision': widget.expense!.revision,
        'name': _name.text.trim(),
        'date': date,
        'localDateTime':
            localTime.isEmpty
                ? null
                : '${date}T${localTime.length == 5 ? '$localTime:00' : localTime}',
        'amount': _amount.text.trim(),
        'currencyCode': currency,
        'splitType': _custom ? 'custom' : 'equally',
        if (_custom) 'sharesMinor': customShares,
        if (!_custom) 'participants': _participants.toList(),
        'payerAmountsMinor': {_payer: minor},
      });
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              error is FirebaseFunctionsException
                  ? error.message ?? 'Unable to save expense.'
                  : '$error';
          _busy = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    final expense = widget.expense;
    if (expense == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete expense?'),
            content: Text('Delete ${expense.name} from this trip?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FinanceService.deleteExpense({
        'tripId': widget.trip.id,
        'expenseId': expense.id,
        'expectedRevision': expense.revision,
        'requestId': _deleteRequestId ??= const Uuid().v4(),
      });
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              error is FirebaseFunctionsException
                  ? error.message ?? 'Unable to delete expense.'
                  : '$error';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fixedCurrency =
        widget.selectedCurrency != null ||
        widget.trip.financeCurrency != null ||
        widget.expense != null;
    final canEdit =
        widget.expense == null ||
        widget.expense!.createdBy == GlobalVariables.currentUid ||
        widget.trip.createdBy == GlobalVariables.currentUid;
    return SafeArea(
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
                widget.expense == null ? 'Add expense' : 'Expense details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                readOnly: !canEdit,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _amount,
                readOnly: !canEdit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: _localTime,
                readOnly: !canEdit,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Local time (optional)',
                  hintText: '10:30',
                ),
              ),
              if (_currencies == null)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  initialValue: _currency,
                  decoration: const InputDecoration(labelText: 'Trip currency'),
                  items:
                      _currencies!.keys
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ),
                          )
                          .toList(),
                  onChanged:
                      fixedCurrency || !canEdit
                          ? null
                          : (value) => setState(() {
                            _currency = value;
                            _requestId = null;
                          }),
                ),
              TextButton.icon(
                onPressed:
                    !canEdit
                        ? null
                        : () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null && mounted) {
                            setState(() {
                              _date = selected;
                              _requestId = null;
                            });
                          }
                        },
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat.yMMMd().format(_date)),
              ),
              DropdownButtonFormField<String>(
                initialValue: _payer,
                decoration: const InputDecoration(labelText: 'Paid by'),
                items:
                    _names.keys
                        .map(
                          (uid) => DropdownMenuItem(
                            value: uid,
                            child: Text(_label(uid)),
                          ),
                        )
                        .toList(),
                onChanged:
                    !canEdit
                        ? null
                        : (value) => setState(() {
                          _payer = value!;
                          _requestId = null;
                        }),
              ),
              const SizedBox(height: 8),
              Text(
                'Split between',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final uid in _names.keys)
                CheckboxListTile(
                  title: Text(_label(uid)),
                  value: _participants.contains(uid),
                  onChanged:
                      !canEdit
                          ? null
                          : (checked) => setState(() {
                            if (checked == true) {
                              _participants.add(uid);
                            } else {
                              _participants.remove(uid);
                            }
                            _requestId = null;
                          }),
                ),
              SwitchListTile(
                title: const Text('Custom shares'),
                value: _custom,
                onChanged:
                    !canEdit
                        ? null
                        : (value) => setState(() {
                          _custom = value;
                          _requestId = null;
                        }),
              ),
              if (_custom)
                for (final uid in _participants)
                  TextField(
                    controller: _shares[uid],
                    readOnly: !canEdit,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: '${_label(uid)} share',
                    ),
                  ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (canEdit) ...[
                FilledButton(
                  onPressed: _busy || _currencies == null ? null : _save,
                  child: Text(_busy ? 'Saving…' : 'Save expense'),
                ),
                if (widget.expense != null)
                  TextButton(
                    onPressed: _busy ? null : _delete,
                    child: const Text('Delete expense'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
