import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/screens/trip_details/cost/split_package.dart';

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
  String hometown;
  String instagramLink;
  String facebookLink;
  List<String> topDestinations;

  UserPublicProfile({this.hometown, this.instagramLink, this.facebookLink, this.topDestinations, this.blockedList, this.displayName, this.email, this.following, this.followers, this.firstName, this.lastName, this.uid, this.urlToImage});

  UserPublicProfile.fromData(Map<String, dynamic> data)
      :
        blockedList = List<String>.from(data['blockedList']) ?? [''],
        displayName = data['displayName'] ?? '',
        email = data['email'] ?? '',
        firstName = data['firstName'] ?? '',
        following = List<String>.from(data['following']) ?? [''],
        followers = List<String>.from(data['followers']) ?? [''],
        lastName = data['lastName'] ?? '',
        tripsCreated = data['tripsCreated'] ?? null,
        tripsJoined = data['tripsJoined'] ?? null,
        uid = data['uid'] ?? '',
        urlToImage = data['urlToImage'] ?? '',
        hometown = data['hometown'] ?? '',
        instagramLink = data['instagramLink'] ?? '',
        facebookLink = data['facebookLink'] ?? '',
        topDestinations = List<String>.from(data['topDestinations']) ?? [''];

  Map<String, dynamic> toJson() {
    return {
      'blockedList': blockedList,
      'displayName': displayName,
      'email': email,
      'firstName': firstName,
      'following': following,
      'followers': followers,
      'lastName': lastName,
      'tripsCreated': tripsCreated,
      'tripsJoined': tripsJoined,
      'uid': uid,
      'urlToImage': urlToImage,
      'hometown': hometown,
      'instagramLink': instagramLink,
      'facebookLink': facebookLink,
      'topDestinations': topDestinations,
    };
  }
}

class Members {
   String uid;
   String displayName;
   String firstName;
   String lastName;
   String urlToImage;

   Members({this.displayName, this.firstName, this.lastName, this.uid, this.urlToImage});

   Members.fromData(Map<String, dynamic> data)
       :displayName = data['displayName'],
         firstName = data['firstName'],
         lastName = data['lastName'],
         uid = data['uid'],
         urlToImage = data['urlToImage'];

   Map<String, dynamic> toJson() {
     return {
       'displayName': displayName,
       'firstName': firstName,
       'lastName': lastName,
       'uid': uid,
       'urlToImage': urlToImage,
     };
   }

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

// class Trip {
//   final List<String> accessUsers;
//   final String comment;
//   final Timestamp dateCreatedTimeStamp;
//   final String displayName;
//   final String documentId;
//   final String endDate;
//   final Timestamp endDateTimeStamp;
//   final List<String> favorite;
//   final bool ispublic;
//   final GeoPoint tripGeoPoint;
//   final String tripName;
//   final String location;
//   final String ownerID;
//   final String startDate;
//   final Timestamp startDateTimeStamp;
//   final String travelType;
//   final String urlToImage;
//
//   Trip({this.tripGeoPoint, this.comment, this.dateCreatedTimeStamp, this.displayName, this.favorite, this.accessUsers, this.documentId, this.endDate, this.endDateTimeStamp, this.ispublic,this.tripName, this.location, this.ownerID, this.startDate, this.startDateTimeStamp, this.travelType, this.urlToImage});
//
//   Trip.fromData(Map<String, dynamic> data)
//       : accessUsers = List<String>.from(data['accessUsers']),
//         comment = data['comment'],
//         dateCreatedTimeStamp = data['dateCreatedTimeStamp'],
//         displayName = data['displayName'],
//         documentId = data['documentId'],
//         endDate = data['endDate'],
//         endDateTimeStamp = data['endDateTimeStamp'],
//         favorite = List<String>.from(data['favorite']),
//         ispublic = data['ispublic'],
//         tripGeoPoint = data['tripGeoPoint'],
//         tripName = data['tripName'],
//         location = data['location'],
//         ownerID = data['ownerID'],
//         startDate = data['startDate'],
//         startDateTimeStamp = data['startDateTimeStamp'],
//         travelType = data['travelType'],
//         urlToImage = data['urlToImage'];
//
//   Map<String, dynamic> toJson() {
//     return {
//       'accessUsers': accessUsers,
//       'comment': comment,
//       'dateCreatedTimeStamp': dateCreatedTimeStamp,
//       'displayName': displayName,
//       'documentId': documentId,
//       'endDate': endDate,
//       'endDateTimeStamp': endDateTimeStamp,
//       'favorite': favorite,
//       'ispublic': ispublic,
//       'tripGeoPoint': tripGeoPoint,
//       'tripName': tripName,
//       'location': location,
//       'ownerID': ownerID,
//       'startDate': startDate,
//       'startDateTimeStamp': startDateTimeStamp,
//       'travelType': travelType,
//       'urlToImage': urlToImage,
//     };
//   }
//
// }

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

  TransportationData.fromData(Map<String, dynamic> data)
      : mode = data['mode'],
        airline = data['airline'],
        airportCode = data['airportCode'],
        canCarpool = data['canCarpool'],
        carpoolingWith = data['carpoolingWith'],
        comment = data['comment'],
        departureDate = data['departureDate'],
        departureDateArrivalTime = data['departureDateArrivalTime'],
        departureDateDepartTime = data['departureDateDepartTime'],
        displayName = data['displayName'],
        fieldID = data['fieldID'],
        flightNumber = data['flightNumber'],
        location = data['location'],
        returnDateArrivalTime = data['returnDateArrivalTime'],
        returnDateDepartTime = data['returnDateDepartTime'],
        returnDate = data['returnDate'],
        tripDocID = data['tripDocID'],
        uid = data['uid'];

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'airline': airline,
      'airportCode': airportCode,
      'canCarpool': canCarpool,
      'carpoolingWith': carpoolingWith,
      'comment': comment,
      'departureDate': departureDate,
      'departureDateArrivalTime': departureDateArrivalTime,
      'departureDateDepartTime': departureDateDepartTime,
      'displayName': displayName,
      'fieldID': fieldID,
      'flightNumber': flightNumber,
      'location': location,
      'returnDateArrivalTime': returnDateArrivalTime,
      'returnDateDepartTime': returnDateDepartTime,
      'returnDate': returnDate,
      'tripDocID': tripDocID,
      'uid': uid,
    };
  }

}

// class LodgingData {
//   final String comment;
//   final String displayName;
//   final String endTime;
//   final String fieldID;
//   final String link;
//   final String lodgingType;
//   final String startTime;
//   final String uid;
//   final String urlToImage;
//   final int vote;
//   final List<String> voters;
//
//   LodgingData({this.endTime, this.startTime, this.comment, this.displayName, this.fieldID, this.link, this.lodgingType, this.uid, this.urlToImage, this.vote, this.voters});
//
//   LodgingData.fromData(Map<String, dynamic> data)
//       : comment = data['comment'],
//         displayName = data['displayName'],
//         endTime = data['endTime'],
//         fieldID = data['fieldID'],
//         link = data['link'],
//         lodgingType = data['lodgingType'],
//         startTime = data['startTime'],
//         uid = data['uid'],
//         urlToImage = data['urlToImage'],
//         vote = data['vote'],
//         voters = List<String>.from(data['voters']);
//
//   Map<String, dynamic> toJson() {
//     return {
//       'comment': comment,
//       'displayName': displayName,
//       'endTime': endTime,
//       'fieldID': fieldID,
//       'link': link,
//       'lodgingType': lodgingType,
//       'startTime': startTime,
//       'uid': uid,
//       'urlToImage': urlToImage,
//       'vote': vote,
//       'voters': voters,
//     };
//   }
//
// }

// class ActivityData {
//   final String comment;
//   final String displayName;
//   final String endTime;
//   final String fieldID;
//   final String link;
//   final String activityType;
//   final String startTime;
//   final String uid;
//   final String urlToImage;
//   final int vote;
//   final List<String> voters;
//
//   ActivityData({this.endTime, this.startTime, this.comment, this.displayName, this.fieldID, this.link, this.activityType, this.uid, this.urlToImage, this.vote, this.voters});
//
//   ActivityData.fromData(Map<String, dynamic> data)
//       : comment = data['comment'],
//         displayName = data['displayName'],
//         endTime = data['endTime'],
//         fieldID = data['fieldID'],
//         link = data['link'],
//         activityType = data['activityType'],
//         startTime = data['startTime'],
//         uid = data['uid'],
//         urlToImage = data['urlToImage'],
//         vote = data['vote'],
//         voters = List<String>.from(data['voters']);
//
//   Map<String, dynamic> toJson() {
//     return {
//       'comment': comment,
//       'displayName': displayName,
//       'endTime': endTime,
//       'fieldID': fieldID,
//       'link': link,
//       'activityType': activityType,
//       'startTime': startTime,
//       'uid': uid,
//       'urlToImage': urlToImage,
//       'vote': vote,
//       'voters': voters,
//     };
//   }
//
// }



// class NotificationData {
//   final String documentID;
//   final String displayName;
//   final String ownerID;
//   final String ownerDisplayName;
//   final String fieldID;
//   final String firstname;
//   final bool ispublic;
//   final String lastname;
//   final String message;
//   final Timestamp timestamp;
//   final String type;
//   final String uid;
//
//   NotificationData({this.ownerID, this.ownerDisplayName, this.displayName, this.firstname, this.ispublic, this.lastname,this.fieldID, this.message, this.timestamp, this.documentID, this.type, this.uid});
//
//   NotificationData.fromData(Map<String, dynamic> data)
//       : documentID = data['documentID'],
//         displayName = data['displayName'],
//         ownerID = data['ownerID'],
//         ownerDisplayName = data['ownerDisplayName'],
//         fieldID = data['fieldID'],
//         firstname = data['firstname'],
//         ispublic = data['ispublic'],
//         lastname = data['lastname'],
//         message = data['message'],
//         timestamp = data['timestamp'],
//         type = data['type'],
//         uid = data['uid'];
//
//   Map<String, dynamic> toJson() {
//     return {
//       'documentID': documentID,
//       'displayName': displayName,
//       'ownerID': ownerID,
//       'ownerDisplayName': ownerDisplayName,
//       'fieldID': fieldID,
//       'firstname': firstname,
//       'ispublic': ispublic,
//       'lastname': lastname,
//       'message': message,
//       'timestamp': timestamp,
//       'type': type,
//       'uid': uid,
//     };
//   }
//
// }

class ChatData {
  final String displayName;
  final String fieldID;
  final String message;
  // final List<Status> status;
  final Timestamp timestamp;
  final String uid;
  final String chatID;


  ChatData({this.fieldID, this.displayName, this.message, this.timestamp, this.uid, this.chatID});

  ChatData.fromData(Map<String, dynamic> data)
      : chatID = data['chatID'] ?? '',
        displayName = data['displayName'] ?? '',
        fieldID = data['fieldID'] ?? '',
        message = data['message'] ?? '',
        timestamp = data['timestamp'] ?? '',
        // status = List<Status>.from(data['status']) ?? [],
        uid = data['uid'];

  Map<String, dynamic> toJson() {
    return {
      'chatID': chatID,
      'displayName': displayName,
      'fieldID': fieldID,
      'message': message,
      'timestamp': timestamp,
      // 'status': status,
      'uid': uid,
    };
  }

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

class CountDownDate {

  double initialDayCount;
  double daysLeft;
  double gaugeCount;

  CountDownDate({this.daysLeft,this.initialDayCount,this.gaugeCount});
}


class ExpansionItem {
  String headerValue;
  bool isExpanded;
  SplitObject item;

  ExpansionItem({this.item,this.headerValue,this.isExpanded = false});
}