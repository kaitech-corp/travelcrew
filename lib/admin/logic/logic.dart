   import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/feedback_model/feedback_model.dart';

final CollectionReference<Object?> feedbackCollection =
      FirebaseFirestore.instance.collection('feedback');
 
  /// Feedback Data stream snapshot
  List<FeedbackModel> _feedbackSnapshot(QuerySnapshot<Object?> snapshot) {
    final List<FeedbackModel> feedback =
        snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
      return FeedbackModel.fromJson(doc as Map<String, Object>);
    }).toList();
    feedback.sort(
        (FeedbackModel a, FeedbackModel b) => b.timestamp!.compareTo(a.timestamp!));

    return feedback;
  }

  ///Stream Feedback data
  Stream<List<FeedbackModel>> get feedbackStream {
    return feedbackCollection.snapshots().map(_feedbackSnapshot);
  }
