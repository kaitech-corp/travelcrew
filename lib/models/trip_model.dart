import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/user_flight_model.dart';

class TripModel {
  TripModel({
    this.createdByUser,
    required this.id,
    this.joindUsersList,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.tripStatus,
    required this.destination,
    this.title,
    required this.createdBy,
    this.tripStartDate,
    this.tripEndDate,
    this.tripLocation,
    this.favouriteCount = 0,
    required this.tripBudget,
    required this.country,
    required this.startDate,
    this.joinedUsers,
    this.invitedUsers,
    this.isPrivate,
    this.airlineName,
    this.flightNumber,
    this.departureDate,
    this.arrivalDate,
    this.departureAirport,
    this.arrivalAirport,
    this.lodgingType,
    this.hotelName,
    this.hotelAddress,
    this.checkInDate,
    this.checkOutDate,
    this.expensePerNight,
    this.activities,
    this.expenses,
    required this.endDate,
    required this.daysToGo,
    required this.images,
    this.continent = '',
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      favouriteCount: (map['favouriteCount'] as num?)?.toInt() ?? 0,
      tripStatus: map['tripStatus'] as String? ?? TripStatus.upcoming.name,
      title: map['title'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      tripStartDate:
          map['tripStartDate'] != null
              ? DateTime.parse(map['tripStartDate'] as String)
              : null,
      tripEndDate:
          map['tripEndDate'] != null
              ? DateTime.parse(map['tripEndDate'] as String)
              : null,
      tripLocation: map['tripLocation'] as String?,
      tripBudget: (map['tripBudget'] as num?)?.toDouble() ?? 0.0,
      country: map['country'] as String? ?? '',
      startDate:
          map['startDate'] != null
              ? DateTime.parse(map['startDate'] as String)
              : DateTime.now(),
      joinedUsers:
          (map['joinedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      invitedUsers:
          (map['invitedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      isPrivate: map['isPrivate'] as bool?,
      airlineName: map['airlineName'] as String?,
      flightNumber: map['flightNumber'] as String?,
      departureDate:
          map['departureDate'] != null
              ? DateTime.parse(map['departureDate'] as String)
              : null,
      arrivalDate:
          map['arrivalDate'] != null
              ? DateTime.parse(map['arrivalDate'] as String)
              : null,
      departureAirport: map['departureAirport'] as String?,
      arrivalAirport: map['arrivalAirport'] as String?,
      lodgingType: map['lodgingType'] as String?,
      hotelName: map['hotelName'] as String?,
      hotelAddress: map['hotelAddress'] as String?,
      checkInDate:
          map['checkInDate'] != null
              ? DateTime.parse(map['checkInDate'] as String)
              : null,
      checkOutDate:
          map['checkOutDate'] != null
              ? DateTime.parse(map['checkOutDate'] as String)
              : null,
      expensePerNight: (map['expensePerNight'] as num?)?.toDouble(),
      activities:
          (map['activities'] as List<dynamic>?)
              ?.map((e) => ActivityModel.fromMap(e as Map<String, dynamic>))
              .toList(),
      expenses:
          (map['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseModel.fromMap(e as Map<String, dynamic>))
              .toList(),
      endDate: map['endDate'] as String? ?? '',
      daysToGo: (map['daysToGo'] as num?)?.toInt() ?? 0,
      images:
          (map['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      continent: map['continent'] as String? ?? '',
    );
  }

  factory TripModel.fromJson(String source) =>
      TripModel.fromMap(json.decode(source) as Map<String, dynamic>);
  double latitude;
  double longitude;
  String continent;
  final String id;
  final String destination;
  List<PublicUserModel>? joindUsersList;
  final String? tripStatus;
  final String? title;
  PublicUserModel? createdByUser;
  final String createdBy;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String? tripLocation;
  int favouriteCount;
  final double tripBudget;
  final String country;
  final DateTime startDate;
  List<String>? joinedUsers;
  List<String>? invitedUsers;
  final bool? isPrivate;
  final String? airlineName;
  final String? flightNumber;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final String? departureAirport;
  final String? arrivalAirport;
  final String? lodgingType;
  final String? hotelName;
  final String? hotelAddress;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final double? expensePerNight;
  List<ActivityModel>? activities;
  List<ExpenseModel>? expenses;
  List<UserFlightModel>? flights;

  final String endDate;
  final int daysToGo;
  List<String> images;

  DateTime get effectiveStartDate => tripStartDate ?? startDate;

  int get computedDaysToGo {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      effectiveStartDate.year,
      effectiveStartDate.month,
      effectiveStartDate.day,
    );

    return start.difference(today).inDays;
  }

  TripModel copyWith({
    String? id,
    String? destination,
    double? latitude,
    double? longitude,
    String? title,
    String? createdBy,
    int? favouriteCount,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? tripLocation,
    String? tripStatus,
    double? tripBudget,
    String? country,
    DateTime? startDate,
    List<String>? joinedUsers,
    List<String>? invitedUsers,
    bool? isPrivate,
    String? airlineName,
    String? flightNumber,
    DateTime? departureDate,
    DateTime? arrivalDate,
    String? departureAirport,
    String? arrivalAirport,
    String? lodgingType,
    String? hotelName,
    String? hotelAddress,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? expensePerNight,
    List<ActivityModel>? activities,
    List<ExpenseModel>? expenses,
    String? endDate,
    int? daysToGo,
    List<String>? images,
    String? continent,
  }) {
    return TripModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tripStatus: tripStatus ?? this.tripStatus,
      favouriteCount: favouriteCount ?? this.favouriteCount,
      id: id ?? this.id,
      destination: destination ?? this.destination,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      tripStartDate: tripStartDate ?? this.tripStartDate,
      tripEndDate: tripEndDate ?? this.tripEndDate,
      tripLocation: tripLocation ?? this.tripLocation,
      tripBudget: tripBudget ?? this.tripBudget,
      country: country ?? this.country,
      startDate: startDate ?? this.startDate,
      joinedUsers: joinedUsers ?? this.joinedUsers,
      invitedUsers: invitedUsers ?? this.invitedUsers,
      isPrivate: isPrivate ?? this.isPrivate,
      airlineName: airlineName ?? this.airlineName,
      flightNumber: flightNumber ?? this.flightNumber,
      departureDate: departureDate ?? this.departureDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      lodgingType: lodgingType ?? this.lodgingType,
      hotelName: hotelName ?? this.hotelName,
      hotelAddress: hotelAddress ?? this.hotelAddress,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      expensePerNight: expensePerNight ?? this.expensePerNight,
      activities: activities ?? this.activities,
      expenses: expenses ?? this.expenses,
      endDate: endDate ?? this.endDate,
      daysToGo: daysToGo ?? this.daysToGo,
      images: images ?? this.images,
      continent: continent ?? this.continent,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tripStatus': tripStatus,
      'latitude': latitude,
      'longitude': longitude,
      'id': id,
      'favouriteCount': favouriteCount,
      'destination': destination,
      'title': title,
      'createdBy': createdBy,
      'tripStartDate': tripStartDate?.toIso8601String(),
      'tripEndDate': tripEndDate?.toIso8601String(),
      'tripLocation': tripLocation,
      'tripBudget': tripBudget,
      'country': country,
      'startDate': startDate.toIso8601String(),
      'joinedUsers': joinedUsers,
      'invitedUsers': invitedUsers,
      'isPrivate': isPrivate,
      'airlineName': airlineName,
      'flightNumber': flightNumber,
      'departureDate': departureDate?.toIso8601String(),
      'arrivalDate': arrivalDate?.toIso8601String(),
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'lodgingType': lodgingType,
      'hotelName': hotelName,
      'hotelAddress': hotelAddress,
      'checkInDate': checkInDate?.toIso8601String(),
      'checkOutDate': checkOutDate?.toIso8601String(),
      'expensePerNight': expensePerNight,
      'activities': activities?.map((x) => x.toMap()).toList(),
      'expenses': expenses?.map((x) => x.toMap()).toList(),
      'endDate': endDate,
      'daysToGo': daysToGo,
      'images': images,
      'continent': continent,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'TripModel(id: $id, destination: $destination, title: $title, createdBy: $createdBy, tripStartDate: $tripStartDate, tripEndDate: $tripEndDate, tripLocation: $tripLocation, tripBudget: $tripBudget, country: $country, startDate: $startDate, joinedUsers: $joinedUsers, invitedUsers: $invitedUsers, isPrivate: $isPrivate, airlineName: $airlineName, flightNumber: $flightNumber, departureDate: $departureDate, arrivalDate: $arrivalDate, departureAirport: $departureAirport, arrivalAirport: $arrivalAirport, lodgingType: $lodgingType, hotelName: $hotelName, hotelAddress: $hotelAddress, checkInDate: $checkInDate, checkOutDate: $checkOutDate, expensePerNight: $expensePerNight, activities: $activities, expenses: $expenses, endDate: $endDate, daysToGo: $daysToGo, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TripModel &&
        other.id == id &&
        other.destination == destination &&
        other.title == title &&
        other.createdBy == createdBy &&
        other.tripStartDate == tripStartDate &&
        other.tripEndDate == tripEndDate &&
        other.tripLocation == tripLocation &&
        other.tripBudget == tripBudget &&
        other.country == country &&
        other.startDate == startDate &&
        listEquals(other.joinedUsers, joinedUsers) &&
        listEquals(other.invitedUsers, invitedUsers) &&
        other.isPrivate == isPrivate &&
        other.airlineName == airlineName &&
        other.flightNumber == flightNumber &&
        other.departureDate == departureDate &&
        other.arrivalDate == arrivalDate &&
        other.departureAirport == departureAirport &&
        other.arrivalAirport == arrivalAirport &&
        other.lodgingType == lodgingType &&
        other.hotelName == hotelName &&
        other.hotelAddress == hotelAddress &&
        other.checkInDate == checkInDate &&
        other.checkOutDate == checkOutDate &&
        other.expensePerNight == expensePerNight &&
        listEquals(other.activities, activities) &&
        listEquals(other.expenses, expenses) &&
        other.endDate == endDate &&
        other.daysToGo == daysToGo &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        destination.hashCode ^
        title.hashCode ^
        createdBy.hashCode ^
        tripStartDate.hashCode ^
        tripEndDate.hashCode ^
        tripLocation.hashCode ^
        tripBudget.hashCode ^
        country.hashCode ^
        startDate.hashCode ^
        joinedUsers.hashCode ^
        invitedUsers.hashCode ^
        isPrivate.hashCode ^
        airlineName.hashCode ^
        flightNumber.hashCode ^
        departureDate.hashCode ^
        arrivalDate.hashCode ^
        departureAirport.hashCode ^
        arrivalAirport.hashCode ^
        lodgingType.hashCode ^
        hotelName.hashCode ^
        hotelAddress.hashCode ^
        checkInDate.hashCode ^
        checkOutDate.hashCode ^
        expensePerNight.hashCode ^
        activities.hashCode ^
        expenses.hashCode ^
        endDate.hashCode ^
        daysToGo.hashCode ^
        images.hashCode;
  }
}

List<TripModel> trips = [
  TripModel(
    createdBy: '',
    id: '12',
    tripBudget: 2000,
    destination: 'Bali',
    images: [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQVnR8_RnoC8pqERqM61YAmCfw7tXZhD3jQEg&s',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUuKp-FBMQVXHLY_PLzDFU44_KA63YXq9Bkg&s',
    ],
    country: 'Indonesia',
    startDate: DateTime(2024, 5, 15),
    endDate: '20 May',
    daysToGo: 7,
  ),
  // Add more trips as needed
  TripModel(
    createdBy: '',
    id: '13',
    tripBudget: 2000,
    destination: 'Paris',
    images: [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmpDy7ztjkfg6K87mapZDmFs72F4pVAo2dR41bw2qHudo86HF2gv0T-TTuAtymJo4GCAc&usqp=CAU',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT79lMmLbkyF2Dj2u1pNmWrjlUZfAjDQak0VA&s',
    ],
    country: 'France',
    startDate: DateTime(2024, 6, 15),
    endDate: '25 June',
    daysToGo: 10,
  ),
  TripModel(
    createdBy: '',
    id: '14',
    tripBudget: 2000,
    destination: 'Tokyo',
    images: [
      'https://t3.ftcdn.net/jpg/02/65/23/70/360_F_265237090_Muthvb72m2POYFjyx7F5UCQLh9JdBtKN.jpg',
    ],
    country: 'Japan',
    startDate: DateTime(2024, 7),
    endDate: '10 July',

    daysToGo: 5,
  ),
];

enum TripStatus { upcoming, completed, cancelled, deleted }
