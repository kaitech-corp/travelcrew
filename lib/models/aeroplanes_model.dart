class AeroplanesModel {
  const AeroplanesModel({
    this.flightDate,
    this.flightStatus,
    this.departure,
    this.arrival,
    this.airline,
    this.flight,
  });

  AeroplanesModel.fromJson(Map<String, dynamic> json)
    : flightDate = json['flight_date'] as String?,
      flightStatus = json['flight_status'] as String?,
      departure =
          json['departure'] != null
              ? Departure.fromJson(json['departure'] as Map<String, dynamic>)
              : null,
      arrival =
          json['arrival'] != null
              ? Arrival.fromJson(json['arrival'] as Map<String, dynamic>)
              : null,
      airline =
          json['airline'] != null
              ? Airline.fromJson(json['airline'] as Map<String, dynamic>)
              : null,
      flight =
          json['flight'] != null
              ? Flight.fromJson(json['flight'] as Map<String, dynamic>)
              : null;
  final String? flightDate;
  final String? flightStatus;
  final Departure? departure;
  final Arrival? arrival;
  final Airline? airline;
  final Flight? flight;
}

class Departure {
  const Departure({
    this.airport,
    this.timezone,
    this.iata,
    this.icao,
    this.terminal,
    this.scheduled,
    this.estimated,
  });
  Departure.fromJson(Map<String, dynamic> json)
    : airport = json['airport'] as String?,
      timezone = json['timezone'] as String?,
      iata = json['iata'] as String?,
      icao = json['icao'] as String?,
      terminal = json['terminal'] as String?,
      scheduled = json['scheduled'] as String?,
      estimated = json['estimated'] as String?;
  final String? airport;
  final String? timezone;
  final String? iata;
  final String? icao;
  final String? terminal;
  final String? scheduled;
  final String? estimated;
}

class Arrival {
  const Arrival({
    this.airport,
    this.timezone,
    this.iata,
    this.icao,
    this.scheduled,
  });
  Arrival.fromJson(Map<String, dynamic> json)
    : airport = json['airport'] as String?,
      timezone = json['timezone'] as String?,
      iata = json['iata'] as String?,
      icao = json['icao'] as String?,
      scheduled = json['scheduled'] as String?;
  final String? airport;
  final String? timezone;
  final String? iata;
  final String? icao;
  final String? scheduled;
}

class Airline {
  const Airline({this.name, this.iata, this.icao});

  Airline.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String?,
      iata = json['iata'] as String?,
      icao = json['icao'] as String?;
  final String? name;
  final String? iata;
  final String? icao;
}

class Flight {
  const Flight({this.number, this.iata, this.icao});

  Flight.fromJson(Map<String, dynamic> json)
    : number = json['number'] as String?,
      iata = json['iata'] as String?,
      icao = json['icao'] as String?;
  final String? number;
  final String? iata;
  final String? icao;
}
