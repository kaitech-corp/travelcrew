import 'package:firebase_analytics/firebase_analytics.dart';

/// Our calls to the Firebase Analytics API.
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(analytics: _analytics);



  Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'email');
  }
  Future<void> logLoginGoogle() async {
    await _analytics.logLogin(loginMethod: 'google');
  }

  Future<void> logSignUp() async {
    await _analytics.logSignUp(signUpMethod: 'email');
  }

  Future<void> createTrip( bool created) async {
    await _analytics.logEvent(name: 'createTrip', parameters: <String, dynamic>{'did_create': created});
  }

  Future<void> createPrivateTrip( bool created) async {
    await _analytics.logEvent(name: 'createPrivateTrip', parameters: <String, dynamic>{'did_create': created});
  }
// Log Write errors
  Future<void> writeError( String error) async {
    await _analytics.logEvent(name: 'writeError', parameters: <String, dynamic>{'errorDescription': error});
  }

  Future<void> joinedTrip(bool joined) async {
    await _analytics.logEvent(name: 'joinedTrip', parameters: <String, dynamic>{'did_join': joined});
  }

  Future<void> likedTrip() async {
    await _analytics.logEvent(name: 'likedTrip');
  }
  Future<void> viewedTrip() async {
    await _analytics.logEvent(name: 'viewedTrip');
  }
}
