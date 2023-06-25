// ignore_for_file: prefer_final_locals, always_specify_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../services/constants/constants.dart';

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
  UserSignUp(
      {this.displayName, this.email, this.firstName, this.lastName, this.uid});

  String? displayName;
  String? email;
  String? firstName;
  String? lastName;
  String? uid;
}

///Model for user public profile
class UserPublicProfile {
  factory UserPublicProfile.mock() {
    return  UserPublicProfile(
        tripsJoined: 0,
        tripsCreated: 0,
        hometown: 'hometown',
        instagramLink: 'instagramLink',
        facebookLink: 'facebookLink',
        topDestinations: [],
        blockedList: [],
        displayName: 'displayName',
        email: 'email',
        following: [],
        followers: [],
        firstName: 'firstName',
        lastName: 'lastName',
        uid: 'uid',
        urlToImage: profileImagePlaceholder);
  }
  UserPublicProfile(
      {required this.tripsJoined,
      required this.tripsCreated,
      required this.hometown,
      required this.instagramLink,
      required this.facebookLink,
      required this.topDestinations,
      required this.blockedList,
      required this.displayName,
      required this.email,
      required this.following,
      required this.followers,
      required this.firstName,
      required this.lastName,
      required this.uid,
      required this.urlToImage});

  UserPublicProfile copyWith({
    int? tripsJoined,
    int? tripsCreated,
    String? hometown,
    String? instagramLink,
    String? facebookLink,
    List<dynamic>? topDestinations,
    List<dynamic>? blockedList,
    String? displayName,
    String? email,
    List<dynamic>? following,
    List<dynamic>? followers,
    String? firstName,
    String? lastName,
    String? uid,
    String? urlToImage,
  }) {
    return UserPublicProfile(
      tripsJoined: tripsJoined ?? this.tripsJoined,
      tripsCreated: tripsCreated ?? this.tripsCreated,
      hometown: hometown ?? this.hometown,
      instagramLink: instagramLink ?? this.instagramLink,
      facebookLink: facebookLink ?? this.facebookLink,
      topDestinations: topDestinations ?? this.topDestinations,
      blockedList: blockedList ?? this.blockedList,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      uid: uid ?? this.uid,
      urlToImage: urlToImage ?? this.urlToImage,
    );
  }

  factory UserPublicProfile.fromDocument(DocumentSnapshot<Object?> doc) {
    List<dynamic> blockedList = <String>[];
    String displayName = '';
    String email = '';
    String firstName = '';
    List<dynamic> following = <String>[];
    List<dynamic> followers = <String>[];
    String lastName = '';
    int tripsCreated = 0;
    int tripsJoined = 0;
    String uid = '';
    String urlToImage = '';
    String hometown = '';
    String instagramLink = '';
    String facebookLink = '';
    List<dynamic> topDestinations = <String>[];

    try {
      blockedList = doc.get('blockedList') as List<dynamic>;
    } catch (e) {
      if(kDebugMode){
        print('Blocked List error: $e');
      }

    }
    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      // print('Display name error: $e');
    }
    try {
      email = doc.get('email') as String;
    } catch (e) {
      // print('Email error: $e');
    }
    try {
      facebookLink = doc.get('facebookLink') as String;
    } catch (e) {
      // print('Facebook link error: $e');
    }
    try {
      firstName = doc.get('firstName') as String;
    } catch (e) {
      // print('First name error: $e');
    }
    try {
      followers = doc.get('followers') as List<dynamic>;
    } catch (e) {
      // print('Followers error: $e');
    }
    try {
      following = doc.get('following') as List<dynamic>;
    } catch (e) {
      // print('Following error: $e');
    }
    try {
      hometown = doc.get('hometown') as String;
    } catch (e) {
      // print('Hometown error: $e');
    }
    try {
      instagramLink = doc.get('instagramLink') as String;
    } catch (e) {
      // print('Instagram link error: $e');
    }
    try {
      lastName = doc.get('lastName') as String;
    } catch (e) {
      // print('Last name error: $e');
    }
    try {
      topDestinations = doc.get('topDestinations') as List<dynamic>;
    } catch (e) {
      // print('Destinations error: $e');
    }
    try {
      tripsCreated = doc.get('tripsCreated') as int;
    } catch (e) {
      // print('Trips created error: $e');
    }
    try {
      tripsJoined = doc.get('tripsJoined') as int;
    } catch (e) {
      // print('Trips joined error: $e');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      // print('UID error: $e');
    }
    try {
      urlToImage = doc.get('urlToImage') as String;
    } catch (e) {
      // print('Image url error: $e');
    }
    return UserPublicProfile(
        tripsJoined: tripsJoined,
        tripsCreated: tripsCreated,
        hometown: hometown,
        instagramLink: instagramLink,
        facebookLink: facebookLink,
        topDestinations: topDestinations,
        blockedList: blockedList,
        displayName: displayName,
        email: email,
        following: following,
        followers: followers,
        firstName: firstName,
        lastName: lastName,
        uid: uid,
        urlToImage: urlToImage);
  }

  List<dynamic> blockedList;
  String displayName;
  String email;
  String firstName;
  List<dynamic> following;
  List<dynamic> followers;
  String lastName;
  int tripsCreated;
  int tripsJoined;
  String uid;
  String urlToImage;
  String hometown;
  String instagramLink;
  String facebookLink;
  List<dynamic> topDestinations;

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
  Members(
      {required this.displayName,
      required this.firstName,
      required this.lastName,
      required this.uid,
      required this.urlToImage});

  factory Members.fromDocument(DocumentSnapshot<Object?> doc) {
    String displayName = '';
    String firstName = '';
    String lastName = '';
    String uid = '';
    String urlToImage = '';

    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      // print('Display name error: $e');
    }
    try {
      firstName = doc.get('firstName') as String;
    } catch (e) {
      // print('First name error: $e');
    }
    try {
      lastName = doc.get('lastName') as String;
    } catch (e) {
      // print('Last name error: $e');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      // print('UID error: $e');
    }
    try {
      urlToImage = doc.get('urlToImage') as String;
    } catch (e) {
      // print('Image url error: $e');
    }
    return Members(
        displayName: displayName,
        firstName: firstName,
        lastName: lastName,
        uid: uid,
        urlToImage: urlToImage);
  }

  String uid;
  String displayName;
  String firstName;
  String lastName;
  String urlToImage;

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
  Bringing(
      {this.voters, this.displayName, this.documentID, this.item, this.type});

  Bringing.fromData(Map<String, dynamic> data)
      : displayName = data['displayName'] as String,
        item = data['item'] as String,
        documentID = data['documentID'] as String,
        type = data['type'] as String,
        voters = data['voters'] != null
            ? List<String>.from(data['voters'] as List<String>)
            : <String>[];
  String? item;
  String? displayName;
  String? documentID;
  List<String>? voters;
  String? type;
}

///Model for item needed for trip
class Need {
  Need({this.displayName, this.documentID, this.item, this.type});

  Need.fromData(Map<String, dynamic> data)
      : displayName = data['displayName'] as String,
        item = data['item'] as String,
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
  WalmartProducts({this.query, this.type});

  WalmartProducts.fromJSON(Map<String, dynamic> jsonMap)
      : query = jsonMap['displayName'] as String,
        type = jsonMap['type'] as String;
  String? query;
  String? type;
}

///Model for department type from Walmart API
class Department {
  Department({this.name, this.id});

  Department.fromJSON(Map<String, dynamic> jsonMap)
      : name = jsonMap['name'] as String,
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
  TCFeedback(
      {required this.fieldID,
      required this.message,
      required this.timestamp,
      required this.uid});
  factory TCFeedback.fromDocument(DocumentSnapshot<Object?> doc) {
    String message = '';
    String fieldID = '';
    Timestamp timestamp = Timestamp.now();
    String uid = '';

    try {
      message = doc.get('message') as String;
    } catch (e) {
      if(kDebugMode){
        print(e);
      }
    }
    try {
      fieldID = doc.get('fieldID') as String;
    } catch (e) {
      if(kDebugMode){
      print(e);
    }
    }
    try {
      timestamp = doc.get('timestamp') as Timestamp;
    } catch (e) {      if(kDebugMode){
      print(e);
    }}
    try {
      uid = doc.get('uid') as String;
    } catch (e) {      if(kDebugMode){
      print(e);
    }}
    return TCFeedback(
        fieldID: fieldID, message: message, timestamp: timestamp, uid: uid);
  }

  final String message;
  final Timestamp timestamp;
  final String uid;
  final String fieldID;
}

class TCReports {}

///Model for Google Places
class GoogleData {
  GoogleData({this.location, this.geoLocation});

  String? location;
  GeoPoint? geoLocation;
}

///Model for trip ads show
class TripAds {
  TripAds(
      {required this.link,
      required this.urlToImage,
      required this.tripName,
      required this.geoPoint,
      required this.location,
      required this.dateCreated,
      required this.documentID,
      required this.favorites,
      required this.clicks,
      required this.clickers});

  factory TripAds.fromDocument(DocumentSnapshot<Object?> doc) {
    String tripName = '';
    GeoPoint geoPoint = const GeoPoint(0, 0);
    String link = '';
    String location = '';
    Timestamp dateCreated = Timestamp.now();
    String documentID = '';
    List<String> favorites = <String>[''];
    int clicks = 0;
    List<String> clickers = <String>[''];
    String urlToImage = '';

    try {
      tripName = doc.get('tripName') as String;
    } catch (e) {
      if(kDebugMode){
        print(e);
      }
    }
    try {
      geoPoint = doc.get('geoPoint') as GeoPoint;
    } catch (e) {
      // print('geoPoint error: $e');
    }
    try {
      link = doc.get('link') as String;
    } catch (e) {
      // print('link error: $e');
    }
    try {
      location = doc.get('location') as String;
    } catch (e) {
      // print('location error: $e');
    }
    try {
      dateCreated = doc.get('dateCreated') as Timestamp;
    } catch (e) {
      // print('dateCreated error: $e');
    }
    try {
      documentID = doc.get('documentID') as String;
    } catch (e) {
      // print('documentID error: $e');
    }
    try {
      var fav = doc.get('favorites') as List<dynamic>;
      for (final element in fav) {
        favorites.add(element.toString());
      }
    } catch (e) {
      // print('favorites error: $e');
    }
    try {
      var clicker = doc.get('clickers') as List<dynamic>;
      for (final element in clicker) {
        clickers.add(element.toString());
      }
    } catch (e) {
      // print('clickers error: $e');
    }
    try {
      clicks = doc.get('clicks') as int;
    } catch (e) {
      // print('endTime error: $e');
    }
    try {
      urlToImage = doc.get('urlToImage') as String;
    } catch (e) {
      // print('urlToImage error: $e');
    }
    return TripAds(
        link: link,
        urlToImage: urlToImage,
        tripName: tripName,
        geoPoint: geoPoint,
        location: location,
        dateCreated: dateCreated,
        documentID: documentID,
        favorites: favorites,
        clicks: clicks,
        clickers: clickers);
  }

  String tripName;
  GeoPoint geoPoint;
  String link;
  String location;
  Timestamp dateCreated;
  String documentID;
  List<String> favorites;
  int clicks;
  List<String> clickers;
  String urlToImage;
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

  TrueWay.fromJSON(Map<String, dynamic> jsonMap)
      : name = jsonMap['name'] as String,
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
  CountDownDate({this.daysLeft, this.initialDayCount, this.gaugeCount});

  double? initialDayCount;
  double? daysLeft;
  double? gaugeCount;
}

///Model for user purchase details: Split Feature
class UserPurchaseDetails {
  UserPurchaseDetails({required this.total, this.uid});

  String? uid;
  double total;
}

///Model for start and end dates
class DateTimeModel {
  DateTimeModel({this.endDate, this.startDate});

  DateTime? startDate;
  DateTime? endDate;
}

UserPublicProfile defaultProfile = UserPublicProfile(
    tripsJoined: 0,
    tripsCreated: 0,
    hometown: 'hometown',
    instagramLink: 'instagramLink',
    facebookLink: 'facebookLink',
    topDestinations: <String>['Mars'],
    blockedList: <String>[],
    displayName: 'unknown',
    email: 'email',
    following: <String>[],
    followers: <String>[],
    firstName: 'firstName',
    lastName: 'lastName',
    uid: 'uid',
    urlToImage: profileImagePlaceholder);

class DestinationModel {

  DestinationModel(
      {required this.name,
      required this.city,
      required this.country,
      required this.url,
      required this.urlToImage});

  DestinationModel.fromJSON(Map<String, dynamic> json) :
        name = json['name'] as String?,
        city = json['city'] as String?,
        country = json['country'] as String?,
        url = json['url'] as String?,
        urlToImage = json['urlToImage'] as String?;
  final String? name;
  final String? city;
  final String? country;
  final String? url;
  final String? urlToImage;
}
