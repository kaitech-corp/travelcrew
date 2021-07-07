class ActivityData {
  final String _comment;
  final String _displayName;
  final String _endTime;
  final String _fieldID;
  final String _link;
  final String _activityType;
  final String _startTime;
  final String _uid;
  final String _urlToImage;
  final int _vote;
  final List<String> _voters;


  ActivityData.fromData(Map<String, dynamic> data)
      : _comment = data['comment'],
        _displayName = data['displayName'],
        _endTime = data['endTime'],
        _fieldID = data['fieldID'],
        _link = data['link'],
        _activityType = data['activityType'],
        _startTime = data['startTime'],
        _uid = data['uid'],
        _urlToImage = data['urlToImage'],
        _vote = data['vote'],
        _voters = List<String>.from(data['voters']);

  Map<String, dynamic> toJson() {
    return {
      'comment': _comment,
      'displayName': _displayName,
      'endTime': _endTime,
      'fieldID': _fieldID,
      'link': _link,
      'activityType': _activityType,
      'startTime': _startTime,
      'uid': _uid,
      'urlToImage': _urlToImage,
      'vote': _vote,
      'voters': _voters,
    };
  }

  String get comment => _comment;
  String get displayName => _displayName;
  String get endTime => _endTime;
  String get fieldID => _fieldID;
  String get link => _link;
  String get activityType => _activityType;
  String get startTime => _startTime;
  String get uid => _uid;
  String get urlToImage => _urlToImage;
  int get vote => _vote;
  List<String> get voters => _voters;

}