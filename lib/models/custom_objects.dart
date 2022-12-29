import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/constants/constants.dart';
import '../services/functions/cloud_functions.dart';

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
      CloudFunction().logError('Blocked List error: ${e.toString()}');
    }
    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      CloudFunction().logError('Display name error: ${e.toString()}');
    }
    try {
      email = doc.get('email') as String;
    } catch (e) {
      CloudFunction().logError('Email error: ${e.toString()}');
    }
    try {
      facebookLink = doc.get('facebookLink') as String;
    } catch (e) {
      CloudFunction().logError('Facebook link error: ${e.toString()}');
    }
    try {
      firstName = doc.get('firstName') as String;
    } catch (e) {
      CloudFunction().logError('First name error: ${e.toString()}');
    }
    try {
      followers = doc.get('followers') as List<dynamic>;
    } catch (e) {
      CloudFunction().logError('Followers error: ${e.toString()}');
    }
    try {
      following = doc.get('following') as List<dynamic>;
    } catch (e) {
      CloudFunction().logError('Following error: ${e.toString()}');
    }
    try {
      hometown = doc.get('hometown') as String;
    } catch (e) {
      CloudFunction().logError('Hometown error: ${e.toString()}');
    }
    try {
      instagramLink = doc.get('instagramLink') as String;
    } catch (e) {
      CloudFunction().logError('Instagram link error: ${e.toString()}');
    }
    try {
      lastName = doc.get('lastName') as String;
    } catch (e) {
      CloudFunction().logError('Last name error: ${e.toString()}');
    }
    try {
      topDestinations = doc.get('topDestinations') as List<dynamic>;
    } catch (e) {
      CloudFunction().logError('Destinations error: ${e.toString()}');
    }
    try {
      tripsCreated = doc.get('tripsCreated') as int;
    } catch (e) {
      CloudFunction().logError('Trips created error: ${e.toString()}');
    }
    try {
      tripsJoined = doc.get('tripsJoined') as int;
    } catch (e) {
      CloudFunction().logError('Trips joined error: ${e.toString()}');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      CloudFunction().logError('UID error: ${e.toString()}');
    }
    try {
      urlToImage = doc.get('urlToImage') as String;
    } catch (e) {
      CloudFunction().logError('Image url error: ${e.toString()}');
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
      CloudFunction().logError('Display name error: ${e.toString()}');
    }
    try {
      firstName = doc.get('firstName') as String;
    } catch (e) {
      CloudFunction().logError('First name error: ${e.toString()}');
    }
    try {
      lastName = doc.get('lastName') as String;
    } catch (e) {
      CloudFunction().logError('Last name error: ${e.toString()}');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      CloudFunction().logError('UID error: ${e.toString()}');
    }
    try {
      urlToImage = doc.get('urlToImage') as String;
    } catch (e) {
      CloudFunction().logError('Image url error: ${e.toString()}');
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
    } catch (e) {}
    try {
      fieldID = doc.get('fieldID') as String;
    } catch (e) {}
    try {
      timestamp = doc.get('timestamp') as Timestamp;
    } catch (e) {}
    try {
      uid = doc.get('uid') as String;
    } catch (e) {}
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
      CloudFunction().logError('tripName error: ${e.toString()}');
    }
    try {
      geoPoint = doc.get('geoPoint') as GeoPoint;
    } catch (e) {
      CloudFunction().logError('geoPoint error: ${e.toString()}');
    }
    try {
      link = doc.get('link') as String;
    } catch (e) {
      CloudFunction().logError('link error: ${e.toString()}');
    }
    try {
      location = doc.get('location') as String;
    } catch (e) {
      CloudFunction().logError('location error: ${e.toString()}');
    }
    try {
      dateCreated = doc.get('dateCreated') as Timestamp;
    } catch (e) {
      CloudFunction().logError('dateCreated error: ${e.toString()}');
    }
    try {
      documentID = doc.get('documentID') as String;
    } catch (e) {
      CloudFunction().logError('documentID error: ${e.toString()}');
    }
    try {
      var fav = doc.get('favorites') as List<dynamic>;
      fav.forEach((dynamic element) {
        favorites.add(element.toString());
      });
    } catch (e) {
      CloudFunction().logError('favorites error: ${e.toString()}');
    }
    try {
      var clicker = doc.get('clickers') as List<dynamic>;
      clicker.forEach((dynamic element) {
        clickers.add(element.toString());
      });
    } catch (e) {
      CloudFunction().logError('clickers error: ${e.toString()}');
    }
    try {
      clicks = doc.get('clicks') as int;
    } catch (e) {
      CloudFunction().logError('endTime error: ${e.toString()}');
    }
    try {
      urlToImage = doc.get('urlToImage') as String;
    } catch (e) {
      CloudFunction().logError('urlToImage error: ${e.toString()}');
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
