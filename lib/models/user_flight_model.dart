import 'dart:convert';

import 'package:travel_crew/utils/travel_time.dart';

class UserFlightModel {
  final Map<String, String> timeOffsets;
  UserFlightModel({
    this.timeOffsets = const {},
    required this.id,
    required this.tripId,
    required this.userId,
    this.displayName,
    this.airlineName,
    this.flightNumber,
    this.departureAirport,
    this.arrivalAirport,
    this.departureDate,
    this.arrivalDate,
  });

  factory UserFlightModel.fromMap(Map<String, dynamic> map) {
    return UserFlightModel(
      timeOffsets: TravelTime.offsets(map, ['departureDate', 'arrivalDate']),
      id: map['id'] as String? ?? '',
      tripId: map['tripId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String?,
      airlineName: map['airlineName'] as String?,
      flightNumber: map['flightNumber'] as String?,
      departureAirport: map['departureAirport'] as String?,
      arrivalAirport: map['arrivalAirport'] as String?,
      departureDate:
          map['departureDate'] != null
              ? TravelTime.tryParse(map['departureDate'] as String)
              : null,
      arrivalDate:
          map['arrivalDate'] != null
              ? TravelTime.tryParse(map['arrivalDate'] as String)
              : null,
    );
  }

  factory UserFlightModel.fromJson(String source) =>
      UserFlightModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String id;
  String tripId;
  String userId;
  String? displayName;
  String? airlineName;
  String? flightNumber;
  String? departureAirport;
  String? arrivalAirport;
  DateTime? departureDate;
  DateTime? arrivalDate;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      if (displayName != null) 'displayName': displayName,
      if (airlineName != null) 'airlineName': airlineName,
      if (flightNumber != null) 'flightNumber': flightNumber,
      if (departureAirport != null) 'departureAirport': departureAirport,
      if (arrivalAirport != null) 'arrivalAirport': arrivalAirport,
      if (departureDate != null)
        'departureDate': TravelTime.serialize(
          departureDate,
          timeOffsets['departureDate'],
        ),
      if (arrivalDate != null)
        'arrivalDate': TravelTime.serialize(
          arrivalDate,
          timeOffsets['arrivalDate'],
        ),
    };
  }

  String toJson() => json.encode(toMap());
}
