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

enum TransportationSource { transportation, flight, legacyFlight, trip }

/// Dates remain strings so date-only values and venue-specific offsets survive
/// every read/edit/write cycle without being replaced by the phone timezone.
class TransportationModel {
  const TransportationModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.mode,
    this.hasLegacyMirror = false,
    this.source = TransportationSource.transportation,
    this.displayName = '',
    this.title = '',
    this.origin = '',
    this.destination = '',
    this.departure,
    this.arrival,
    this.provider = '',
    this.serviceNumber = '',
    this.driver = '',
    this.travelerNames = const [],
    this.notes = '',
  });
  final String id, tripId, userId, displayName, title, origin, destination;
  final String? departure, arrival;
  final String provider, serviceNumber, driver, notes;
  final List<String> travelerNames;
  final TransportationMode mode;
  final TransportationSource source;
  final bool hasLegacyMirror;
  String get heading => title.trim().isEmpty ? mode.label : title;
  String get key => '${source.name}:$id';

  factory TransportationModel.fromMap(
    String id,
    String tripId,
    Map<String, dynamic> data, {
    TransportationSource source = TransportationSource.transportation,
    bool hasLegacyMirror = false,
  }) {
    final flight = source != TransportationSource.transportation;
    String text(String key) => data[key] is String ? data[key] as String : '';
    String? optional(String key) => text(key).trim().isEmpty ? null : text(key);
    final mode =
        flight
            ? TransportationMode.flight
            : TransportationMode.values.firstWhere(
              (item) => item.name == data['mode'],
              orElse: () => TransportationMode.other,
            );
    return TransportationModel(
      id: id,
      tripId: tripId,
      userId: text(
        flight && source == TransportationSource.trip ? 'createdBy' : 'userId',
      ),
      mode: mode,
      source: source,
      hasLegacyMirror: hasLegacyMirror,
      displayName: text('displayName'),
      title: text(flight ? 'transportTitle' : 'title'),
      origin: text(flight ? 'departureAirport' : 'origin'),
      destination: text(flight ? 'arrivalAirport' : 'destination'),
      departure: optional(flight ? 'departureDate' : 'departure'),
      arrival: optional(flight ? 'arrivalDate' : 'arrival'),
      provider: text(flight ? 'airlineName' : 'provider'),
      serviceNumber: text(flight ? 'flightNumber' : 'serviceNumber'),
      driver: text('driver'),
      travelerNames:
          (data['travelerNames'] is List
                  ? data['travelerNames'] as List
                  : const [])
              .whereType<String>()
              .toList(),
      notes: text('notes'),
    );
  }

  factory TransportationModel.fromImport(
    Map<String, dynamic> data, {
    required String id,
    required String tripId,
    required String userId,
  }) => TransportationModel.fromMap(id, tripId, {
    ...data,
    'userId': userId,
    'serviceNumber': data['service_number'],
    'travelerNames': data['travelers'],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'tripId': tripId,
    'userId': userId,
    'displayName': displayName,
    'mode': mode.name,
    'title': title.trim(),
    'origin': origin.trim(),
    'destination': destination.trim(),
    'departure': departure,
    'arrival': arrival,
    'provider': provider.trim(),
    'serviceNumber': serviceNumber.trim(),
    'driver': driver.trim(),
    'travelerNames': travelerNames,
    'notes': notes.trim(),
  };

  Map<String, dynamic> toFlightMap() => {
    'id': id,
    'tripId': tripId,
    'userId': userId,
    'displayName': displayName,
    'airlineName': provider.trim(),
    'flightNumber': serviceNumber.trim(),
    'departureAirport': origin.trim(),
    'arrivalAirport': destination.trim(),
    'departureDate': departure,
    'arrivalDate': arrival,
    'transportTitle': heading,
    'driver': driver.trim(),
    'travelerNames': travelerNames,
    'notes': notes.trim(),
  };

  Map<String, dynamic> toTripFlightMap() => {
    for (final field in flightFields) field: toFlightMap()[field],
  };
  static const flightFields = [
    'airlineName',
    'flightNumber',
    'departureAirport',
    'arrivalAirport',
    'departureDate',
    'arrivalDate',
  ];

  bool get hasDetails =>
      [
        title,
        origin,
        destination,
        provider,
        serviceNumber,
        notes,
      ].any((v) => v.trim().isNotEmpty) ||
      departure != null ||
      arrival != null;

  static bool sameFlight(TransportationModel a, TransportationModel b) =>
      a.mode == TransportationMode.flight &&
      b.mode == TransportationMode.flight &&
      a.userId == b.userId &&
      flightFields.every(
        (field) =>
            (a.toFlightMap()[field] ?? '') == (b.toFlightMap()[field] ?? ''),
      );

  static List<TransportationModel> combine(
    TransportationModel summary,
    Iterable<TransportationModel> nested,
    Iterable<TransportationModel> legacy,
    Iterable<TransportationModel> other, {
    Iterable<TransportationModel> hiddenFlights = const [],
  }) {
    final flights = [
      ...nested.map(
        (current) =>
            legacy.any(
                  (old) => current.id == old.id && sameFlight(current, old),
                )
                ? TransportationModel.fromMap(
                  current.id,
                  current.tripId,
                  current.toFlightMap(),
                  source: current.source,
                  hasLegacyMirror: true,
                )
                : current,
      ),
      ...legacy.where(
        (old) =>
            !nested.any(
              (current) => current.id == old.id && sameFlight(current, old),
            ),
      ),
    ];
    final result = [...flights, ...other];
    if (summary.hasDetails &&
        !flights.any((entry) => sameFlight(summary, entry)) &&
        !hiddenFlights.any((entry) => sameFlight(summary, entry))) {
      result.add(summary);
    }
    result.sort((a, b) {
      if (a.departure == null && b.departure != null) return 1;
      if (b.departure == null && a.departure != null) return -1;
      final bothTimed =
          a.departure != null &&
          b.departure != null &&
          TravelTime.offset(a.departure) != null &&
          TravelTime.offset(b.departure) != null;
      final order =
          bothTimed
              ? DateTime.parse(
                a.departure!,
              ).compareTo(DateTime.parse(b.departure!))
              : (a.departure ?? '').compareTo(b.departure ?? '');
      return order == 0 ? a.key.compareTo(b.key) : order;
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
    TravelTime.offset(value) == null
        ? '${value.length == 10 ? '${value}T00:00:00' : value}Z'
        : value,
  );

  static String? dateIssue(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(
      r'^\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?)?$',
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
      final offset = TravelTime.offset(value);
      if (hour > 23 ||
          minute > 59 ||
          second > 59 ||
          (offset != null &&
              offset != 'Z' &&
              (int.parse(offset.substring(1, 3)) > 23 ||
                  int.parse(offset.substring(4, 6)) > 59))) {
        return 'Enter a valid local time.';
      }
    }
    return null;
  }

  String? get issue {
    final bounded = [
      (title, 200),
      (origin, 500),
      (destination, 500),
      (provider, 200),
      (serviceNumber, 100),
      (driver, 200),
      (notes, 4000),
      (displayName, 200),
    ];
    if (bounded.any((entry) => entry.$1.length > entry.$2)) {
      return 'One of the fields is too long.';
    }
    if (travelerNames.length > 50 ||
        travelerNames.any((name) => name.length > 200)) {
      return 'Use up to 50 traveler names, each 200 characters or fewer.';
    }
    for (final value in [departure, arrival]) {
      final error = dateIssue(value);
      if (error != null) return error;
    }
    // Different locations can have arrival clocks earlier than departure clocks.
    // Compare instants only when both endpoints actually supply zone information.
    if (departure != null &&
        arrival != null &&
        ((departure!.length == 10 && arrival!.length == 10) ||
            (TravelTime.offset(departure) != null &&
                TravelTime.offset(arrival) != null))) {
      final reversed =
          departure!.length == 10 || arrival!.length == 10
              ? arrival!
                      .substring(0, 10)
                      .compareTo(departure!.substring(0, 10)) <
                  0
              : DateTime.parse(arrival!).isBefore(DateTime.parse(departure!));
      if (reversed) return 'Arrival must follow departure.';
    }
    return null;
  }
}
