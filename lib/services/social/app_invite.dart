import 'package:flutter/foundation.dart';
import 'package:flutter_sms/flutter_sms.dart';
import '../analytics_service.dart';
import '../constants/constants.dart';

class AppInvite{

  Future<void> sendInvite() async{

    try{
      String result = await sendSMS(message: 'Join me on Travel Crew!\n\n Apple: $appleStore\n\n Google: $googleplay', recipients: <String>[]);
      if (kDebugMode) {
        print(result);
      }
    } catch (e){
      AnalyticsService().writeError(e.toString());
    }
  }
}
