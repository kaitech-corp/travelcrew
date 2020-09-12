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
  String displayName;
  String email;
  String firstName;
  List<String> following;
  List<String> followers;
  String lastName;
  String uid;
  String urlToImage;

  UserPublicProfile({this.displayName, this.email, this.following, this.followers, this.firstName, this.lastName, this.uid, this.urlToImage});

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

  Bringing({this.displayName, this.documentID, this.item});
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
  final String tripName;
  final String location;
  final String ownerID;
  final String startDate;
  final Timestamp startDateTimeStamp;
  final String travelType;
  final String urlToImage;

  Trip( {this.comment, this.dateCreatedTimeStamp, this.displayName, this.favorite, this.accessUsers, this.documentId, this.endDate, this.endDateTimeStamp, this.ispublic,this.tripName, this.location, this.ownerID, this.startDate, this.startDateTimeStamp, this.travelType, this.urlToImage});
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
  final String tripName;
  final String location;
  final String ownerID;
  final String startDate;
  final Timestamp startDateTimeStamp;
  final String travelType;
  final String urlToImage;

  PrivateTrip({this.comment, this.dateCreatedTimeStamp, this.displayName, this.favorite, this.accessUsers, this.documentId, this.endDate, this.endDateTimeStamp, this.ispublic,this.tripName, this.location, this.ownerID, this.startDate, this.startDateTimeStamp, this.travelType, this.urlToImage});
}

class UserProfile {
  final String displayName;
  final String email;
  final List<String> following;
  final List<String> followers;
  final String firstName;
  final String lastName;
  final int tripsCreated;
  final int tripsJoined;
  final String uid;
  final String urlToImage;

  UserProfile({this.urlToImage, this.uid, this.lastName, this.following, this.followers, this.firstName, this.email, this.displayName, this.tripsCreated, this.tripsJoined});
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
  final String documentID;
  String displayName;
  final String fieldID;
  String firstname;
  String lastname;
  final String message;
  final Timestamp timestamp;
  final String type;
  final String uid;

  NotificationData({this.displayName, this.firstname, this.lastname,this.fieldID, this.message, this.timestamp, this.documentID, this.type, this.uid});

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
class Covid19 {
  final String countryName;
  final String cases;
  final String deaths;
  final String totalRecovered;
  final String newDeaths;
  final String newCases;
  final String seriousCritical;
  final String activeCases;
  final String totalCasesPer1mPopulation;


  Covid19({this.countryName, this.cases, this.deaths, this.totalRecovered, this.newDeaths, this.newCases, this.seriousCritical, this.activeCases, this.totalCasesPer1mPopulation});

  Covid19.fromJSON(Map<String, dynamic> jsonMap):
        countryName = jsonMap['country_name'],
        cases = jsonMap['cases'],
        deaths = jsonMap['deaths'],
        totalRecovered = jsonMap['total_recovered'],
        newDeaths = jsonMap['new_deaths'],
        newCases = jsonMap['new_cases'],
        seriousCritical = jsonMap['serious_critical'],
        activeCases = jsonMap['active_cases'],
        totalCasesPer1mPopulation = jsonMap['total_cases_per_1m_population'];

}

class Covid19_2 {
  final String activeCases;
  final String countryName;
  final String lastUpdate;
  final String totalRecovered;
  final String newDeaths;
  final String newCases;
  final String totalDeaths;
  final String totalCases;

  Covid19_2({this.activeCases, this.countryName, this.lastUpdate, this.totalRecovered, this.newDeaths, this.newCases, this.totalDeaths, this.totalCases,});

  Covid19_2.fromJSON(Map<String, dynamic> jsonMap):
        activeCases = jsonMap['Active Cases_text'],
        countryName = jsonMap['Country_text'],
        lastUpdate = jsonMap['Last Update'],
        totalRecovered = jsonMap['Total Recovered_text'],
        newDeaths = jsonMap['New Deaths_text'],
        newCases = jsonMap['Total Cases_text'],
        totalDeaths = jsonMap['Total Deaths_text'],
        totalCases = jsonMap['Total Cases_text'];
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