import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

/// Our calls to the Firebase Analytics API.
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

  Future joinedTrip(bool joined) async {
    await _analytics.logEvent(name: 'joinedTrip', parameters: {'did_join': joined});
  }

  Future likedTrip() async {
    await _analytics.logEvent(name: 'likedTrip');
  }
  Future viewedTrip() async {
    await _analytics.logEvent(name: 'viewedTrip');
  }

  Future createActivity( bool created) async {
    await _analytics.logEvent(name: 'createActivity', parameters: {'did_create': created});
  }

  Future createLodging( bool created) async {
    await _analytics.logEvent(name: 'createLodging', parameters: {'did_create': created});
  }

  Future createTransportation( bool created) async {
    await _analytics.logEvent(name: 'createTransportation', parameters: {'did_create': created});
  }
}
