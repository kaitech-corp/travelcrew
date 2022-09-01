import 'package:cloud_firestore/cloud_firestore.dart';

///Model for user
class User {

  User({this.displayName, this.email, this.firstName, this.lastName, this.uid});
  final String? displayName;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? uid;

}

///Model for user signup
class UserSignUp {

   UserSignUp({this.displayName, this.email, this.firstName, this.lastName, this.uid});
   String? displayName;
   String? email;
   String? firstName;
   String? lastName;
   String? uid;

}

///Model for user public profile
class UserPublicProfile {

  UserPublicProfile({this.hometown, this.instagramLink, this.facebookLink, this.topDestinations, this.blockedList, this.displayName, this.email, this.following, this.followers, this.firstName, this.lastName, this.uid, this.urlToImage});

  UserPublicProfile.fromData(Map<String, dynamic> data)
      :
        blockedList = List<String>.from(data['blockedList'] as List<String>),
        displayName = data['displayName'] as String,
        email = data['email'] as String,
        firstName = data['firstName'] as String,
        following = List<String>.from(data['following'] as List<String>) ,
        followers = List<String>.from(data['followers'] as List<String>),
        lastName = data['lastName'] as String,
        tripsCreated = data['tripsCreated'] as int,
        tripsJoined = data['tripsJoined'] as int,
        uid = data['uid'] as String,
        urlToImage = data['urlToImage'] as String,
        hometown = data['hometown'] as String,
        instagramLink = data['instagramLink'] as String,
        facebookLink = data['facebookLink'] as String,
        topDestinations = List<String>.from(data['topDestinations'] as List<String>);
  List<String>? blockedList;
  String? displayName;
  String? email;
  String? firstName;
  List<String>? following;
  List<String>? followers;
  String? lastName;
  int? tripsCreated;
  int? tripsJoined;
  String? uid;
  String? urlToImage;
  String? hometown;
  String? instagramLink;
  String? facebookLink;
  List<String>? topDestinations;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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

   Members({this.displayName, this.firstName, this.lastName, this.uid, this.urlToImage});

   Members.fromData(Map<String, dynamic> data)
       :displayName = data['displayName'] as String,
         firstName = data['firstName'] as String,
         lastName = data['lastName'] as String,
         uid = data['uid'] as String,
         urlToImage = data['urlToImage'] as String;
   String? uid;
   String? displayName;
   String? firstName;
   String? lastName;
   String? urlToImage;

   Map<String, dynamic> toJson() {
     return <String, dynamic>{
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

  Bringing({this.voters, this.displayName, this.documentID, this.item,this.type});

  Bringing.fromData(Map<String, dynamic> data):
        displayName = data['displayName'] as String,
        item = data['item'] as String,
        documentID = data['documentID'] as String,
        type = data['type'] as String,
        voters = data['voters'] != null ? List<String>.from(data['voters'] as List<String>) : <String>[];
  String? item;
  String? displayName;
  String? documentID;
  List<String>? voters;
  String? type;
}

///Model for item needed for trip
class Need {

  Need({this.displayName, this.documentID, this.item,this.type});

  Need.fromData(Map<String, dynamic> data):
        displayName = data['displayName']  as String,
        item = data['item']  as String,
        documentID = data['documentID'] as String,
        type = data['type'] as String;
  String? item;
  String? displayName;
  String? documentID;
  String? type;
}

///API Objects

// class Countries {
//
//   Countries({this.name, this.capital, this.currencies, this.languages, this.region});
//
//   Countries.fromJSON(Map<String, dynamic> jsonMap):
//         name = jsonMap['name'],
//   capital = jsonMap['capital'],
//   currencies = jsonMap['currencies'],
//   languages = jsonMap['languages'],
//   region = jsonMap['region'];
//   final String? name;
//   final String? capital;
//   final String? region;
//   final List<dynamic>? currencies;
//   final List<dynamic>? languages;
//
// }
//
// ///Model for Holiday
// class Holiday {
//
// Holiday({this.date, this.localName, this.name, this.countryCode});
//
//   Holiday.fromJSON(Map<String, dynamic> jsonMap):
//         date = jsonMap['date'],
//         localName = jsonMap['localName'],
//         name = jsonMap['name'],
//         countryCode = jsonMap['countryCode'];
//   final String? date;
//   final String? localName;
//   final String? name;
//   final String? countryCode;
//
// }

///Model Walmart API
class WalmartProducts {

  WalmartProducts({this.query,this.type});

  WalmartProducts.fromJSON(Map<String, dynamic> jsonMap):
        query = jsonMap['displayName'] as String,
        type = jsonMap['type'] as String;
   String? query;
   String? type;

}

///Model for department type from Walmart API
class Department {

  Department({this.name,this.id});

  Department.fromJSON(Map<String, dynamic> jsonMap):
        name = jsonMap['name'] as String,
        id = jsonMap['id'] as String;
  final String? name;
  final String? id;
}

///Model for quantity from Walmart API
class WalmartProductsItem {

  WalmartProductsItem({this.quantity = 1, this.walmartProducts});
  int quantity;
  final WalmartProducts? walmartProducts;

  void increment() {
    quantity++;
  }
}

///Model for user feedback
class TCFeedback {

  TCFeedback({this.fieldID, this.message, this.timestamp, this.uid});
  final String? message;
  final Timestamp? timestamp;
  final String? uid;
  final String? fieldID;

}

class TCReports {

}
///Model for Google Places
class GoogleData {

  GoogleData({this.location, this.geoLocation});
  String? location;
  GeoPoint? geoLocation;
}

///Model for trip ads show
class TripAds {

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

  TripAds.fromData(Map<String, dynamic> data):
    tripName = data['tripName'] as String,
    documentID = data['documentID'] as String,
    geoPoint = data['geoPoint'] as GeoPoint,
    link = data['link'] as String,
    location = data['location'] as String,
    dateCreated = data['dateCreated'] as Timestamp,
    clicks = data['clicks'] as int,
    favorites = List<String>.from(data['favorites'] as List<String>),
    clickers = List<String>.from(data['clickers'] as List<String>),
    urlToImage = data['urlToImage'] as String;
  final String? tripName;
  final GeoPoint? geoPoint;
  final String? link;
  final String? location;
  final Timestamp? dateCreated;
  final String? documentID;
  final List<String>? favorites;
  final int? clicks;
  final List<String>? clickers;
  final String? urlToImage;
}

///Model for suggestions
class Suggestions {

  Suggestions({this.fieldID, this.url, this.timestamp, this.tags});
  final String? url;
  final Timestamp? timestamp;
  final List<String>? tags;
  final String? fieldID;
}

///Model for map API
class TrueWay {

  TrueWay({this.name, this.address, this.distance, this.website});

  TrueWay.fromJSON(Map<String, dynamic> jsonMap):
        name = jsonMap['name'] as String,
        address = jsonMap['address'] as String,
        distance = jsonMap['distance'] as int,
        website = jsonMap['website'] as String;

  final String? name;
  final String? address;
  final int? distance;
  final String? website;
}

///Model for count down date to show on trip page
class CountDownDate {

  CountDownDate({this.daysLeft,this.initialDayCount,this.gaugeCount});

  double? initialDayCount;
  double? daysLeft;
  double? gaugeCount;
}

///Model for user purchase details: Split Feature
class UserPurchaseDetails{

  UserPurchaseDetails({this.total,this.uid});
  String? uid;
  double? total;
}
///Model for start and end dates
class DateTimeModel{

  DateTimeModel({this.endDate,this.startDate});
  DateTime? startDate;
  DateTime? endDate;
}
