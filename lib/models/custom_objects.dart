import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String displayName;
  final String email;
  final String firstname;
  final String lastname;
  final String uid;

  User({this.displayName, this.email, this.firstname, this.lastname, this.uid});

}
class UserSignUp {
   String displayName;
   String email;
   String firstname;
   String lastname;
   String uid;

   UserSignUp({this.displayName, this.email, this.firstname, this.lastname, this.uid});

}
class Trip {
  final List<String> accessUsers;
  final String comment;
  final String displayName;
  final String documentId;
  final String endDate;
  final String endDateTimeStamp;
  final List<String> favorite;
  final bool ispublic;
  final String location;
  final String ownerID;
  final String startDate;
  final String travelType;
  final String urlToImage;

  Trip({this.comment, this.displayName, this.favorite, this.accessUsers, this.documentId, this.endDate, this.endDateTimeStamp, this.ispublic, this.location, this.ownerID, this.startDate, this.travelType, this.urlToImage});
}


class UserProfile {
  final String displayName;
  final String email;
  final String firstname;
  final String lastname;
  final int tripsCreated;
  final int tripsJoined;
  final String uid;
  final String urlToImage;

  UserProfile({this.urlToImage, this.uid, this.lastname, this.firstname, this.email, this.displayName, this.tripsCreated, this.tripsJoined});
}

class FlightData {
  final String airline;
  final String airportCode;
  final String departureDate;
  final String departureDateArrivalTime;
  final String departureDateDepartTime;
  final String displayName;
  final String flightNumber;
  final String location;
  final String returnDateArrivalTime;
  final String returnDateDepartTime;
  final String returnDate;

  FlightData({this.airportCode, this.displayName, this.location, this.airline, this.departureDate,this.departureDateArrivalTime, this.departureDateDepartTime, this.flightNumber, this.returnDate, this.returnDateArrivalTime, this.returnDateDepartTime });
}

class LodgingData {
  final String comment;
  final String displayName;
  final String fieldID;
  final String link;
  final String lodgingType;
  final String uid;
  final String urlToImage;
  final int vote;
  final List<String> voters;

  LodgingData({this.comment, this.displayName, this.fieldID, this.link, this.lodgingType, this.uid, this.urlToImage, this.vote, this.voters});
}

class ActivityData {
  final String comment;
  final String displayName;
  final String fieldID;
  final String link;
  final String activityType;
  final String uid;
  final String urlToImage;
  final int vote;
  final List<String> voters;

  ActivityData({this.comment, this.displayName, this.fieldID, this.link, this.activityType, this.uid, this.urlToImage, this.vote, this.voters});
}



class NotificationData {
  final String fieldID;
  final String message;
  final Timestamp timestamp;
  final String documentID;
  final String type;
  final String uid;

  NotificationData({this.fieldID, this.message, this.timestamp, this.documentID, this.type, this.uid});

}

class ChatData {
  final String displayName;
  final String message;
  final List<Status> status;
  final Timestamp timestamp;
  final String uid;


  ChatData({this.status, this.displayName, this.message, this.timestamp, this.uid,});

}
class Status {
  final String uid;
  final bool status;

  Status.fromMap(Map<String, dynamic> data) : uid = data["uid"], status = data["read"];
  Status({this.uid, this.status,});
}