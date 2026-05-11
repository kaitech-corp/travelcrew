import 'package:cloud_firestore/cloud_firestore.dart';

class TripMemberModel {
  TripMemberModel({
    required this.userId,
    required this.role,
    this.status = 'active',
    this.joinedAt,
    this.invitedBy,
    this.removedAt,
  });

  factory TripMemberModel.fromMap(Map<String, dynamic> map) {
    return TripMemberModel(
      userId: map['userId'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      status: map['status'] as String? ?? 'active',
      joinedAt: _dateFromValue(map['joinedAt']),
      invitedBy: map['invitedBy'] as String?,
      removedAt: _dateFromValue(map['removedAt']),
    );
  }

  final String userId;
  final String role;
  final String status;
  final DateTime? joinedAt;
  final String? invitedBy;
  final DateTime? removedAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'role': role,
      'status': status,
      'joinedAt': FieldValue.serverTimestamp(),
      'invitedBy': invitedBy,
      'removedAt': removedAt?.toIso8601String(),
    };
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
