
  import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/feed_model/feed_model.dart';

final CollectionReference<Object?> feedCollection =
      FirebaseFirestore.instance.collection('feed');

  /// Get Feed
  Stream<List<FeedModel>> getFeed() async* {
    final QuerySnapshot<Object?> ref =
        await feedCollection.orderBy('dateCreated', descending: true).get();

    final List<FeedModel> feedModels = <FeedModel>[];
    for (final QueryDocumentSnapshot<Object?> doc in ref.docs) {
      // feedModels.add(FeedModel.fromMap(doc.data() as Map<String, Object>));
    }

    yield feedModels;
  }
