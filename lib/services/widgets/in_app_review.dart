import 'package:in_app_review/in_app_review.dart';

class InAppReviewClass {
  final InAppReview inAppReview = InAppReview.instance;

  Future<void> requestReviewFunc() async {
    if(await inAppReview.isAvailable()){
      inAppReview.requestReview();
    }
  }
}
