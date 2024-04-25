import 'package:cloud_functions/cloud_functions.dart';

class FeedbackCloudFunction {
  // Give feedback
  Future<void> giveFeedback(String message) async {
    final HttpsCallable giveFeedback =
        FirebaseFunctions.instance.httpsCallable('giveFeedback');
    giveFeedback(<String, dynamic>{
      'message': message,
    });
  }

  Future<void> feedbackData() async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('feedbackData');
    functionData(<String, dynamic>{});
  }

  Future<void> removeFeedback(String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeFeedback');
    functionData(<String, dynamic>{
      'fieldID': fieldID,
    });
  }

  Future<void> addReview({required String docID}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addReview');
    functionData(<String, dynamic>{
      'docID': docID,
    });
  }
}
