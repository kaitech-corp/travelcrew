import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_crew/models/trip_model.dart';

class TripDiscoveryModel {
  TripDiscoveryModel({
    required this.id,
    required this.destination,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.images,
    required this.createdBy,
    this.title,
    this.continent = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.tripStartDate,
    this.tripEndDate,
    this.memberCount = 0,
    this.favouriteCount = 0,
    this.creatorDisplayName,
    this.creatorProfileImage,
    this.tripStatus,
    this.isDiscoverable = true,
    this.updatedAt,
  });

  factory TripDiscoveryModel.fromMap(Map<String, dynamic> map) {
    return TripDiscoveryModel(
      id: map['id'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      country: map['country'] as String? ?? '',
      startDate: _dateFromValue(map['startDate']) ?? DateTime.now(),
      endDate: map['endDate'] as String? ?? '',
      images:
          (map['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      createdBy: map['createdBy'] as String? ?? '',
      title: map['title'] as String?,
      continent: map['continent'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      tripStartDate: _dateFromValue(map['tripStartDate']),
      tripEndDate: _dateFromValue(map['tripEndDate']),
      memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
      favouriteCount: (map['favouriteCount'] as num?)?.toInt() ?? 0,
      creatorDisplayName: map['creatorDisplayName'] as String?,
      creatorProfileImage: map['creatorProfileImage'] as String?,
      tripStatus: map['tripStatus'] as String?,
      isDiscoverable: map['isDiscoverable'] as bool? ?? true,
      updatedAt: _dateFromValue(map['updatedAt']),
    );
  }

  factory TripDiscoveryModel.fromTrip(
    TripModel trip, {
    String? creatorDisplayName,
    String? creatorProfileImage,
  }) {
    final memberIds = <String>{trip.createdBy, ...?trip.joinedUsers}
      ..removeWhere((id) => id.isEmpty);
    return TripDiscoveryModel(
      id: trip.id,
      destination: trip.destination,
      country: trip.country,
      startDate: trip.startDate,
      endDate: trip.endDate,
      images: trip.images,
      createdBy: trip.createdBy,
      title: trip.title,
      continent: trip.continent,
      latitude: trip.latitude,
      longitude: trip.longitude,
      tripStartDate: trip.tripStartDate,
      tripEndDate: trip.tripEndDate,
      memberCount: memberIds.length,
      favouriteCount: trip.favouriteCount,
      creatorDisplayName: creatorDisplayName ?? trip.createdByUser?.displayName,
      creatorProfileImage:
          creatorProfileImage ?? trip.createdByUser?.profileImage,
      tripStatus: trip.tripStatus,
      isDiscoverable:
          trip.isPrivate != true && trip.tripStatus != TripStatus.deleted.name,
      updatedAt: DateTime.now(),
    );
  }

  final String id;
  final String destination;
  final String country;
  final DateTime startDate;
  final String endDate;
  final List<String> images;
  final String createdBy;
  final String? title;
  final String continent;
  final double latitude;
  final double longitude;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final int memberCount;
  final int favouriteCount;
  final String? creatorDisplayName;
  final String? creatorProfileImage;
  final String? tripStatus;
  final bool isDiscoverable;
  final DateTime? updatedAt;

  DateTime get effectiveStartDate => tripStartDate ?? startDate;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'destination': destination,
      'country': country,
      'continent': continent,
      'latitude': latitude,
      'longitude': longitude,
      'tripStartDate': tripStartDate?.toIso8601String(),
      'tripEndDate': tripEndDate?.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate,
      'images': images,
      'memberCount': memberCount,
      'favouriteCount': favouriteCount,
      'createdBy': createdBy,
      'creatorDisplayName': creatorDisplayName,
      'creatorProfileImage': creatorProfileImage,
      'tripStatus': tripStatus,
      'isDiscoverable': isDiscoverable,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TripModel toPreviewTripModel() {
    return TripModel(
      id: id,
      destination: destination,
      createdBy: createdBy,
      country: country,
      startDate: startDate,
      endDate: endDate,
      daysToGo: _calendarDaysUntil(effectiveStartDate),
      images: images,
      title: title,
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      favouriteCount: favouriteCount,
      tripStatus: tripStatus,
      joinedUsers: const [],
      isPrivate: false,
      continent: continent,
    );
  }

  String toJson() => json.encode(toMap());

  static DateTime? _dateFromValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  static int _calendarDaysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.difference(today).inDays;
  }
}
