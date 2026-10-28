import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/lodging_model.dart';
import 'package:travel_crew/models/trip_model.dart';

class LodgingService {
  static const _legacyFields = [
    'lodgingType',
    'hotelName',
    'hotelAddress',
    'checkInDate',
    'checkOutDate',
    'expensePerNight',
    'lodgingCurrencyCode',
  ];

  static Map<String, dynamic> _legacyValues(LodgingModel option) {
    final values = option.toMap();
    return {
      for (final field in _legacyFields)
        field:
            field == 'lodgingCurrencyCode'
                ? option.currencyCode
                : values[field],
    };
  }

  static bool legacyMatches(
    Map<String, dynamic> current,
    String tripId,
    TripModel expected,
  ) => legacyMatchesOption(current, tripId, LodgingModel.fromTrip(expected));

  static bool legacyMatchesOption(
    Map<String, dynamic> current,
    String tripId,
    LodgingModel expected,
  ) {
    final stored = _legacyValues(
      LodgingModel.fromTrip(TripModel.fromMap({...current, 'id': tripId})),
    );
    final before = _legacyValues(expected);
    return _legacyFields.every((field) => stored[field] == before[field]);
  }

  static CollectionReference<Map<String, dynamic>> options(String tripId) =>
      firestore.collection('trips').doc(tripId).collection('lodgings');

  static Future<void> saveLegacy(
    String tripId,
    LodgingModel expected,
    LodgingModel updated,
  ) async {
    if (expected.id != 'legacy' || updated.id != 'legacy') {
      throw ArgumentError('Expected trip-level lodging.');
    }
    final ref = firestore.collection('trips').doc(tripId);
    final after = _legacyValues(updated);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final current = snapshot.data();
      if (current == null ||
          current['tripStatus'] == 'deleted' ||
          current['moderationRemoved'] == true) {
        throw StateError('Trip is unavailable.');
      }
      if (!legacyMatchesOption(current, tripId, expected)) {
        throw StateError('Lodging changed. Reopen it before saving.');
      }
      transaction.update(ref, {
        ...after,
        'lodgingRevision': (current['lodgingRevision'] as int? ?? 0) + 1,
      });
    });
  }

  static Future<void> deleteLegacy(String tripId, LodgingModel expected) async {
    if (expected.id != 'legacy') {
      throw ArgumentError('Expected trip-level lodging.');
    }
    final ref = firestore.collection('trips').doc(tripId);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final current = snapshot.data();
      if (current == null ||
          current['tripStatus'] == 'deleted' ||
          current['moderationRemoved'] == true) {
        throw StateError('Trip is unavailable.');
      }
      if (!legacyMatchesOption(current, tripId, expected)) {
        throw StateError('Lodging changed. Reopen it before deleting.');
      }
      transaction.update(ref, {
        for (final field in _legacyFields) field: null,
        'lodgingRevision': (current['lodgingRevision'] as int? ?? 0) + 1,
      });
    });
  }

  static Stream<List<LodgingModel>> watch(String tripId) =>
      options(tripId).snapshots().map(
        (snapshot) =>
            snapshot.docs
                .where(
                  (doc) =>
                      doc.data()['moderationRemoved'] != true &&
                      doc.data()['isDeleted'] != true,
                )
                .map((doc) => LodgingModel.fromMap(doc.id, doc.data()))
                .where((option) => option.hasDetails)
                .toList(),
      );

  static Stream<Set<String>> watchLikes(String tripId, String lodgingId) =>
      options(tripId)
          .doc(lodgingId)
          .collection('likes')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());

  static Future<void> setLiked(
    String tripId,
    String lodgingId,
    String uid,
    bool liked,
  ) async {
    final ref = options(tripId).doc(lodgingId).collection('likes').doc(uid);
    if (liked) {
      await ref.set({'userId': uid});
    } else {
      await ref.delete();
    }
  }

  static Future<void> save(
    String tripId,
    LodgingModel option, {
    required bool isNew,
  }) async {
    final ref = options(tripId).doc(option.id);
    final tripRef = firestore.collection('trips').doc(tripId);
    await firestore.runTransaction((transaction) async {
      final trip = await transaction.get(tripRef);
      if (!trip.exists ||
          trip.data()?['tripStatus'] == 'deleted' ||
          trip.data()?['moderationRemoved'] == true) {
        throw StateError('Trip is unavailable.');
      }
      final current = await transaction.get(ref);
      if (isNew) {
        if (current.exists) throw StateError('Lodging option already exists.');
        transaction.set(ref, {
          ...option.toMap(),
          'revision': 1,
          'isDeleted': false,
        });
      } else {
        if (!current.exists ||
            current.data()?['isDeleted'] == true ||
            (current.data()?['revision'] as int? ?? 0) != option.revision) {
          throw StateError('Lodging changed. Reopen it before saving.');
        }
        transaction.update(ref, {
          ...option.toMap(),
          'revision': option.revision + 1,
          'isDeleted': false,
        });
      }
    });
  }

  static Future<void> delete(
    String tripId,
    LodgingModel option,
    String uid,
  ) async {
    if (uid.isEmpty || option.id == 'legacy') {
      throw StateError('Choose an editable lodging option.');
    }
    final tripRef = firestore.collection('trips').doc(tripId);
    final ref = options(tripId).doc(option.id);
    await firestore.runTransaction((transaction) async {
      final trip = await transaction.get(tripRef);
      if (!trip.exists ||
          trip.data()?['tripStatus'] == 'deleted' ||
          trip.data()?['moderationRemoved'] == true) {
        throw StateError('Trip is unavailable.');
      }
      final current = await transaction.get(ref);
      if (!current.exists ||
          current.data()?['isDeleted'] == true ||
          (current.data()?['revision'] as int? ?? 0) != option.revision) {
        throw StateError('Lodging changed. Reopen it before deleting.');
      }
      transaction.update(ref, {
        'lodgingType': '',
        'hotelName': '',
        'hotelAddress': '',
        'checkInDate': null,
        'checkOutDate': null,
        'expensePerNight': null,
        'currencyCode': null,
        'revision': option.revision + 1,
        'isDeleted': true,
        'deletedBy': uid,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
