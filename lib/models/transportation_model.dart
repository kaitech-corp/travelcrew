
///Model for transportation data
class TransportationData {
  final String _mode;
  final String _airline;
  final String _airportCode;
  final bool _canCarpool;
  final String _carpoolingWith;
  final String _comment;
  final String _departureDate;
  final String _departureDateArrivalTime;
  final String _departureDateDepartTime;
  final String _displayName;
  final String _fieldID;
  final String _flightNumber;
  final String _location;
  final String _returnDateArrivalTime;
  final String _returnDateDepartTime;
  final String _returnDate;
  final String _uid;
  final String _tripDocID;


  TransportationData.fromData(Map<String, dynamic> data)
      : _mode = data['mode'],
        _airline = data['airline'],
        _airportCode = data['airportCode'],
        _canCarpool = data['canCarpool'],
        _carpoolingWith = data['carpoolingWith'],
        _comment = data['comment'],
        _departureDate = data['departureDate'],
        _departureDateArrivalTime = data['departureDateArrivalTime'],
        _departureDateDepartTime = data['departureDateDepartTime'],
        _displayName = data['displayName'],
        _fieldID = data['fieldID'],
        _flightNumber = data['flightNumber'],
        _location = data['location'],
        _returnDateArrivalTime = data['returnDateArrivalTime'],
        _returnDateDepartTime = data['returnDateDepartTime'],
        _returnDate = data['returnDate'],
        _tripDocID = data['tripDocID'],
        _uid = data['uid'];

  Map<String, dynamic> toJson() {
    return {
      'mode': _mode,
      'airline': _airline,
      'airportCode': _airportCode,
      'canCarpool': _canCarpool,
      'carpoolingWith': _carpoolingWith,
      'comment': _comment,
      'departureDate': _departureDate,
      'departureDateArrivalTime': _departureDateArrivalTime,
      'departureDateDepartTime': _departureDateDepartTime,
      'displayName': _displayName,
      'fieldID': _fieldID,
      'flightNumber': _flightNumber,
      'location': _location,
      'returnDateArrivalTime': _returnDateArrivalTime,
      'returnDateDepartTime': _returnDateDepartTime,
      'returnDate': _returnDate,
      'tripDocID': _tripDocID,
      'uid': _uid,
    };
  }

  String get  mode => _mode;
  String get  airline => _airline;
  String get  airportCode => _airportCode;
  bool get canCarpool => _canCarpool;
  String get  carpoolingWith => _carpoolingWith;
  String get  comment => _comment;
  String get  departureDate => _departureDate;
  String get  departureDateArrivalTime => _departureDateArrivalTime;
  String get  departureDateDepartTime => _departureDateDepartTime;
  String get  displayName => _displayName;
  String get  fieldID => _fieldID;
  String get  flightNumber => _flightNumber;
  String get  location => _location;
  String get  returnDateArrivalTime => _returnDateArrivalTime;
  String get  returnDateDepartTime => _returnDateDepartTime;
  String get  returnDate => _returnDate;
  String get  uid => _uid;
  String get  tripDocID => _tripDocID;

}