import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/trip_model.dart';

class UserNotificationModel {
  UserNotificationModel({
    required this.notificationId,
    required this.notificationMessage,

    this.isLoading = false,
    this.addedBy,

    this.notificationStatus = '',
    required this.notificationTitle,
    this.trip,
    required this.notificationType,
    required this.createdAt,
    this.releaseDate,
    required this.createdBy,
    required this.notificationForId,
    required this.updateAt,
    required this.updateBy,
    required this.sentTo,
    required this.isTopic,
    required this.notificationTopic,
    required this.isActive,
  });

  String notificationId;
  String notificationMessage;
  String notificationTitle;
  String notificationType;
  DateTime createdAt;
  TripModel? trip;
  PublicUserModel? addedBy;
  String? releaseDate;
  String createdBy;
  String notificationForId;
  DateTime updateAt;
  String updateBy;
  List<String> sentTo;
  bool isTopic;
  bool isLoading;
  String notificationStatus;
  List<dynamic> notificationTopic;
  bool isActive;

  bool get isRead => notificationStatus == NotificationStatus.read.name;
  bool get isUnread =>
      notificationStatus.isEmpty ||
      notificationStatus == NotificationStatus.unread.name;

  factory UserNotificationModel.fromMap(Map<String, dynamic> map) {
    return UserNotificationModel(
      notificationId: (map['notificationId'] as String?) ?? '',
      notificationStatus:
          (map['notificationStatus'] as String?) ??
          NotificationStatus.unread.name,
      notificationMessage: (map['notificationMessage'] as String?) ?? '',
      notificationTitle: (map['notificationTitle'] as String?) ?? '',
      notificationType: (map['notificationType'] as String?) ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as int?) ?? 0,
      ),
      releaseDate: map['releaseDate'] as String?,
      createdBy: (map['createdBy'] as String?) ?? '',
      notificationForId: (map['notificationForId'] as String?) ?? '',
      updateAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updateAt'] as int?) ?? 0,
      ),
      updateBy: (map['updateBy'] as String?) ?? '',
      sentTo: List<String>.from(
        (map['sentTo'] as List<dynamic>?) ?? <dynamic>[],
      ),
      isTopic: (map['isTopic'] as bool?) ?? false,
      notificationTopic: List<dynamic>.from(
        (map['notificationTopic'] as List<dynamic>?) ?? <dynamic>[],
      ),
      isActive: (map['isActive'] as bool?) ?? false,
    );
  }

  factory UserNotificationModel.fromJson(String source) =>
      UserNotificationModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  UserNotificationModel copyWith({
    String? notificationId,
    String? notificationMessage,
    String? notificationTitle,
    String? notificationType,
    DateTime? createdAt,
    String? releaseDate,
    String? createdBy,
    String? notificationStatus,
    String? notificationForId,
    DateTime? updateAt,
    String? updateBy,
    List<String>? sentTo,
    bool? isTopic,
    List<dynamic>? notificationTopic,
    bool? isActive,
  }) {
    return UserNotificationModel(
      notificationId: notificationId ?? this.notificationId,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationType: notificationType ?? this.notificationType,
      createdAt: createdAt ?? this.createdAt,
      releaseDate: releaseDate ?? this.releaseDate,
      createdBy: createdBy ?? this.createdBy,
      notificationForId: notificationForId ?? this.notificationForId,
      updateAt: updateAt ?? this.updateAt,
      updateBy: updateBy ?? this.updateBy,
      sentTo: sentTo ?? this.sentTo,
      isTopic: isTopic ?? this.isTopic,
      notificationTopic: notificationTopic ?? this.notificationTopic,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'notificationStatus': notificationStatus});
    result.addAll({'notificationId': notificationId});
    result.addAll({'notificationMessage': notificationMessage});
    result.addAll({'notificationTitle': notificationTitle});
    result.addAll({'notificationType': notificationType});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    if (releaseDate != null) {
      result.addAll({'releaseDate': releaseDate});
    }
    result.addAll({'createdBy': createdBy});
    result.addAll({'notificationForId': notificationForId});
    result.addAll({'updateAt': updateAt.millisecondsSinceEpoch});
    result.addAll({'updateBy': updateBy});
    result.addAll({'sentTo': sentTo});
    result.addAll({'isTopic': isTopic});
    result.addAll({'notificationTopic': notificationTopic});
    result.addAll({'isActive': isActive});

    return result;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UserNotificationModel(notificationId: $notificationId, notificationMessage: $notificationMessage, notificationTitle: $notificationTitle, notificationType: $notificationType, createdAt: $createdAt, releaseDate: $releaseDate, createdBy: $createdBy, notificationForId: $notificationForId, updateAt: $updateAt, updateBy: $updateBy, sentTo: $sentTo, isTopic: $isTopic, notificationTopic: $notificationTopic, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserNotificationModel &&
        other.notificationId == notificationId &&
        other.notificationMessage == notificationMessage &&
        other.notificationTitle == notificationTitle &&
        other.notificationType == notificationType &&
        other.createdAt == createdAt &&
        other.releaseDate == releaseDate &&
        other.createdBy == createdBy &&
        other.notificationForId == notificationForId &&
        other.updateAt == updateAt &&
        other.updateBy == updateBy &&
        listEquals(other.sentTo, sentTo) &&
        other.isTopic == isTopic &&
        listEquals(other.notificationTopic, notificationTopic) &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return notificationId.hashCode ^
        notificationMessage.hashCode ^
        notificationTitle.hashCode ^
        notificationType.hashCode ^
        createdAt.hashCode ^
        releaseDate.hashCode ^
        createdBy.hashCode ^
        notificationForId.hashCode ^
        updateAt.hashCode ^
        updateBy.hashCode ^
        sentTo.hashCode ^
        isTopic.hashCode ^
        notificationTopic.hashCode ^
        isActive.hashCode;
  }
}

enum NotificationType {
  trip('Trip'),
  news('News');

  final String status;
  const NotificationType(this.status);
}

enum NotificationStatus { read, unread, all, accepted, rejected }
