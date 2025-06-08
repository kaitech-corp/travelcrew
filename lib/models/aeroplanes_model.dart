class AeroplanesModel {
  final String? flightDate;
  final String? flightStatus;
  final Departure? departure;
  final Arrival? arrival;
  final Airline? airline;
  final Flight? flight;

  const AeroplanesModel({
    this.flightDate,
    this.flightStatus,
    this.departure,
    this.arrival,
    this.airline,
    this.flight,
  });

  AeroplanesModel.fromJson(Map<String, dynamic> json)
    : flightDate = json['flight_date'],
      flightStatus = json['flight_status'],
      departure = Departure.fromJson(json['departure']),
      arrival = Arrival.fromJson(json['arrival']),
      airline = Airline.fromJson(json['airline']),
      flight = Flight.fromJson(json['flight']);
}

class Departure {
  final String? airport;
  final String? timezone;
  final String? iata;
  final String? icao;
  final String? terminal;
  final String? scheduled;
  final String? estimated;

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
    : airport = json['airport'],
      timezone = json['timezone'],
      iata = json['iata'],
      icao = json['icao'],
      terminal = json['terminal'],
      scheduled = json['scheduled'],
      estimated = json['estimated'];
}

class Arrival {
  final String? airport;
  final String? timezone;
  final String? iata;
  final String? icao;
  final String? scheduled;

  const Arrival({
    this.airport,
    this.timezone,
    this.iata,
    this.icao,
    this.scheduled,
  });
  Arrival.fromJson(Map<String, dynamic> json)
    : airport = json['airport'],
      timezone = json['timezone'],
      iata = json['iata'],
      icao = json['icao'],
      scheduled = json['scheduled'];
}

class Airline {
  final String? name;
  final String? iata;
  final String? icao;

  const Airline({this.name, this.iata, this.icao});

  Airline.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      iata = json['iata'],
      icao = json['icao'];
}

class Flight {
  final String? number;
  final String? iata;
  final String? icao;

  const Flight({this.number, this.iata, this.icao});

  Flight.fromJson(Map<String, dynamic> json)
    : number = json['number'],
      iata = json['iata'],
      icao = json['icao'];
}
