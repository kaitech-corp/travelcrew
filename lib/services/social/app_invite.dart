import 'package:flutter_sms/flutter_sms.dart';
import 'package:travelcrew/services/analytics_service.dart';
import 'package:travelcrew/services/constants/constants.dart';

class AppInvite{

  Future<void> sendInvite() async{

    try{
      String _result = await sendSMS(message: "Join me on Travel Crew!\n\n Apple: $appleStore\n\n Google: $googleplay", recipients: []);
      print(_result);
    } catch (e){
      AnalyticsService().writeError(e.toString());
    }
  }


}