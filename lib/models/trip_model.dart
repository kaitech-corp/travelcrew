import 'dart:convert';

import 'package:travel_crew/utils/travel_time.dart';

import 'package:flutter/foundation.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/finance_expense_model.dart';
import 'package:travel_crew/models/public_user_model.dart';

class TripModel {
  final Map<String, String> timeOffsets;
  TripModel({
    this.timeOffsets = const {},
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
    this.tripBudget = 0.0,
    required this.country,
    required this.startDate,
    this.joinedUsers,
    this.invitedUsers,
    this.isShared = false,
    this.isPrivate,
    this.lodgingType,
    this.hotelName,
    this.hotelAddress,
    this.checkInDate,
    this.checkOutDate,
    this.expensePerNight,
    this.lodgingCurrencyCode,
    this.lodgingRevision = 0,
    this.activities,
    this.expenses,
    this.financeCurrency,
    this.financePrecision,
    this.financeSchemaVersion,
    this.financeMigrationStatus,
    this.hasLegacyExpenseRecords = false,
    this.financeExpenses,
    required this.endDate,
    required this.daysToGo,
    required this.images,
    Map<String, dynamic>? imageCredits,
    this.continent = '',
  }) : imageCredits = Map<String, dynamic>.from(imageCredits ?? {});

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      timeOffsets: TravelTime.offsets(map, ['checkInDate', 'checkOutDate']),
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
      isShared: map['isShared'] as bool? ?? false,
      isPrivate: map['isPrivate'] as bool?,
      lodgingType: map['lodgingType'] as String?,
      hotelName: map['hotelName'] as String?,
      hotelAddress: map['hotelAddress'] as String?,
      checkInDate:
          map['checkInDate'] != null
              ? TravelTime.parse(map['checkInDate'] as String)
              : null,
      checkOutDate:
          map['checkOutDate'] != null
              ? TravelTime.parse(map['checkOutDate'] as String)
              : null,
      expensePerNight: (map['expensePerNight'] as num?)?.toDouble(),
      lodgingCurrencyCode: map['lodgingCurrencyCode'] as String?,
      lodgingRevision: map['lodgingRevision'] as int? ?? 0,
      activities:
          (map['activities'] as List<dynamic>?)
              ?.map((e) => ActivityModel.fromMap(e as Map<String, dynamic>))
              .toList(),
      expenses: _readLegacyExpenses(map['expenses']),
      hasLegacyExpenseRecords:
          map['expenses'] is List
              ? (map['expenses'] as List).isNotEmpty
              : map['expenses'] != null,
      financeCurrency: map['financeCurrency'] as String?,
      financePrecision: (map['financePrecision'] as num?)?.toInt(),
      financeSchemaVersion: (map['financeSchemaVersion'] as num?)?.toInt(),
      financeMigrationStatus: map['financeMigrationStatus'] as String?,
      endDate: map['endDate'] as String? ?? '',
      daysToGo: (map['daysToGo'] as num?)?.toInt() ?? 0,
      images:
          (map['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      imageCredits: Map<String, dynamic>.from(
        map['imageCredits'] as Map? ?? {},
      ),
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
  bool isShared;
  final bool? isPrivate;
  final String? lodgingType;
  final String? hotelName;
  final String? hotelAddress;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final double? expensePerNight;
  final String? lodgingCurrencyCode;
  final int lodgingRevision;
  List<ActivityModel>? activities;
  List<ExpenseModel>? expenses;
  final String? financeCurrency;
  final int? financePrecision;
  final int? financeSchemaVersion;
  final String? financeMigrationStatus;
  bool hasLegacyExpenseRecords;
  List<FinanceExpenseModel>? financeExpenses;

  final String endDate;
  final int daysToGo;
  List<String> images;
  final Map<String, dynamic> imageCredits;

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
    bool? isShared,
    bool? isPrivate,
    String? lodgingType,
    String? hotelName,
    String? hotelAddress,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? expensePerNight,
    String? lodgingCurrencyCode,
    int? lodgingRevision,
    List<ActivityModel>? activities,
    List<ExpenseModel>? expenses,
    String? financeCurrency,
    int? financePrecision,
    int? financeSchemaVersion,
    String? financeMigrationStatus,
    bool? hasLegacyExpenseRecords,
    List<FinanceExpenseModel>? financeExpenses,
    String? endDate,
    int? daysToGo,
    List<String>? images,
    String? continent,
  }) {
    return TripModel(
      timeOffsets: timeOffsets,
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
      isShared: isShared ?? this.isShared,
      isPrivate: isPrivate ?? this.isPrivate,
      lodgingType: lodgingType ?? this.lodgingType,
      hotelName: hotelName ?? this.hotelName,
      hotelAddress: hotelAddress ?? this.hotelAddress,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      expensePerNight: expensePerNight ?? this.expensePerNight,
      lodgingCurrencyCode: lodgingCurrencyCode ?? this.lodgingCurrencyCode,
      lodgingRevision: lodgingRevision ?? this.lodgingRevision,
      activities: activities ?? this.activities,
      expenses: expenses ?? this.expenses,
      financeCurrency: financeCurrency ?? this.financeCurrency,
      financePrecision: financePrecision ?? this.financePrecision,
      financeSchemaVersion: financeSchemaVersion ?? this.financeSchemaVersion,
      financeMigrationStatus:
          financeMigrationStatus ?? this.financeMigrationStatus,
      hasLegacyExpenseRecords:
          hasLegacyExpenseRecords ?? this.hasLegacyExpenseRecords,
      financeExpenses: financeExpenses ?? this.financeExpenses,
      endDate: endDate ?? this.endDate,
      daysToGo: daysToGo ?? this.daysToGo,
      images: images ?? this.images,
      imageCredits: imageCredits,
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
      'country': country,
      'startDate': startDate.toIso8601String(),
      'joinedUsers': joinedUsers,
      'invitedUsers': invitedUsers,
      'isShared': isShared,
      'isPrivate': isPrivate,
      'lodgingType': lodgingType,
      'hotelName': hotelName,
      'hotelAddress': hotelAddress,
      'checkInDate': TravelTime.serialize(
        checkInDate,
        timeOffsets['checkInDate'],
      ),
      'checkOutDate': TravelTime.serialize(
        checkOutDate,
        timeOffsets['checkOutDate'],
      ),
      'expensePerNight': expensePerNight,
      if (lodgingCurrencyCode != null)
        'lodgingCurrencyCode': lodgingCurrencyCode,
      if (lodgingRevision > 0) 'lodgingRevision': lodgingRevision,
      'activities': activities?.map((x) => x.toMap()).toList(),
      'expenses': expenses?.map((x) => x.toMap()).toList(),
      if (financeCurrency != null) 'financeCurrency': financeCurrency,
      if (financePrecision != null) 'financePrecision': financePrecision,
      if (financeSchemaVersion != null)
        'financeSchemaVersion': financeSchemaVersion,
      'endDate': endDate,
      'daysToGo': daysToGo,
      'images': images,
      'imageCredits': imageCredits,
      'continent': continent,
    };
  }

  static List<ExpenseModel> _readLegacyExpenses(dynamic raw) {
    if (raw is! List) return [];
    final parsed = <ExpenseModel>[];
    for (final value in raw) {
      if (value is! Map<String, dynamic>) continue;
      try {
        parsed.add(ExpenseModel.fromMap(value));
      } on FormatException {
        // Original records remain in Firestore for owner review.
      } on TypeError {
        // Historical entries can have nonnumeric amounts or invalid dates.
      }
    }
    return parsed;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'TripModel(id: $id, destination: $destination, title: $title, createdBy: $createdBy, tripStartDate: $tripStartDate, tripEndDate: $tripEndDate, tripLocation: $tripLocation, country: $country, startDate: $startDate, joinedUsers: $joinedUsers, invitedUsers: $invitedUsers, isShared: $isShared, isPrivate: $isPrivate, lodgingType: $lodgingType, hotelName: $hotelName, hotelAddress: $hotelAddress, checkInDate: $checkInDate, checkOutDate: $checkOutDate, expensePerNight: $expensePerNight, activities: $activities, expenses: $expenses, endDate: $endDate, daysToGo: $daysToGo, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TripModel &&
        mapEquals(other.timeOffsets, timeOffsets) &&
        other.id == id &&
        other.destination == destination &&
        other.title == title &&
        other.createdBy == createdBy &&
        other.tripStartDate == tripStartDate &&
        other.tripEndDate == tripEndDate &&
        other.tripLocation == tripLocation &&
        other.country == country &&
        other.startDate == startDate &&
        listEquals(other.joinedUsers, joinedUsers) &&
        listEquals(other.invitedUsers, invitedUsers) &&
        other.isShared == isShared &&
        other.isPrivate == isPrivate &&
        other.lodgingType == lodgingType &&
        other.hotelName == hotelName &&
        other.hotelAddress == hotelAddress &&
        other.checkInDate == checkInDate &&
        other.checkOutDate == checkOutDate &&
        other.expensePerNight == expensePerNight &&
        other.lodgingCurrencyCode == lodgingCurrencyCode &&
        other.lodgingRevision == lodgingRevision &&
        listEquals(other.activities, activities) &&
        listEquals(other.expenses, expenses) &&
        other.endDate == endDate &&
        other.daysToGo == daysToGo &&
        listEquals(other.images, images);
  }

  @override
  int get hashCode {
    return timeOffsets['checkInDate'].hashCode ^
        timeOffsets['checkOutDate'].hashCode ^
        id.hashCode ^
        destination.hashCode ^
        title.hashCode ^
        createdBy.hashCode ^
        tripStartDate.hashCode ^
        tripEndDate.hashCode ^
        tripLocation.hashCode ^
        country.hashCode ^
        startDate.hashCode ^
        joinedUsers.hashCode ^
        invitedUsers.hashCode ^
        isShared.hashCode ^
        isPrivate.hashCode ^
        lodgingType.hashCode ^
        hotelName.hashCode ^
        hotelAddress.hashCode ^
        checkInDate.hashCode ^
        checkOutDate.hashCode ^
        expensePerNight.hashCode ^
        lodgingCurrencyCode.hashCode ^
        lodgingRevision.hashCode ^
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
