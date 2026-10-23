import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:uuid/uuid.dart';

typedef RecommendationCall =
    Future<Map<String, dynamic>> Function(
      String name,
      Map<String, dynamic> data,
    );

class RecommendationException implements Exception {
  const RecommendationException(this.code);
  final String code;
}

/// Account-scoped feed state. Firebase and the session listener live in the
/// runtime adapter, allowing races and retries to be tested without a device.
class RecommendationService extends ChangeNotifier {
  RecommendationService({required this.call, required this.currentUid});

  final RecommendationCall call;
  final String Function() currentUid;
  final List<TripDiscoveryModel> _items = [];
  final Set<String> _dismissed = {};
  final List<Map<String, dynamic>> _pendingEvents = [];
  final Set<String> _observed = {};
  String _owner = '';
  int _accountEpoch = 0;
  int _loadEpoch = 0;
  String? _cursor;
  String? _sessionId;
  bool _disposed = false;
  bool _flushing = false;
  Completer<void>? _flushDone;
  Timer? _flushTimer;
  int _retryCount = 0;
  bool _retryRefresh = true;

  bool loading = false;
  bool loaded = false;
  bool exhausted = false;
  bool needsRefresh = false;
  String? error;
  List<String> destinations = [];
  Map<String, dynamic> filters = {};
  String? _preferenceVersion;
  final Set<String> busyDismissals = {};

  List<TripDiscoveryModel> get items =>
      List.unmodifiable(_items.where((trip) => !_dismissed.contains(trip.id)));
  bool get hasMore => _cursor != null && !exhausted && !needsRefresh;
  String? get sessionId => _sessionId;

  void bindAccount() {
    if (_owner == currentUid()) return;
    _owner = currentUid();
    _accountEpoch++;
    _loadEpoch++;
    _items.clear();
    _dismissed.clear();
    _pendingEvents.clear();
    _observed.clear();
    busyDismissals.clear();
    _flushTimer?.cancel();
    _flushTimer = null;
    _flushing = false;
    _flushDone = null;
    _retryCount = 0;
    _retryRefresh = true;
    _cursor = null;
    _sessionId = null;
    _preferenceVersion = null;
    destinations = [];
    filters = {};
    loading = false;
    loaded = false;
    exhausted = false;
    needsRefresh = false;
    error = null;
    _changed();
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  bool _sameAccount(int epoch) =>
      !_disposed && epoch == _accountEpoch && _owner == currentUid();

  void updateDismissals(Set<String> ids) {
    _dismissed
      ..clear()
      ..addAll(ids);
    _changed();
  }

  void updatePreferences(Map<String, dynamic> data) {
    final version = data['version'] as String? ?? 'initial';
    final changed = _preferenceVersion != null && version != _preferenceVersion;
    destinations = List<String>.from(data['destinations'] as List? ?? []);
    filters = Map<String, dynamic>.from(data['filters'] as Map? ?? {});
    _preferenceVersion = version;
    if (changed && (loaded || loading)) {
      _loadEpoch++;
      loading = false;
      needsRefresh = true;
      _items.clear();
    }
    _changed();
  }

  Future<void> load({bool refresh = false}) async {
    bindAccount();
    if (_owner.isEmpty || _disposed) return;
    if (!refresh && (loading || needsRefresh || (loaded && !hasMore))) return;
    final account = _accountEpoch;
    final generation = ++_loadEpoch;
    final uid = _owner;
    final cursor = refresh ? null : _cursor;
    _retryRefresh = cursor == null;
    loading = true;
    error = null;
    _changed();
    try {
      final data = await call('getRecommendedTripsV3', {
        'pageSize': 20,
        if (cursor != null) 'cursor': cursor,
      });
      if (!_sameAccount(account) || generation != _loadEpoch) return;
      final session = data['sessionId'] as String;
      if (cursor != null && _sessionId != session) {
        throw const RecommendationException('failed-precondition');
      }
      final results =
          (data['items'] as List)
              .map(
                (row) => TripDiscoveryModel.fromMap(
                  Map<String, dynamic>.from(row as Map),
                  recommendationViewerUid: uid,
                ),
              )
              .toList();
      if (refresh || cursor == null) _items.clear();
      final seen = _items.map((trip) => trip.id).toSet();
      _items.addAll(results.where((trip) => seen.add(trip.id)));
      _sessionId = session;
      _cursor = data['nextCursor'] as String?;
      exhausted = data['exhausted'] == true;
      needsRefresh = false;
      loaded = true;
    } catch (exception) {
      if (!_sameAccount(account) || generation != _loadEpoch) return;
      if (exception is RecommendationException &&
          exception.code == 'failed-precondition') {
        needsRefresh = true;
        error = 'Refresh to see current recommendations.';
      } else {
        error = 'Recommendations could not load. Please try again.';
      }
    } finally {
      if (_sameAccount(account) && generation == _loadEpoch) {
        loading = false;
        _changed();
      }
    }
  }

  Future<void> retry() => load(refresh: _retryRefresh || needsRefresh);

  Future<void> savePreferences(
    List<String> choices, {
    Map<String, dynamic>? availability,
  }) async {
    bindAccount();
    final account = _accountEpoch;
    final data = await call('setRecommendationPreferencesV3', {
      'destinations': choices,
      'filters': availability ?? filters,
    });
    if (!_sameAccount(account)) return;
    updatePreferences(data);
    await load(refresh: true);
  }

  Future<void> dismiss(TripDiscoveryModel trip, bool dismissed) async {
    bindAccount();
    if (_owner.isEmpty ||
        busyDismissals.contains(trip.id) ||
        (trip.recommendation != null &&
            trip.recommendation!.viewerUid != _owner)) {
      return;
    }
    final account = _accountEpoch;
    busyDismissals.add(trip.id);
    _changed();
    try {
      await call('setRecommendationDismissalV3', {
        'tripId': trip.id,
        'dismissed': dismissed,
        if (trip.recommendation?.viewerUid == _owner)
          'sessionId': trip.recommendation!.sessionId,
      });
      if (!_sameAccount(account)) return;
      if (dismissed) {
        _dismissed.add(trip.id);
      } else {
        _dismissed.remove(trip.id);
      }
    } finally {
      if (_sameAccount(account)) {
        busyDismissals.remove(trip.id);
        _changed();
      }
    }
  }

  void observe(TripDiscoveryModel trip, String type) {
    bindAccount();
    final context = trip.recommendation;
    if (context == null || context.viewerUid != _owner || _owner.isEmpty) {
      return;
    }
    if (!{'impression', 'open', 'favorite', 'unfavorite'}.contains(type)) {
      return;
    }
    if (_observed.length >= 1000) _observed.remove(_observed.first);
    final key = '${context.sessionId}:${trip.id}:$type';
    if ((type == 'impression' || type == 'open') && !_observed.add(key)) return;
    // Bounded, transient telemetry. No other account inherits this queue.
    if (_pendingEvents.length >= 100) _pendingEvents.removeAt(0);
    _pendingEvents.add({
      'eventId': const Uuid().v4(),
      'type': type,
      'tripId': trip.id,
      ...context.toMap(),
      'occurredAt': DateTime.now().millisecondsSinceEpoch,
    });
    _flushTimer ??= Timer(const Duration(milliseconds: 500), () {
      _flushTimer = null;
      unawaited(flush());
    });
  }

  /// Best-effort observations never fail a save or join action. The same event
  /// IDs survive retries so a lost response cannot create duplicate impressions.
  Future<void> flush() async {
    bindAccount();
    if (_flushing) {
      await _flushDone?.future;
      return;
    }
    if (_pendingEvents.isEmpty || _owner.isEmpty || _disposed) {
      return;
    }
    final account = _accountEpoch;
    _flushing = true;
    final done = Completer<void>();
    _flushDone = done;
    _flushTimer?.cancel();
    _flushTimer = null;
    final batch = _pendingEvents.take(25).toList();
    try {
      final response = await call('recordRecommendationEventsV3', {
        'events': batch,
      });
      if (!_sameAccount(account)) return;
      final acknowledgments =
          (response['results'] as List? ?? [])
              .whereType<Map>()
              .where(
                (row) => {
                  'accepted',
                  'duplicate',
                  'invalid',
                }.contains(row['status']),
              )
              .map((row) => row['eventId'])
              .toSet();
      if (acknowledgments.isEmpty) throw StateError('No event acknowledgments');
      _pendingEvents.removeWhere(
        (row) => acknowledgments.contains(row['eventId']),
      );
      _retryCount = 0;
    } catch (_) {
      if (!_sameAccount(account)) return;
      _retryCount++;
      if (_retryCount >= 5) {
        final ids = batch.map((event) => event['eventId']).toSet();
        _pendingEvents.removeWhere((event) => ids.contains(event['eventId']));
        _retryCount = 0;
      }
    } finally {
      done.complete();
      if (_sameAccount(account)) {
        _flushing = false;
        _flushDone = null;
        if (_pendingEvents.isNotEmpty) {
          _flushTimer = Timer(Duration(seconds: 1 << _retryCount), () {
            _flushTimer = null;
            unawaited(flush());
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _loadEpoch++;
    _accountEpoch++;
    _flushTimer?.cancel();
    _pendingEvents.clear();
    super.dispose();
  }
}
