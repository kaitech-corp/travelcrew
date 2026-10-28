import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/transportation_model.dart';

class TransportationService {
  static DocumentReference<Map<String, dynamic>> tripRef(
    String tripId, {
    FirebaseFirestore? database,
  }) => (database ?? firestore).collection('trips').doc(tripId);

  static CollectionReference<Map<String, dynamic>> entriesRef(
    String tripId, {
    FirebaseFirestore? database,
  }) => tripRef(tripId, database: database).collection('transportation');

  static Stream<List<TransportationModel>> watch(String tripId) => entriesRef(
    tripId,
  ).snapshots().map(
    (snapshot) => TransportationModel.sort(
      snapshot.docs
          .where(
            (doc) =>
                doc.data()['moderationRemoved'] != true &&
                doc.data()['isDeleted'] != true,
          )
          .map(
            (doc) => TransportationModel.fromMap(doc.id, tripId, doc.data()),
          ),
    ),
  );

  static Future<void> save(
    TransportationModel entry, {
    required bool isNew,
    FirebaseFirestore? database,
  }) async {
    final issue = entry.issue;
    if (issue != null) throw FormatException(issue);
    if (entry.id.isEmpty || entry.tripId.isEmpty || entry.userId.isEmpty) {
      throw const FormatException('Transportation identity is missing.');
    }
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
    final target = entriesRef(entry.tripId, database: db).doc(entry.id);
    await db.runTransaction((transaction) async {
      final tripSnapshot = await transaction.get(trip);
      final tripData = tripSnapshot.data();
      if (tripData == null ||
          tripData['tripStatus'] == 'deleted' ||
          tripData['moderationRemoved'] == true) {
        throw StateError('This trip is no longer available.');
      }
      final previous = await transaction.get(target);
      if (isNew) {
        if (previous.exists) throw StateError('This entry already exists.');
        if (entry.revision != 1) {
          throw StateError('Refresh before saving this entry.');
        }
        transaction.set(target, entry.toMap());
        return;
      }
      final current = previous.data();
      if (current == null) {
        throw StateError('This entry was removed. Refresh the trip.');
      }
      if (current['moderationRemoved'] == true ||
          current['isDeleted'] == true) {
        throw StateError('This entry is no longer available.');
      }
      if (current['userId'] != entry.userId ||
          current['tripId'] != entry.tripId ||
          current['id'] != entry.id ||
          current['displayName'] != entry.displayName ||
          current['revision'] != entry.revision) {
        throw StateError(
          'This entry changed on another device. Refresh the trip.',
        );
      }
      if (remove) {
        transaction.update(target, {
          'isDeleted': true,
          'revision': entry.revision + 1,
        });
      } else {
        transaction.update(target, {
          ...entry.toMap(),
          'revision': entry.revision + 1,
        });
      }
    });
  }
}
