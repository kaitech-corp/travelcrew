import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/transportation_model.dart';
import 'package:travel_crew/models/trip_model.dart';

/// The same-device recovery checkpoint for a trip whose remote create may
/// already have committed. Request IDs must survive an app restart.
class PendingTripImport {
  PendingTripImport({
    required this.trip,
    required this.transportation,
    required this.activities,
    required this.expenses,
    required this.expenseRequestIds,
    required this.savedExpenseRequestIds,
    required this.expenseCurrency,
  }) {
    if (trip.id.isEmpty ||
        trip.createdBy.isEmpty ||
        expenses.length != expenseRequestIds.length ||
        expenses.length > 50 ||
        transportation.length > 50 ||
        activities.length > 200 ||
        (expenses.isNotEmpty &&
            (expenseCurrency == null ||
                !RegExp(r'^[A-Z]{3}$').hasMatch(expenseCurrency!))) ||
        expenseRequestIds.any((id) => id.isEmpty) ||
        expenseRequestIds.toSet().length != expenseRequestIds.length ||
        !expenseRequestIds.toSet().containsAll(savedExpenseRequestIds)) {
      throw const FormatException('Invalid pending trip checkpoint.');
    }
  }

  final TripModel trip;
  final List<TransportationModel> transportation;
  final List<ActivityModel> activities;
  final List<Map<String, dynamic>> expenses;
  final List<String> expenseRequestIds;
  final Set<String> savedExpenseRequestIds;
  final String? expenseCurrency;

  String encode() => jsonEncode({
    'version': 1,
    'trip': trip.toMap(),
    'transportation': transportation.map((item) => item.toMap()).toList(),
    'activities': activities.map((item) => item.toMap()).toList(),
    'expenses': expenses,
    'expenseRequestIds': expenseRequestIds,
    'savedExpenseRequestIds': savedExpenseRequestIds.toList(),
    'expenseCurrency': expenseCurrency,
  });

  factory PendingTripImport.decode(String source, String ownerId) {
    if (source.length > 250000) {
      throw const FormatException('Pending trip checkpoint is too large.');
    }
    final data = jsonDecode(source) as Map<String, dynamic>;
    if (data['version'] != 1) {
      throw const FormatException('Unsupported pending trip checkpoint.');
    }
    final trip = TripModel.fromMap(
      Map<String, dynamic>.from(data['trip'] as Map),
    );
    if (trip.createdBy != ownerId) {
      throw const FormatException('Pending trip belongs to another account.');
    }
    final transportRaw = data['transportation'] as List;
    final activityRaw = data['activities'] as List;
    final expenseRaw = data['expenses'] as List;
    if (transportRaw.length > 50 ||
        activityRaw.length > 200 ||
        expenseRaw.length > 50) {
      throw const FormatException(
        'Pending trip checkpoint exceeds import limits.',
      );
    }
    return PendingTripImport(
      trip: trip,
      transportation: [
        for (final raw in transportRaw)
          TransportationModel.fromMap(
            (raw as Map)['id'] as String,
            trip.id,
            Map<String, dynamic>.from(raw),
          ),
      ],
      activities: [
        for (final raw in activityRaw)
          ActivityModel.fromMap(Map<String, dynamic>.from(raw as Map)),
      ],
      expenses: [
        for (final raw in expenseRaw) Map<String, dynamic>.from(raw as Map),
      ],
      expenseRequestIds: List<String>.from(data['expenseRequestIds'] as List),
      savedExpenseRequestIds: Set<String>.from(
        data['savedExpenseRequestIds'] as List,
      ),
      expenseCurrency: data['expenseCurrency'] as String?,
    );
  }
}

class PendingTripImportStore {
  PendingTripImportStore({
    Future<String?> Function(String key)? read,
    Future<void> Function(String key, String value)? write,
    Future<void> Function(String key)? delete,
  }) : _read = read ?? ((key) => const FlutterSecureStorage().read(key: key)),
       _write =
           write ??
           ((key, value) =>
               const FlutterSecureStorage().write(key: key, value: value)),
       _delete =
           delete ?? ((key) => const FlutterSecureStorage().delete(key: key));

  final Future<String?> Function(String) _read;
  final Future<void> Function(String, String) _write;
  final Future<void> Function(String) _delete;

  String _key(String ownerId) {
    if (ownerId.isEmpty) throw const FormatException('Sign in to save a trip.');
    return 'pendingTripImport.v1.$ownerId';
  }

  Future<PendingTripImport?> load(String ownerId) async {
    final source = await _read(_key(ownerId));
    return source == null ? null : PendingTripImport.decode(source, ownerId);
  }

  Future<void> save(PendingTripImport pending) async {
    final key = _key(pending.trip.createdBy);
    final existing = await _read(key);
    if (existing != null &&
        PendingTripImport.decode(existing, pending.trip.createdBy).trip.id !=
            pending.trip.id) {
      throw const FormatException(
        'Finish the earlier trip save before creating another trip.',
      );
    }
    final encoded = pending.encode();
    if (encoded.length > 250000) {
      throw const FormatException('Pending trip checkpoint is too large.');
    }
    await _write(key, encoded);
  }

  Future<void> delete(String ownerId) => _delete(_key(ownerId));
}
