import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/finance_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/expense/controller/expense_conrtoller.dart';
import 'package:travel_crew/views/expense/finance_migration_review.dart';
import 'package:travel_crew/views/expense/legacy_expense_archive.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/finance_expense_section.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key, this.fromMainView = false});
  final bool fromMainView;

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ExpenseController controller = Get.find<ExpenseController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = true;
  bool _startingReview = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is TripModel) controller.tripModel.value = Get.arguments;
    _refresh();
  }

  Future<void> _refresh() async {
    final tripId = controller.tripModel.value?.id;
    final uid = GlobalVariables.currentUid;
    if (tripId == null || tripId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Trip unavailable.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trip = await FirebaseTripService.getTripById(tripId: tripId);
      if (trip == null) throw StateError('Trip unavailable.');
      if (!mounted) return;
      if (uid.isEmpty || GlobalVariables.currentUid != uid) {
        throw StateError('Sign in again to view this trip.');
      }
      controller.tripModel.value = trip;
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Unable to load trip expenses: $error');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _beginReview() async {
    final trip = controller.tripModel.value;
    if (trip == null || _startingReview) return;
    setState(() => _startingReview = true);
    try {
      await FinanceService.beginMigrationReview(trip.id);
      await _refresh();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to start expense review: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _startingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = controller.tripModel.value;
    final l10n = AppLocalizations.of(context)!;
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null || trip == null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'Trip unavailable.'),
            TextButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      );
    } else if (trip.financeMigrationStatus == 'reviewing') {
      body =
          GlobalVariables.currentUid == trip.createdBy
              ? FinanceMigrationReview(
                trip: trip,
                onCompleted: (currency, precision) {
                  controller.tripModel.value = trip.copyWith(
                    financeMigrationStatus: 'completed',
                    financeSchemaVersion: 2,
                    financeCurrency: currency,
                    financePrecision: precision,
                  );
                  setState(() {});
                },
              )
              : LegacyExpenseArchive(tripId: trip.id, reviewInProgress: true);
    } else if (trip.hasLegacyExpenseRecords && trip.financeSchemaVersion != 2) {
      body = Column(
        children: [
          if (GlobalVariables.currentUid == trip.createdBy)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _startingReview ? null : _beginReview,
                child: Text(
                  _startingReview
                      ? 'Starting review…'
                      : 'Review historical expenses',
                ),
              ),
            ),
          Expanded(child: LegacyExpenseArchive(tripId: trip.id)),
        ],
      );
    } else {
      body = SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FinanceExpenseSection(trip: trip),
              if (trip.financeMigrationStatus == 'completed')
                TextButton.icon(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (_) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Historical expenses'),
                                ),
                                body: LegacyExpenseArchive(tripId: trip.id),
                              ),
                        ),
                      ),
                  icon: const Icon(Icons.history),
                  label: const Text('View original expense records'),
                ),
            ],
          ),
        ),
      );
    }
    return CustomScaffold(
      screenName: l10n.expenses,
      isBackIcon: false,
      centerTitle: true,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
      body: body,
    );
  }
}
