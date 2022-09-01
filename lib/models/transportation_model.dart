
///Model for transportation data
class TransportationData {

  // TransportationData(this._mode, this._airline, this._airportCode, this._canCarpool, this._carpoolingWith, this._comment, this._departureDate, this._departureDateArrivalTime, this._departureDateDepartTime, this._displayName, this._fieldID, this._flightNumber, this._location, this._returnDateArrivalTime, this._returnDateDepartTime, this._returnDate, this._uid, this._tripDocID,);

  TransportationData.fromData(Map<String, dynamic> data)
      : _mode = data['mode'] as String,
        _airline = data['airline'] as String,
        _airportCode = data['airportCode'] as String,
        _canCarpool = data['canCarpool'] as bool,
        _carpoolingWith = data['carpoolingWith'] as String,
        _comment = data['comment'] as String,
        _departureDate = data['departureDate'] as String,
        _departureDateArrivalTime = data['departureDateArrivalTime'] as String,
        _departureDateDepartTime = data['departureDateDepartTime'] as String,
        _displayName = data['displayName'] as String,
        _fieldID = data['fieldID'] as String,
        _flightNumber = data['flightNumber'] as String,
        _location = data['location'] as String,
        _returnDateArrivalTime = data['returnDateArrivalTime'] as String,
        _returnDateDepartTime = data['returnDateDepartTime'] as String,
        _returnDate = data['returnDate'] as String,
        _tripDocID = data['tripDocID'] as String,
        _uid = data['uid'] as String;
  final String _mode;
  final String? _airline;
  final String? _airportCode;
  final bool _canCarpool;
  final String? _carpoolingWith;
  final String? _comment;
  final String? _departureDate;
  final String? _departureDateArrivalTime;
  final String? _departureDateDepartTime;
  final String? _displayName;
  final String _fieldID;
  final String? _flightNumber;
  final String? _location;
  final String? _returnDateArrivalTime;
  final String? _returnDateDepartTime;
  final String? _returnDate;
  final String _uid;
  final String _tripDocID;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
  String? get  airline => _airline;
  String? get  airportCode => _airportCode;
  bool get canCarpool => _canCarpool;
  String? get  carpoolingWith => _carpoolingWith;
  String? get  comment => _comment;
  String? get  departureDate => _departureDate;
  String? get  departureDateArrivalTime => _departureDateArrivalTime;
  String? get  departureDateDepartTime => _departureDateDepartTime;
  String? get  displayName => _displayName;
  String get  fieldID => _fieldID;
  String? get  flightNumber => _flightNumber;
  String? get  location => _location;
  String? get  returnDateArrivalTime => _returnDateArrivalTime;
  String? get  returnDateDepartTime => _returnDateDepartTime;
  String? get  returnDate => _returnDate;
  String get  uid => _uid;
  String get  tripDocID => _tripDocID;

}
