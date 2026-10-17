// Deliberate in-memory Firestore test doubles; production uses the real SDK.
// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/transportation_model.dart';
import 'package:travel_crew/services/transportation_service.dart';

class MemoryDatabase extends Fake implements FirebaseFirestore {
  final records = <String, Map<String, dynamic>>{
    'trips/trip': {'createdBy': 'owner'},
  };
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      MemoryCollection(this, path);
  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    final transaction = MemoryTransaction(this);
    final result = await transactionHandler(transaction);
    for (final write in transaction.writes) {
      write();
    }
    return result;
  }
}

class MemoryCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  MemoryCollection(this.db, this.path);
  final MemoryDatabase db;
  @override
  final String path;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      MemoryDoc(db, '${this.path}/$path');
}

class MemoryDoc extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  MemoryDoc(this.db, this.path);
  final MemoryDatabase db;
  @override
  final String path;
  @override
  String get id => path.split('/').last;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      MemoryCollection(db, '${this.path}/$path');
}

class MemorySnapshot<T> extends Fake implements DocumentSnapshot<T> {
  MemorySnapshot(this.value);
  final T? value;
  @override
  bool get exists => value != null;
  @override
  T? data() => value;
}

class MemoryTransaction extends Fake implements Transaction {
  MemoryTransaction(this.db);
  final MemoryDatabase db;
  final writes = <void Function()>[];
  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(
    DocumentReference<T> reference,
  ) async {
    expect(
      writes,
      isEmpty,
      reason: 'Firestore requires every transaction read before writes',
    );
    return MemorySnapshot<T>(db.records[reference.path] as T?);
  }

  @override
  Transaction set<T>(
    DocumentReference<T> reference,
    T data, [
    SetOptions? options,
  ]) {
    writes.add(
      () => db.records[reference.path] = Map<String, dynamic>.from(data as Map),
    );
    return this;
  }

  @override
  Transaction update(DocumentReference reference, Map<Object, Object?> data) {
    writes.add(() {
      expect(db.records.containsKey(reference.path), isTrue);
      db.records[reference.path]!.addAll(Map<String, dynamic>.from(data));
    });
    return this;
  }

  @override
  Transaction delete(DocumentReference reference) {
    writes.add(() => db.records.remove(reference.path));
    return this;
  }
}

TransportationModel flight({
  TransportationSource source = TransportationSource.flight,
  bool mirror = false,
}) => TransportationModel.fromMap(
  'one',
  'trip',
  {
    'userId': 'owner',
    'createdBy': 'owner',
    'flightNumber': 'AB123',
    'departureDate': '2027-04-10T10:00:00+09:00',
  },
  source: source,
  hasLegacyMirror: mirror,
);

void main() {
  test(
    'new flights use compatible storage while nonflight records use transportation',
    () async {
      final db = MemoryDatabase();
      final item = TransportationModel(
        id: 'ride',
        tripId: 'trip',
        userId: 'owner',
        mode: TransportationMode.rideshare,
      );
      await TransportationService.save(item, isNew: true, database: db);
      expect(
        db.records['trips/trip/transportation/ride']!['mode'],
        'rideshare',
      );
      await TransportationService.save(flight(), isNew: true, database: db);
      expect(db.records['trips/trip/flights/one']!['flightNumber'], 'AB123');
      expect(db.records.containsKey('trips/trip/transportation/one'), isFalse);
    },
  );
  test(
    'editing and deleting mirrored flights cannot resurrect old summary or top-level copies',
    () async {
      final db = MemoryDatabase();
      final original = flight(mirror: true);
      db.records['trips/trip']!.addAll(original.toTripFlightMap());
      db.records['trips/trip/flights/one'] = original.toFlightMap();
      db.records['flights/one'] = original.toFlightMap();
      final updated = TransportationModel.fromMap(
        'one',
        'trip',
        {...original.toFlightMap(), 'flightNumber': 'AB456'},
        source: TransportationSource.flight,
        hasLegacyMirror: true,
      );
      await TransportationService.save(updated, isNew: false, database: db);
      expect(db.records['trips/trip/flights/one']!['flightNumber'], 'AB456');
      expect(db.records['flights/one']!['flightNumber'], 'AB456');
      expect(db.records['trips/trip']!['flightNumber'], isNull);
      await TransportationService.delete(updated, database: db);
      expect(db.records.containsKey('trips/trip/flights/one'), isFalse);
      expect(db.records.containsKey('flights/one'), isFalse);
    },
  );
  test(
    'legacy summary becomes a compatible flight on edit and preserves additional details',
    () async {
      final db = MemoryDatabase();
      final original = flight(source: TransportationSource.trip);
      db.records['trips/trip']!.addAll(original.toTripFlightMap());
      final updated = TransportationModel(
        id: 'one',
        tripId: 'trip',
        userId: 'owner',
        mode: TransportationMode.flight,
        source: TransportationSource.trip,
        notes: 'Bring passport',
        serviceNumber: 'AB123',
      );
      await TransportationService.save(updated, isNew: false, database: db);
      expect(db.records['trips/trip/flights/one']!['notes'], 'Bring passport');
      expect(db.records['trips/trip']!['flightNumber'], isNull);
    },
  );
  test(
    'changing modes moves the entry atomically and deleted records cannot be recreated by edit',
    () async {
      final db = MemoryDatabase();
      db.records['trips/trip/flights/one'] = flight().toFlightMap();
      final changed = TransportationModel(
        id: 'one',
        tripId: 'trip',
        userId: 'owner',
        mode: TransportationMode.train,
        source: TransportationSource.flight,
        title: 'Train instead',
      );
      await TransportationService.save(changed, isNew: false, database: db);
      expect(db.records.containsKey('trips/trip/flights/one'), isFalse);
      expect(db.records['trips/trip/transportation/one']!['mode'], 'train');
      await expectLater(
        TransportationService.save(changed, isNew: false, database: db),
        throwsStateError,
      );
      expect(
        db.records['trips/trip/transportation/one']!['title'],
        'Train instead',
      );
    },
  );
}
