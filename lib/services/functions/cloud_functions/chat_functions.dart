import 'package:cloud_functions/cloud_functions.dart';

class ChatCloudFunction {
    Future<void> deleteChatMessage(
      {required String tripDocID, required String fieldID}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('deleteChatMessage');
    functionData(<String, dynamic>{
      'tripDocID': tripDocID,
      'fieldID': fieldID,
    });
  }
}
