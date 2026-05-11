import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRequestModel {
  JoinRequestModel({
    required this.userId,
    required this.tripId,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.message,
    this.reviewedBy,
    this.reviewedAt,
  });

  factory JoinRequestModel.fromMap(Map<String, dynamic> map) {
    return JoinRequestModel(
      userId: map['userId'] as String? ?? '',
      tripId: map['tripId'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
      message: map['message'] as String?,
      reviewedBy: map['reviewedBy'] as String?,
      reviewedAt: _dateFromValue(map['reviewedAt']),
    );
  }

  final String userId;
  final String tripId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? message;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'tripId': tripId,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'message': message,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
