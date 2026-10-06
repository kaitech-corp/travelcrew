import 'package:cloud_functions/cloud_functions.dart';

class TripInviteUser {
  const TripInviteUser({
    required this.uid,
    required this.displayName,
    this.hometown = '',
    this.status = 'available',
  });
  final String uid;
  final String displayName;
  final String hometown;
  final String status;

  factory TripInviteUser.fromMap(Map<String, dynamic> data) => TripInviteUser(
    uid: data['uid'] as String,
    displayName: data['displayName'] as String? ?? 'Traveler',
    hometown: data['hometown'] as String? ?? '',
    status: data['status'] as String? ?? 'available',
  );
}

class TripInvitationService {
  static Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final result = await FirebaseFunctions.instance
        .httpsCallable(name)
        .call(data);
    return Map<String, dynamic>.from(result.data as Map);
  }

  static Future<List<TripInviteUser>> search(
    String tripId,
    String query,
  ) async {
    final data = await _call('searchTripInviteUsersV3', {
      'tripId': tripId,
      'query': query,
    });
    return (data['users'] as List)
        .map(
          (user) =>
              TripInviteUser.fromMap(Map<String, dynamic>.from(user as Map)),
        )
        .toList();
  }

  static Future<void> send(
    String tripId,
    String userId,
    String requestId,
  ) async {
    await _call('inviteTripUserV3', {
      'tripId': tripId,
      'userId': userId,
      'requestId': requestId,
    });
  }

  static Future<Map<String, dynamic>> preview(
    String tripId,
    String invitationId,
  ) => _call('getTripInvitationV3', {
    'tripId': tripId,
    'invitationId': invitationId,
  });

  static Future<void> respond(
    String tripId,
    String invitationId,
    bool accept,
  ) async {
    await _call('respondToTripInvitationV3', {
      'tripId': tripId,
      'invitationId': invitationId,
      'accept': accept,
    });
  }

  static String errorMessage(Object error) {
    if (error is FirebaseFunctionsException &&
        {
          'permission-denied',
          'failed-precondition',
          'already-exists',
          'invalid-argument',
          'not-found',
        }.contains(error.code)) {
      return error.message ?? 'This invitation is unavailable.';
    }
    return 'Could not complete this request. Please try again.';
  }
}
