import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/transportation_model.dart';

class TransportationService {
  static DocumentReference<Map<String, dynamic>> tripRef(
    String tripId, {
    FirebaseFirestore? database,
  }) => (database ?? firestore).collection('trips').doc(tripId);

  static Stream<List<TransportationModel>> watch(String tripId) {
    late StreamController<List<TransportationModel>> output;
    final subscriptions = <StreamSubscription>[];
    final snapshots = <String, dynamic>{};
    void emit() {
      if (snapshots.length != 4 || output.isClosed) return;
      final trip = snapshots['trip'] as DocumentSnapshot<Map<String, dynamic>>;
      if (!trip.exists) {
        output.add([]);
        return;
      }
      List<TransportationModel> entries(
        String name,
        TransportationSource source,
      ) =>
          (snapshots[name] as QuerySnapshot<Map<String, dynamic>>).docs
              .where((doc) => doc.data()['moderationRemoved'] != true)
              .map(
                (doc) => TransportationModel.fromMap(
                  doc.id,
                  tripId,
                  doc.data(),
                  source: source,
                ),
              )
              .toList();
      final hiddenFlights = <TransportationModel>[];
      for (final source in ['flights', 'legacy']) {
        for (final doc
            in (snapshots[source] as QuerySnapshot<Map<String, dynamic>>)
                .docs) {
          if (doc.data()['moderationRemoved'] == true) {
            hiddenFlights.add(
              TransportationModel.fromMap(
                doc.id,
                tripId,
                doc.data(),
                source:
                    source == 'flights'
                        ? TransportationSource.flight
                        : TransportationSource.legacyFlight,
              ),
            );
          }
        }
      }
      bool visibleFlight(TransportationModel entry) =>
          !hiddenFlights.any(
            (hidden) => TransportationModel.sameFlight(entry, hidden),
          );
      output.add(
        TransportationModel.combine(
          TransportationModel.fromMap(
            'legacy-summary',
            tripId,
            trip.data()!,
            source: TransportationSource.trip,
          ),
          entries('flights', TransportationSource.flight).where(visibleFlight),
          entries(
            'legacy',
            TransportationSource.legacyFlight,
          ).where(visibleFlight),
          entries('transportation', TransportationSource.transportation),
          hiddenFlights: hiddenFlights,
        ),
      );
    }

    void listen(String key, Stream<dynamic> stream) {
      subscriptions.add(
        stream.listen(
          (value) {
            snapshots[key] = value;
            emit();
          },
          onError: (Object error, StackTrace stack) {
            if (!output.isClosed) output.addError(error, stack);
          },
        ),
      );
    }

    output = StreamController<List<TransportationModel>>(
      onListen: () {
        final trip = tripRef(tripId);
        listen('trip', trip.snapshots());
        listen('flights', trip.collection('flights').snapshots());
        listen(
          'legacy',
          firestore
              .collection('flights')
              .where('tripId', isEqualTo: tripId)
              .snapshots(),
        );
        listen('transportation', trip.collection('transportation').snapshots());
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return output.stream;
  }

  static DocumentReference<Map<String, dynamic>> sourceRef(
    TransportationModel entry, {
    FirebaseFirestore? database,
  }) => switch (entry.source) {
    TransportationSource.trip => tripRef(entry.tripId, database: database),
    TransportationSource.flight => tripRef(
      entry.tripId,
      database: database,
    ).collection('flights').doc(entry.id),
    TransportationSource.legacyFlight => (database ?? firestore)
        .collection('flights')
        .doc(entry.id),
    TransportationSource.transportation => tripRef(
      entry.tripId,
      database: database,
    ).collection('transportation').doc(entry.id),
  };

  static Future<void> save(
    TransportationModel entry, {
    required bool isNew,
    FirebaseFirestore? database,
  }) async {
    if (entry.issue != null) throw FormatException(entry.issue!);
    await _mutate(entry, isNew: isNew, remove: false, database: database);
  }

  static Future<void> delete(
    TransportationModel entry, {
    FirebaseFirestore? database,
  }) => _mutate(entry, isNew: false, remove: true, database: database);

  static Future<void> _mutate(
    TransportationModel entry, {
    required bool isNew,
    required bool remove,
    FirebaseFirestore? database,
  }) async {
    final db = database ?? firestore;
    final trip = tripRef(entry.tripId, database: db);
    final source = sourceRef(entry, database: db);
    final target =
        entry.mode == TransportationMode.flight
            ? (entry.source == TransportationSource.legacyFlight && !isNew
                ? source
                : trip.collection('flights').doc(entry.id))
            : trip.collection('transportation').doc(entry.id);
    await db.runTransaction((transaction) async {
      final tripSnapshot = await transaction.get(trip);
      if (!tripSnapshot.exists) {
        throw StateError('This trip is no longer available.');
      }
      final previous = isNew ? null : await transaction.get(source);
      if (!isNew && !previous!.exists) {
        throw StateError('This entry was removed. Refresh the trip.');
      }
      final summary = TransportationModel.fromMap(
        'legacy-summary',
        entry.tripId,
        tripSnapshot.data()!,
        source: TransportationSource.trip,
      );
      final original =
          previous == null
              ? null
              : TransportationModel.fromMap(
                entry.id,
                entry.tripId,
                previous.data()!,
                source: entry.source,
              );
      if (!isNew &&
          entry.source == TransportationSource.trip &&
          !original!.hasDetails) {
        throw StateError('This flight was removed. Refresh the trip.');
      }
      // Updating an assistant-created mirrored flight must not leave a stale
      // summary behind, or it would reappear as a duplicate after reload.
      final linkedSummary =
          original != null &&
          summary.hasDetails &&
          TransportationModel.sameFlight(summary, original);
      DocumentReference<Map<String, dynamic>>? mirror;
      if (!isNew &&
          entry.source == TransportationSource.flight &&
          entry.hasLegacyMirror) {
        final reference = db.collection('flights').doc(entry.id);
        final snapshot = await transaction.get(reference);
        if (snapshot.exists &&
            snapshot.data()!['tripId'] == entry.tripId &&
            TransportationModel.sameFlight(
              original!,
              TransportationModel.fromMap(
                entry.id,
                entry.tripId,
                snapshot.data()!,
                source: TransportationSource.legacyFlight,
              ),
            )) {
          mirror = reference;
        }
      }
      if (isNew) {
        final existing = await transaction.get(target);
        if (existing.exists) throw StateError('This entry already exists.');
      } else if (source.path != target.path && !remove) {
        final existing = await transaction.get(target);
        if (existing.exists) {
          throw StateError('Another entry already uses this ID.');
        }
      }
      if (!isNew &&
          (remove || source.path != target.path) &&
          entry.source != TransportationSource.trip) {
        transaction.delete(source);
      }
      if (mirror != null) {
        if (remove || entry.mode != TransportationMode.flight) {
          transaction.delete(mirror);
        } else {
          transaction.update(mirror, entry.toFlightMap());
        }
      }
      if (!remove) {
        final data =
            entry.mode == TransportationMode.flight
                ? entry.toFlightMap()
                : entry.toMap();
        if (!isNew && source.path == target.path) {
          transaction.update(target, data);
        } else {
          transaction.set(target, data);
        }
      }
      if (entry.source == TransportationSource.trip && !isNew ||
          linkedSummary) {
        transaction.update(trip, {
          for (final field in TransportationModel.flightFields) field: null,
        });
      }
    });
  }
}
