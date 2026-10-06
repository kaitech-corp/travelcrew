import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/trip_invitation_service.dart';
import 'package:travel_crew/views/notification/trip_invitation_dialog.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';
import 'notifications_firebase_service.dart';

/// One navigation path for inbox taps, remote pushes and local alerts.
class NotificationNavigation {
  static Map<String, dynamic>? _pending;
  static bool _opening = false;
  static String? _readyUid;

  static void sessionReady() {
    _readyUid = GlobalVariables.currentUid;
    WidgetsBinding.instance.addPostFrameCallback((_) => flush());
  }

  static void clearSession() {
    _readyUid = null;
    _pending = null;
  }

  static void receive(Map<String, dynamic> data) {
    _pending = data;
    if (_readyUid == GlobalVariables.currentUid &&
        GlobalVariables.currentUid.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => flush());
    }
  }

  static Future<void> flush() async {
    final data = _pending;
    if (data == null ||
        GlobalVariables.currentUid.isEmpty ||
        _readyUid != GlobalVariables.currentUid ||
        _opening) {
      return;
    }
    _pending = null;
    await open(data);
  }

  static Future<void> open(Map<String, dynamic> data) async {
    if (_opening || GlobalVariables.currentUid.isEmpty) return;
    if (data['recipientUid'] != null &&
        data['recipientUid'] != GlobalVariables.currentUid) {
      return;
    }
    _opening = true;
    try {
      final uid = GlobalVariables.currentUid;
      var eventType = '';
      String? invitationId;
      var type = data['type'] as String? ?? '';
      var target = data['notificationForId'] as String? ?? '';
      final id = data['notificationId'] as String?;
      if (id != null && id.isNotEmpty) {
        final doc =
            await firestore
                .collection(kNotificationsCollection)
                .doc(GlobalVariables.currentUid)
                .collection(kNotificationsSubCollection)
                .doc(id)
                .get();
        if (uid != GlobalVariables.currentUid) return;
        final saved = doc.data();
        if (saved == null || saved['isActive'] != true) {
          showCustomSnackBar(
            content: 'This notification is no longer available.',
          );
          return;
        }
        // Read the current server-owned target, rather than trusting an old push.
        eventType = saved['eventType'] as String? ?? '';
        invitationId = saved['invitationId'] as String?;
        type = saved['notificationType'] as String? ?? '';
        target = saved['notificationForId'] as String? ?? '';
        await FirebaseNotificationsService.markNotificationAsRead(
          notificationId: id,
        );
      }
      if (type == 'Invitation') {
        if (invitationId == null) throw StateError('Invitation unavailable');
        final preview = await TripInvitationService.preview(
          target,
          invitationId,
        );
        if (uid != GlobalVariables.currentUid) return;
        final accepted = await Get.dialog<bool>(
          TripInvitationDialog(
            preview: preview,
            respond:
                (accept) => TripInvitationService.respond(
                  target,
                  invitationId!,
                  accept,
                ),
          ),
          barrierDismissible: false,
        );
        if (accepted != true || uid != GlobalVariables.currentUid) return;
        type = 'Trip';
      }
      if (type == 'Profile') {
        final profile = await AuthService.getUserPublicProfile(userId: target);
        if (profile == null) throw StateError('Profile unavailable');
        if (uid != GlobalVariables.currentUid) return;
        unawaited(Get.toNamed(kPublicProfileScreenRoute, arguments: profile));
      } else if (type == 'Trip' || type == 'Chat') {
        final trip = await FirebaseTripService.getTripById(tripId: target);
        if (uid != GlobalVariables.currentUid) return;
        if (trip != null && trip.tripStatus != 'deleted') {
          if (type == 'Chat') {
            if (!await FirebaseTripService.isTripMember(
              tripId: target,
              userId: uid,
            )) {
              throw StateError('Chat unavailable');
            }
            final controller = Get.find<UsersController>();
            controller.currentTrip.value = trip;
            await controller.listenToChat();
            unawaited(Get.toNamed(kMessagesScreenRoute));
          } else {
            unawaited(
              Get.toNamed(
                kSpecificTripViewScreenRoute,
                arguments: {
                  'trip': trip,
                  if (eventType == 'join_requested') 'section': 'Crew',
                },
              ),
            );
          }
        } else if (type == 'Trip') {
          final card =
              await firestore.collection(kTripDiscoveryTable).doc(target).get();
          if (!card.exists || card.data()?['isDiscoverable'] != true) {
            throw StateError('Trip unavailable');
          }
          if (uid != GlobalVariables.currentUid) return;
          unawaited(
            Get.toNamed(
              kSpecificTripViewScreenRoute,
              arguments: TripDiscoveryModel.fromMap(card.data()!),
            ),
          );
        } else {
          throw StateError('Chat unavailable');
        }
      } else {
        unawaited(Get.toNamed(kNotificationScreenRoute));
      }
    } catch (_) {
      showCustomSnackBar(
        content:
            'This content is no longer available or you no longer have access.',
      );
    } finally {
      _opening = false;
    }
  }
}
