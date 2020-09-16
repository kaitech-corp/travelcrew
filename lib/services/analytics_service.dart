import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(analytics: _analytics);



  Future logLogin() async {
    await _analytics.logLogin(loginMethod: 'email');
  }
  Future logLoginGoogle() async {
    await _analytics.logLogin(loginMethod: 'google');
  }

  Future logSignUp() async {
    await _analytics.logSignUp(signUpMethod: 'email');
  }
  // Future logSignUpGoogle() async {
  //   await _analytics.logSignUp(signUpMethod: 'google');
  // }
  Future createTrip( bool created) async {
    await _analytics.logEvent(name: 'createTrip', parameters: {'did_create': created});
  }

  Future createPrivateTrip( bool created) async {
    await _analytics.logEvent(name: 'createPrivateTrip', parameters: {'did_create': created});
  }
// Log Write errors
  Future writeError( String error) async {
    await _analytics.logEvent(name: 'writeError', parameters: {'errorDescription': error});
  }
}