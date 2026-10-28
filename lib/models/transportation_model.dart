import 'package:intl/intl.dart';
import 'package:travel_crew/utils/travel_time.dart';

enum TransportationMode {
  flight('Flight'),
  driving('Driving'),
  rideshare('Rideshare'),
  taxi('Taxi'),
  train('Train'),
  bus('Bus'),
  scooter('Scooter'),
  bicycle('Bicycle'),
  walking('Walking'),
  ferry('Ferry'),
  boat('Boat'),
  other('Other');

  const TransportationMode(this.label);
  final String label;
}

/// Times remain the local clock of the departure or arrival location.
/// Revision is incremented by the service for every edit.
class TransportationModel {
  const TransportationModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.mode,
    this.displayName = '',
    this.departure,
    this.arrival,
    this.notes = '',
    this.revision = 1,
  });
  final String id, tripId, userId, displayName, notes;
  final String? departure, arrival;
  final TransportationMode mode;
  final int revision;

  factory TransportationModel.fromMap(
    String id,
    String tripId,
    Map<String, dynamic> data,
  ) {
    String text(String key) => data[key] is String ? data[key] as String : '';
    String? optional(String key) => text(key).trim().isEmpty ? null : text(key);
    return TransportationModel(
      id: id,
      tripId: tripId,
      userId: text('userId'),
      displayName: text('displayName'),
      mode: TransportationMode.values.firstWhere(
        (item) => item.name == data['mode'],
        orElse: () => TransportationMode.other,
      ),
      departure: optional('departure'),
      arrival: optional('arrival'),
      notes: text('notes'),
      revision: (data['revision'] as num?)?.toInt() ?? 1,
    );
  }

  factory TransportationModel.fromImport(
    Map<String, dynamic> data, {
    required String id,
    required String tripId,
    required String userId,
  }) => TransportationModel.fromMap(id, tripId, {...data, 'userId': userId});

  Map<String, dynamic> toMap() => {
    'id': id,
    'tripId': tripId,
    'userId': userId,
    'displayName': displayName,
    'mode': mode.name,
    'departure': departure,
    'arrival': arrival,
    'notes': notes.trim(),
    'revision': revision,
    'isDeleted': false,
  };

  static List<TransportationModel> sort(Iterable<TransportationModel> entries) {
    final result = entries.toList();
    result.sort((a, b) {
      if (a.departure == null && b.departure != null) return 1;
      if (b.departure == null && a.departure != null) return -1;
      final order = (a.departure ?? '').compareTo(b.departure ?? '');
      return order == 0 ? a.id.compareTo(b.id) : order;
    });
    return result;
  }

  static String formatDate(String? value) {
    if (value == null || value.isEmpty) return '';
    final date = _wallClock(value);
    if (date == null) return value;
    return DateFormat(
      value.length == 10 ? 'MMM d, yyyy' : 'MMM d, yyyy · h:mm a',
    ).format(date);
  }

  // A UTC container prevents the device's DST rules from altering a location's
  // clock. This never adds a timezone to the stored value.
  static DateTime? _wallClock(String value) => TravelTime.tryParse(
    '${value.length == 10 ? '${value}T00:00:00' : value}Z',
  );

  static String? dateIssue(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(
      r'^\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}:\d{2})?$',
    ).hasMatch(value)) {
      return 'Use a valid date and local time.';
    }
    final parsed = _wallClock(value);
    if (parsed == null ||
        DateFormat('yyyy-MM-dd').format(parsed) != value.substring(0, 10)) {
      return 'Enter a valid calendar date.';
    }
    if (value.length > 10) {
      final hour = int.tryParse(value.substring(11, 13)) ?? 24;
      final minute = int.tryParse(value.substring(14, 16)) ?? 60;
      final second = int.tryParse(value.substring(17, 19)) ?? 60;
      if (hour > 23 || minute > 59 || second > 59) {
        return 'Enter a valid local time.';
      }
    }
    return null;
  }

  String? get issue {
    if (revision < 1) return 'Transportation revision is invalid.';
    if (notes.length > 4000 || displayName.length > 200) {
      return 'Transportation notes or display name is too long.';
    }
    for (final value in [departure, arrival]) {
      final error = dateIssue(value);
      if (error != null) return error;
    }
    // Different locations can have arrival clocks earlier than departure clocks.
    if (departure != null &&
        arrival != null &&
        departure!.length == 10 &&
        arrival!.length == 10) {
      final reversed =
          arrival!.substring(0, 10).compareTo(departure!.substring(0, 10)) < 0;
      if (reversed) return 'Arrival must follow departure.';
    }
    return null;
  }
}
