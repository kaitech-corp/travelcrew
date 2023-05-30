import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/recommended_model/recommended_model.dart';

final Query<Object> recActivityCollection =
    FirebaseFirestore.instance.collection('recommended_activities').orderBy('clicks');
final Query<Object> recTripCollection =
    FirebaseFirestore.instance.collection('recommended_trips').orderBy('clicks');

Future<List<RecommendedContentModel>> getRecommendedContentModel(
    String content) async {
  final Query<Object> collection =
      content == 'trip' ? recTripCollection : recActivityCollection;
  final QuerySnapshot<Object?> snapshot = await collection.get();
  final List<RecommendedContentModel> recommendedContents = snapshot.docs
      .map((QueryDocumentSnapshot<Object?> doc) =>
          RecommendedContentModel.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
  return recommendedContents;
}

int getRandomIndex(List<dynamic> list) {
  final Random random = Random();
  final int index = random.nextInt(list.length);
  return index;
}
