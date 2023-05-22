import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendedContent {

  RecommendedContent({
    required this.name,
    required this.clicks,
    required this.dateCreated,
    required this.docID,
    required this.urlToImage,
  });

factory RecommendedContent.fromDocument(DocumentSnapshot<Object?> doc) {
  final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
  final urlToImage = data['urlToImage'] as List<dynamic>? ?? [];
  return RecommendedContent(
    name: data['name'] as String,
    clicks: data['clicks'] as int,
    dateCreated: data['dateCreated'] as Timestamp,
    docID: data['docID'] as String,
    urlToImage: urlToImage.cast<String>(),
  );
}


  String name;
  int clicks;
  Timestamp dateCreated;
  String docID;
  List<String> urlToImage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'clicks': clicks,
      'dateCreated': dateCreated,
      'docID': docID,
      'urlToImage': urlToImage,
    };
  }
}
