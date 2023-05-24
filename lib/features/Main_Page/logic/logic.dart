import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../../models/recommended_model/recommended_model.dart';

final CollectionReference<Object?> recActivityCollection =
    FirebaseFirestore.instance.collection('recommended_activities');
final CollectionReference<Object?> recTripCollection =
    FirebaseFirestore.instance.collection('recommended_trips');

Future<List<RecommendedContentModel>> getRecommendedContentModel(
    String content) async {
  final CollectionReference<Object?> collection =
      content == 'trip' ? recTripCollection : recActivityCollection;
  final QuerySnapshot<Object?> docs = await collection.get();
  final List<RecommendedContentModel> recommendedContents = docs.docs
      .map((QueryDocumentSnapshot<Object?> doc) =>
          RecommendedContentModel.fromJson(doc as Map<String, Object>))
      .toList();
  return recommendedContents;
}

int getRandomIndex(List<dynamic> list) {
  final Random random = Random();
  final int index = random.nextInt(list.length);
  return index;
}
