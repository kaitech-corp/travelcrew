import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {

  final String city;
  final String country;
  final String documentID;
  final GeoPoint geoPoint;
  final Timestamp timestamp;
  final String uid;
  final String zipcode;

  LocationModel(
      {this.city,
      this.country,
      this.documentID,
      this.geoPoint,
      this.timestamp,
      this.uid,
      this.zipcode});

  LocationModel.fromData(Map<String, dynamic> data) :
      city = data['city'],
      country = data['country'],
      documentID = data['documentID'],
      geoPoint = data['geoPoint'],
      timestamp = data['timestamp'],
      uid = data['uid'],
      zipcode = data['zipcode'];

  Map<String, dynamic> toJson(){
    return {
      'city': city,
      'country': country,
      'documentID': documentID,
      'geoPoint': geoPoint,
      'timestamp': timestamp,
      'uid': uid,
      'zipcode':zipcode,
    };
  }
}