import 'package:cloud_firestore/cloud_firestore.dart';

class FeedModel {

  FeedModel({
    required this.dateCreated,
    required this.docID,
    required this.message,
    required this.tripID,
  });

  factory FeedModel.fromMap(Map<String, dynamic> map) {
    return FeedModel(
      dateCreated: map['dateCreated'] as Timestamp,
      docID: map['docID'] as String,
      message: map['message'] as String,
      tripID: map['tripID'] as String,
    );
  }
  final Timestamp dateCreated;
  final String docID;
  final String message;
  final String tripID;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateCreated': dateCreated,
      'docID': docID,
      'message': message,
      'tripID': tripID,
    };
  }
}
