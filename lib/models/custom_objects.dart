import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String displayName;
  final String email;
  final String firstName;
  final String lastName;
  final String uid;

  User({this.displayName, this.email, this.firstName, this.lastName, this.uid});

}
class UserSignUp {
   String displayName;
   String email;
   String firstName;
   String lastName;
   String uid;

   UserSignUp({this.displayName, this.email, this.firstName, this.lastName, this.uid});

}
class UserPublicProfile {
  List<String> blockedList;
  String displayName;
  String email;
  String firstName;
  List<String> following;
  List<String> followers;
  String lastName;
  int tripsCreated;
  int tripsJoined;
  String uid;
  String urlToImage;

  UserPublicProfile({this.blockedList, this.displayName, this.email, this.following, this.followers, this.firstName, this.lastName, this.uid, this.urlToImage});

}

class Members {
   String uid;
   String displayName;
   String firstName;
   String lastName;
   String urlToImage;

   Members({this.displayName, this.firstName, this.lastName, this.uid, this.urlToImage});
}

class Bringing {
  String item;
  String displayName;
  String documentID;
  List<String> voters;

  Bringing({this.voters, this.displayName, this.documentID, this.item});
}

class Need {
  String item;
  String displayName;
  String documentID;

  Need({this.displayName, this.documentID, this.item});
}

class Trip {
  final List<String> accessUsers;
  final String comment;
  final Timestamp dateCreatedTimeStamp;
  final String displayName;
  final String documentId;
  final String endDate;
  final Timestamp endDateTimeStamp;
  final List<String> favorite;
  final bool ispublic;
  final GeoPoint tripGeoPoint;
  final String tripName;
  final String location;
  final String ownerID;
  final String startDate;
  final Timestamp startDateTimeStamp;
  final String travelType;
  final String urlToImage;

  Trip({this.tripGeoPoint, this.comment, this.dateCreatedTimeStamp, this.displayName, this.favorite, this.accessUsers, this.documentId, this.endDate, this.endDateTimeStamp, this.ispublic,this.tripName, this.location, this.ownerID, this.startDate, this.startDateTimeStamp, this.travelType, this.urlToImage});
}
class PrivateTrip {
  final List<String> accessUsers;
  final String comment;
  final Timestamp dateCreatedTimeStamp;
  final String displayName;
  final String documentId;
  final String endDate;
  final Timestamp endDateTimeStamp;
  final List<String> favorite;
  final bool ispublic;
  final GeoPoint tripGeoPoint;
  final String tripName;
  final String location;
  final String ownerID;
  final String startDate;
  final Timestamp startDateTimeStamp;
  final String travelType;
  final String urlToImage;

  PrivateTrip({this.tripGeoPoint, this.comment, this.dateCreatedTimeStamp, this.displayName, this.favorite, this.accessUsers, this.documentId, this.endDate, this.endDateTimeStamp, this.ispublic,this.tripName, this.location, this.ownerID, this.startDate, this.startDateTimeStamp, this.travelType, this.urlToImage});
}

class TransportationData {
  final String mode;
  final String airline;
  final String airportCode;
  final bool canCarpool;
  final String carpoolingWith;
  final String comment;
  final String departureDate;
  final String departureDateArrivalTime;
  final String departureDateDepartTime;
  final String displayName;
  final String fieldID;
  final String flightNumber;
  final String location;
  final String returnDateArrivalTime;
  final String returnDateDepartTime;
  final String returnDate;
  final String uid;
  final String tripDocID;

  TransportationData({this.tripDocID,this.fieldID,this.uid, this.comment, this.canCarpool, this.carpoolingWith,this.mode, this.airportCode, this.displayName, this.location, this.airline, this.departureDate,this.departureDateArrivalTime, this.departureDateDepartTime, this.flightNumber, this.returnDate, this.returnDateArrivalTime, this.returnDateDepartTime });
}

class LodgingData {
  final String comment;
  final String displayName;
  final String endTime;
  final String fieldID;
  final String link;
  final String lodgingType;
  final String startTime;
  final String uid;
  final String urlToImage;
  final int vote;
  final List<String> voters;

  LodgingData({this.endTime, this.startTime, this.comment, this.displayName, this.fieldID, this.link, this.lodgingType, this.uid, this.urlToImage, this.vote, this.voters});
}

class ActivityData {
  final String comment;
  final String displayName;
  final String endTime;
  final String fieldID;
  final String link;
  final String activityType;
  final String startTime;
  final String uid;
  final String urlToImage;
  final int vote;
  final List<String> voters;

  ActivityData({this.endTime, this.startTime, this.comment, this.displayName, this.fieldID, this.link, this.activityType, this.uid, this.urlToImage, this.vote, this.voters});
}



class NotificationData {
  final String documentID;
  final String displayName;
  final String ownerID;
  final String ownerDisplayName;
  final String fieldID;
  final String firstname;
  final bool ispublic;
  final String lastname;
  final String message;
  final Timestamp timestamp;
  final String type;
  final String uid;

  NotificationData({this.ownerID, this.ownerDisplayName, this.displayName, this.firstname, this.ispublic, this.lastname,this.fieldID, this.message, this.timestamp, this.documentID, this.type, this.uid});

}

class ChatData {
  final String displayName;
  final String fieldID;
  final String message;
  final List<Status> status;
  final Timestamp timestamp;
  final String uid;
  final String chatID;


  ChatData({this.fieldID, this.status, this.displayName, this.message, this.timestamp, this.uid, this.chatID});

}
class Status {
  final String uid;
  final bool status;

  Status.fromMap(Map<String, dynamic> data) : uid = data["uid"], status = data["read"];
  Status({this.uid, this.status,});
}

class Countries {
  final String name;
  final String capital;
  final String region;
  final List<dynamic> currencies;
  final List<dynamic> languages;

  Countries({this.name, this.capital, this.currencies, this.languages, this.region});

  Countries.fromJSON(Map<String, dynamic> jsonMap):
        name = jsonMap['name'],
  capital = jsonMap['capital'],
  currencies = jsonMap['currencies'],
  languages = jsonMap['languages'],
  region = jsonMap['region'];

}


class Holiday {
  final String date;
  final String localName;
  final String name;
  final String countryCode;

Holiday({this.date, this.localName, this.name, this.countryCode});

  Holiday.fromJSON(Map<String, dynamic> jsonMap):
        date = jsonMap['date'],
        localName = jsonMap['localName'],
        name = jsonMap['name'],
        countryCode = jsonMap['countryCode'];

}

class WalmartProducts {
   String query;

  WalmartProducts({this.query});

  WalmartProducts.fromJSON(Map<String, dynamic> jsonMap):
        query = jsonMap['query'];

}

class TCFeedback {
  final String message;
  final Timestamp timestamp;
  final String uid;
  final String fieldID;

  TCFeedback({this.fieldID, this.message, this.timestamp, this.uid});

}

class TCReports {

}

class GoogleData {
  String location;
  GeoPoint geoLocation;

  GoogleData({this.location, this.geoLocation});
}

class TripAds {
  final String tripName;
  final GeoPoint geoPoint;
  final String link;
  final String location;
  final Timestamp dateCreated;
  final String documentID;
  final List<String> favorites;
  final int clicks;
  final List<String> clickers;
  final String urlToImage;

  TripAds(
      {this.link,
        this.urlToImage,
        this.tripName,
      this.geoPoint,
      this.location,
      this.dateCreated,
      this.documentID,
      this.favorites,
      this.clicks,
      this.clickers});
}

class Suggestions {
  final String url;
  final Timestamp timestamp;
  final List<String> tags;
  final String fieldID;

  Suggestions({this.fieldID, this.url, this.timestamp, this.tags});
}

class TrueWay {

  final String name;
  final String address;
  final int distance;
  final String website;

  TrueWay({this.name, this.address, this.distance, this.website});

  TrueWay.fromJSON(Map<String, dynamic> jsonMap):
        name = jsonMap['name'],
        address = jsonMap['address'],
        distance = jsonMap['distance'],
        website = jsonMap['website'];
}