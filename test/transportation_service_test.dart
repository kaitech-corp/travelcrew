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

TransportationModel entry({
  String id = 'one',
  TransportationMode mode = TransportationMode.flight,
  int revision = 1,
  String notes = 'Flight details',
}) => TransportationModel(
  id: id,
  tripId: 'trip',
  userId: 'owner',
  displayName: 'Owner',
  mode: mode,
  notes: notes,
  revision: revision,
);

void main() {
  test('flights and other modes use one transportation collection', () async {
    final db = MemoryDatabase();
    await TransportationService.save(entry(), isNew: true, database: db);
    await TransportationService.save(
      entry(id: 'ride', mode: TransportationMode.rideshare),
      isNew: true,
      database: db,
    );
    expect(db.records['trips/trip/transportation/one']!['mode'], 'flight');
    expect(db.records['trips/trip/transportation/ride']!['mode'], 'rideshare');
    expect(
      db.records.keys.where((path) => path.contains('/flights/')),
      isEmpty,
    );
  });

  test(
    'edits increment revision and reject stale or removed records',
    () async {
      final db = MemoryDatabase();
      final original = entry();
      await TransportationService.save(original, isNew: true, database: db);
      await TransportationService.save(
        entry(mode: TransportationMode.train, notes: 'Train instead'),
        isNew: false,
        database: db,
      );
      final saved = db.records['trips/trip/transportation/one']!;
      expect(saved['revision'], 2);
      expect(saved['mode'], 'train');
      await expectLater(
        TransportationService.save(original, isNew: false, database: db),
        throwsStateError,
      );
      await TransportationService.delete(
        entry(revision: 2, mode: TransportationMode.train),
        database: db,
      );
      expect(db.records['trips/trip/transportation/one']!['isDeleted'], isTrue);
      expect(db.records['trips/trip/transportation/one']!['revision'], 3);
      await expectLater(
        TransportationService.delete(entry(revision: 2), database: db),
        throwsStateError,
      );
      await expectLater(
        TransportationService.save(
          entry(revision: 2),
          isNew: false,
          database: db,
        ),
        throwsStateError,
      );
    },
  );

  test(
    'duplicate IDs, changed identity and unavailable trips are rejected',
    () async {
      final db = MemoryDatabase();
      await TransportationService.save(entry(), isNew: true, database: db);
      await expectLater(
        TransportationService.save(entry(), isNew: true, database: db),
        throwsStateError,
      );
      await expectLater(
        TransportationService.save(
          const TransportationModel(
            id: 'one',
            tripId: 'trip',
            userId: 'other',
            mode: TransportationMode.flight,
            displayName: 'Other',
          ),
          isNew: false,
          database: db,
        ),
        throwsStateError,
      );
      db.records['trips/trip']!['tripStatus'] = 'deleted';
      await expectLater(
        TransportationService.save(entry(id: 'new'), isNew: true, database: db),
        throwsStateError,
      );
    },
  );
}
