// ignore_for_file: prefer_final_locals

import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/functions/cloud_functions.dart';

///Model for transportation data
class TransportationData {
  TransportationData({
    required this.mode,
    required this.airline,
    required this.airportCode,
    required this.canCarpool,
    required this.carpoolingWith,
    required this.comment,
    required this.departureDate,
    required this.departureDateArrivalTime,
    required this.departureDateDepartTime,
    required this.displayName,
    required this.fieldID,
    required this.flightNumber,
    required this.location,
    required this.returnDateArrivalTime,
    required this.returnDateDepartTime,
    required this.returnDate,
    required this.uid,
    required this.tripDocID,
  });

  factory TransportationData.fromDocument(DocumentSnapshot<Object?> doc) {
    String mode = '';
    String airline = '';
    String airportCode = '';
    bool canCarpool = false;
    String carpoolingWith = '';
    String comment = '';
    String departureDate = '';
    String departureDateArrivalTime = '';
    String departureDateDepartTime = '';
    String displayName = '';
    String fieldID = '';
    String flightNumber = '';
    String location = '';
    String returnDateArrivalTime = '';
    String returnDateDepartTime = '';
    String returnDate = '';
    String uid = '';
    String tripDocID = '';
    try {
      airline = doc.get('airline') as String;
    } catch (e) {
      CloudFunction().logError('amountRemaining error: $e');
    }
    try {
      airportCode = doc.get('airportCode') as String;
    } catch (e) {
      CloudFunction().logError('airportCode error: $e');
    }
    try {
      comment = doc.get('comment') as String;
    } catch (e) {
      CloudFunction().logError('comment error: $e');
    }
    try {
      canCarpool = doc.get('canCarpool') as bool;
    } catch (e) {
      CloudFunction().logError('canCarpool error: $e');
    }
    try {
      carpoolingWith = doc.get('carpoolingWith') as String;
    } catch (e) {
      CloudFunction().logError('carpoolingWith error: $e');
    }
    try {
      comment = doc.get('comment') as String;
    } catch (e) {
      CloudFunction().logError('comment error: $e');
    }
    try {
      displayName = doc.get('displayName') as String;
    } catch (e) {
      CloudFunction().logError('displayName error: $e');
    }
    try {
      departureDateArrivalTime = doc.get('departureDateArrivalTime') as String;
    } catch (e) {
      CloudFunction()
          .logError('departureDateArrivalTime error: $e');
    }
    try {
      departureDateDepartTime = doc.get('departureDateDepartTime') as String;
    } catch (e) {
      CloudFunction()
          .logError('departureDateDepartTime error: $e');
    }
    try {
      departureDate = doc.get('departureDate') as String;
    } catch (e) {
      CloudFunction().logError('departureDate error: $e');
    }
    try {
      fieldID = doc.get('fieldID') as String;
    } catch (e) {
      CloudFunction().logError('fieldID error: $e');
    }
    try {
      flightNumber = doc.get('flightNumber') as String;
    } catch (e) {
      CloudFunction().logError('flightNumber error: $e');
    }
    try {
      location = doc.get('location') as String;
    } catch (e) {
      CloudFunction().logError('location error: $e');
    }
    try {
      returnDate = doc.get('returnDate') as String;
    } catch (e) {
      CloudFunction().logError('returnDate error: $e');
    }
    try {
      returnDateDepartTime = doc.get('returnDateDepartTime') as String;
    } catch (e) {
      CloudFunction().logError('returnDateDepartTime error: $e');
    }
    try {
      returnDateArrivalTime = doc.get('returnDateArrivalTime') as String;
    } catch (e) {
      CloudFunction().logError('returnDateArrivalTime error: $e');
    }
    try {
      uid = doc.get('uid') as String;
    } catch (e) {
      CloudFunction().logError('uid error: $e');
    }
    try {
      tripDocID = doc.get('tripDocID') as String;
    } catch (e) {
      CloudFunction().logError('tripDocID error: $e');
    }
    return TransportationData(
        mode: mode,
        airline: airline,
        airportCode: airportCode,
        canCarpool: canCarpool,
        carpoolingWith: carpoolingWith,
        comment: comment,
        departureDate: departureDate,
        departureDateArrivalTime: departureDateArrivalTime,
        departureDateDepartTime: departureDateDepartTime,
        displayName: displayName,
        fieldID: fieldID,
        flightNumber: flightNumber,
        location: location,
        returnDateArrivalTime: returnDateArrivalTime,
        returnDateDepartTime: returnDateDepartTime,
        returnDate: returnDate,
        uid: uid,
        tripDocID: tripDocID);
  }
  String mode;
  String airline;
  String airportCode;
  bool canCarpool;
  String carpoolingWith;
  String comment;
  String departureDate;
  String departureDateArrivalTime;
  String departureDateDepartTime;
  String displayName;
  String fieldID;
  String flightNumber;
  String location;
  String returnDateArrivalTime;
  String returnDateDepartTime;
  String returnDate;
  String uid;
  String tripDocID;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
