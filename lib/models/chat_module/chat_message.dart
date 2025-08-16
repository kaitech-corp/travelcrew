import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  ChatMessage({
    required this.chateId,
    required this.messageStatus,
    required this.createdAt,
    this.isLoading = false,
    required this.createdBy,
    required this.sentTo,
    required this.messageType,
    this.callTimeTaken,
    required this.data,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      chateId: map['chateId'] as String? ?? '',
      messageStatus: map['messageStatus'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp,
      createdBy: map['createdBy'] as String? ?? '',
      sentTo: map['sentTo'] as String? ?? '',
      messageType: map['messageType'] as String? ?? '',
      callTimeTaken: map['callTimeTaken']?.toInt() as int?,
      data: map['data'] as String? ?? '',
    );
  }

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source) as Map<String, dynamic>);
  String chateId;
  String messageStatus;
  Timestamp createdAt;
  String createdBy;
  String sentTo;
  String messageType;
  bool isLoading;
  int? callTimeTaken;
  String data;

  ChatMessage copyWith({
    String? chateId,
    String? messageStatus,
    Timestamp? createdAt,
    String? createdBy,
    String? sentTo,
    String? messageType,
    int? callTimeTaken,
    String? data,
  }) {
    return ChatMessage(
      chateId: chateId ?? this.chateId,
      messageStatus: messageStatus ?? this.messageStatus,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      sentTo: sentTo ?? this.sentTo,
      messageType: messageType ?? this.messageType,
      callTimeTaken: callTimeTaken ?? this.callTimeTaken,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'chateId': chateId});
    result.addAll({'messageStatus': messageStatus});
    result.addAll({'createdAt': createdAt});
    result.addAll({'createdBy': createdBy});
    result.addAll({'sentTo': sentTo});
    result.addAll({'messageType': messageType});
    if (callTimeTaken != null) {
      result.addAll({'callTimeTaken': callTimeTaken});
    }
    result.addAll({'data': data});

    return result;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'ChatMessage(chateId: $chateId, messageStatus: $messageStatus, createdAt: $createdAt, createdBy: $createdBy, sentTo: $sentTo, messageType: $messageType, callTimeTaken: $callTimeTaken, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatMessage &&
        other.chateId == chateId &&
        other.messageStatus == messageStatus &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.sentTo == sentTo &&
        other.messageType == messageType &&
        other.callTimeTaken == callTimeTaken &&
        other.data == data;
  }

  @override
  int get hashCode {
    return chateId.hashCode ^
        messageStatus.hashCode ^
        createdAt.hashCode ^
        createdBy.hashCode ^
        sentTo.hashCode ^
        messageType.hashCode ^
        callTimeTaken.hashCode ^
        data.hashCode;
  }
}

enum MessageType { Text, Audio, Audio_Call, Video_call, Image }

enum MessageStatus {
  pending('Pending'),
  sent('Sent'),
  readed('readed');

  final String status;
  const MessageStatus(this.status);
}
