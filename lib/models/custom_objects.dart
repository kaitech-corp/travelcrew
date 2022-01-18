import 'package:cloud_firestore/cloud_firestore.dart';

///Model for user
class User {
  final String displayName;
  final String email;
  final String firstName;
  final String lastName;
  final String uid;

  User({this.displayName, this.email, this.firstName, this.lastName, this.uid});

}

///Model for user signup
class UserSignUp {
   String displayName;
   String email;
   String firstName;
   String lastName;
   String uid;

   UserSignUp({this.displayName, this.email, this.firstName, this.lastName, this.uid});

}

///Model for user public profile
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

///Model for members of trip
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

///Model for item being brought
class Bringing {
  String item;
  String displayName;
  String documentID;
  List<String> voters;
  String type;

  Bringing({this.voters, this.displayName, this.documentID, this.item,this.type});

  Bringing.fromData(Map<String, dynamic> data):
        displayName = data['displayName'] ?? '',
        item = data['item'] ?? '',
        documentID = data['documentID'] ?? '',
        type = data['type'] != null ? data['type'] : '',
        voters = data['voters'] != null ? List<String>.from(data['voters']) : [];
}

///Model for item needed for trip
class Need {
  String item;
  String displayName;
  String documentID;
  String type;

  Need({this.displayName, this.documentID, this.item,this.type});

  Need.fromData(Map<String, dynamic> data):
        displayName = data['displayName'],
        item = data['item'],
        documentID = data['documentID'],
        type = data['type'] ?? '';
}

///API Objects

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

///Model for Holiday
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

///Model Walmart API
class WalmartProducts {
   String query;
   String type;

  WalmartProducts({this.query,this.type});

  WalmartProducts.fromJSON(Map<String, dynamic> jsonMap):
        query = jsonMap['displayName'],
        // type = jsonMap['super_deps'][0]['name'] ?? '';
        type = jsonMap['type'] ?? '';

}

///Model for department type from Walmart API
class Department {
  final String name;
  final String id;

  Department({this.name,this.id});

  Department.fromJSON(Map<String, dynamic> jsonMap):
        name = jsonMap['name'],
        id = jsonMap['id'];
}

///Model for quantity from Walmart API
class WalmartProductsItem {
  int quantity;
  final WalmartProducts walmartProducts;

  WalmartProductsItem({this.quantity = 1, this.walmartProducts});

  void increment() {
    quantity++;
  }
}

///Model for user feedback
class TCFeedback {
  final String message;
  final Timestamp timestamp;
  final String uid;
  final String fieldID;

  TCFeedback({this.fieldID, this.message, this.timestamp, this.uid});

}

class TCReports {

}
///Model for Google Places
class GoogleData {
  String location;
  GeoPoint geoLocation;

  GoogleData({this.location, this.geoLocation});
}

///Model for trip ads show
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

///Model for suggestions
class Suggestions {
  final String url;
  final Timestamp timestamp;
  final List<String> tags;
  final String fieldID;

  Suggestions({this.fieldID, this.url, this.timestamp, this.tags});
}

///Model for map API
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

///Model for count down date to show on trip page
class CountDownDate {

  double initialDayCount;
  double daysLeft;
  double gaugeCount;

  CountDownDate({this.daysLeft,this.initialDayCount,this.gaugeCount});
}

///Model for user purchase details: Split Feature
class UserPurchaseDetails{
  String uid;
  double total;

  UserPurchaseDetails({this.total,this.uid});
}
///Model for start and end dates
class DateTimeModel{
  DateTime startDate;
  DateTime endDate;

  DateTimeModel({this.endDate,this.startDate});
}