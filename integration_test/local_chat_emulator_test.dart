import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/services/chat_firebase_service.dart';
import 'package:travel_crew/services/finance_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/private_photo_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/transportation_service.dart';
import 'package:travel_crew/services/trip_link_service.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/create_trip/create_trip_screen.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';

const _password = String.fromEnvironment('TRAVEL_CREW_LOCAL_TEST_PASSWORD');
const _tripId = 'e2e_chat';
// Created by functions/seed-local-assistant-trip.js through the real
// assistant transaction; passed with --dart-define=TRAVEL_CREW_ASSISTANT_TRIP_ID.
const _assistantTripId = String.fromEnvironment(
  'TRAVEL_CREW_ASSISTANT_TRIP_ID',
);
const _photoRef =
    'gs://universal-code-135522.appspot.com/private_uploads/e2e_owner/trip_images/e2e_chat/local-photo.png';

class _SaveProbeController extends CreateTripController {
  int attempts = 0;

  @override
  Future<void> updateTrip() {
    attempts++;
    return super.updateTrip();
  }
}

Future<void> _signIn(String email) async {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: _password,
  );
  final uid = credential.user!.uid;
  final profile = await firestore.collection('users').doc(uid).get();
  GlobalVariables.loggedInUser.value = UserModel.fromMap(profile.data()!);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    expect(useLocalFirebaseEmulators, isTrue);
    expect(_password.length, greaterThanOrEqualTo(12));
    await initializeFirebase();
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
    GlobalVariables.loggedInUser.value = null;
  });

  testWidgets('local iOS chat send and same-ID retry are idempotent', (
    tester,
  ) async {
    await _signIn('owner@example.test');
    expect(GlobalVariables.currentUid, 'e2e_owner');

    final room = await ChatFirebaseService.ensureChatRoom(roomId: _tripId);
    expect(room.usersIds, contains('e2e_owner'));
    final messageId = 'local_retry_${DateTime.now().microsecondsSinceEpoch}';
    final message = ChatMessage(
      chateId: messageId,
      messageStatus: MessageStatus.sent.status,
      createdAt: Timestamp.now(),
      createdBy: GlobalVariables.currentUid,
      sentTo: _tripId,
      messageType: MessageType.Text.name,
      data: 'Local simulator retry check',
    );
    await ChatFirebaseService.sendMessage(roomId: _tripId, chatToSave: message);
    await ChatFirebaseService.sendMessage(roomId: _tripId, chatToSave: message);
    final stored =
        await firestore
            .collection(kTripChatCollection)
            .doc(_tripId)
            .collection(kTripChatMessagesCollection)
            .doc(messageId)
            .get();
    expect(stored.exists, isTrue);
    expect(stored.data()?['data'], message.data);
    expect(stored.data()?['createdBy'], 'e2e_owner');

    await _signIn('member@example.test');
    expect(GlobalVariables.currentUid, 'e2e_member');
    final memberRoom = await ChatFirebaseService.ensureChatRoom(
      roomId: _tripId,
    );
    expect(memberRoom.usersIds, contains('e2e_member'));
    final memberRead =
        await firestore
            .collection(kTripChatCollection)
            .doc(_tripId)
            .collection(kTripChatMessagesCollection)
            .doc(messageId)
            .get();
    expect(memberRead.data()?['data'], message.data);
  });

  testWidgets('stale trip edits fail while unrelated changes merge', (
    tester,
  ) async {
    await _signIn('owner@example.test');
    final ref = firestore.collection(kTripTable).doc(_tripId);
    final original = (await ref.get()).data()!;
    final previousTitle = original['title'] as String;
    final previousDestination = original['destination'] as String;
    final otherTitle = 'Other device ${DateTime.now().microsecondsSinceEpoch}';
    try {
      await ref.update({'title': otherTitle});
      final staleSave = await FirebaseTripService.updateTrip(
        tripId: _tripId,
        data: {'title': 'Stale title'},
        expectedEditedFields: original,
      );
      expect(staleSave, isFalse);
      expect((await ref.get()).data()?['title'], otherTitle);

      final independentSave = await FirebaseTripService.updateTrip(
        tripId: _tripId,
        data: {'destination': 'Kyoto'},
        expectedEditedFields: original,
      );
      expect(independentSave, isTrue);
      final merged = (await ref.get()).data()!;
      expect(merged['title'], otherTitle);
      expect(merged['destination'], 'Kyoto');
    } finally {
      await ref.update({
        'title': previousTitle,
        'destination': previousDestination,
      });
    }
  });

  testWidgets('signed-in private photo loads and removal revokes access', (
    tester,
  ) async {
    final trip = firestore.collection(kTripTable).doc(_tripId);
    await _signIn('owner@example.test');
    final ownerPhoto = await PrivatePhotoService.load(_photoRef);
    expect(ownerPhoto, isNotEmpty);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnyImageView(
            url: _photoRef,
            width: 40,
            height: 40,
            errorWidget: Text('Private photo failed'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Private photo failed'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is MemoryImage,
      ),
      findsOneWidget,
    );
    await _signIn('member@example.test');
    final memberPhoto = await PrivatePhotoService.load(_photoRef);
    expect(memberPhoto, ownerPhoto);

    await _signIn('owner@example.test');
    try {
      await trip.update({'images': <String>[]});
      await expectLater(
        PrivatePhotoService.load(_photoRef),
        throwsA(isA<StateError>()),
      );
    } finally {
      await trip.update({
        'images': [_photoRef],
      });
    }
  });

  testWidgets(
    'an assistant-created trip opens from its app link and reloads every section',
    (tester) async {
      expect(
        _assistantTripId,
        isNotEmpty,
        reason: 'Pass --dart-define=TRAVEL_CREW_ASSISTANT_TRIP_ID',
      );
      expect(
        tripIdFromLink(Uri.parse('travelcrew://trips/$_assistantTripId')),
        _assistantTripId,
      );
      expect(
        tripIdFromLink(Uri.parse('travelcrew://trips/$_assistantTripId?x=1')),
        isNull,
      );

      await _signIn('owner@example.test');
      expect(
        await FirebaseTripService.isTripMember(
          tripId: _assistantTripId,
          userId: GlobalVariables.currentUid,
        ),
        isTrue,
      );
      final trip = await FirebaseTripService.getTripById(
        tripId: _assistantTripId,
      );
      expect(trip, isNotNull);
      expect(trip!.destination, 'Kyoto');
      expect(trip.isPrivate, true);
      expect(trip.hotelName, 'Ryokan by the river');
      expect(trip.latitude, 0);
      expect(trip.longitude, 0);

      final activities = await FirebaseTripService.getTripActivities(
        tripId: _assistantTripId,
      );
      expect(
        activities.map((activity) => activity.title),
        containsAll(['Fushimi Inari at dawn', 'Kaiseki dinner']),
      );
      final transportation =
          await TransportationService.watch(_assistantTripId).first;
      expect(
        transportation.map((entry) => entry.mode.name),
        containsAll(['flight', 'train']),
      );
      final flight = transportation.firstWhere(
        (entry) => entry.mode.name == 'flight',
      );
      expect(flight.departure, '2027-05-01T10:15:00');
      expect(flight.arrival, '2027-05-02T14:05:00');
      final expenses = await FinanceService.getExpenses(_assistantTripId);
      expect(expenses.single.amountMinor, 128000);
      expect(expenses.single.currencyCode, 'JPY');

      // A signed-in traveler who is not a member sees nonmember, not a
      // read failure, because they may read their own membership record.
      await _signIn('member@example.test');
      expect(
        await FirebaseTripService.isTripMember(
          tripId: _assistantTripId,
          userId: GlobalVariables.currentUid,
        ),
        isFalse,
      );
    },
  );

  testWidgets(
    'the edit screen keeps a conflicting edit and saves an unrelated one',
    (tester) async {
      await _signIn('owner@example.test');
      final ref = firestore.collection(kTripTable).doc(_tripId);
      final before = (await ref.get()).data()!;
      final previousTitle = before['title'] as String;
      final previousHotel = before['hotelName'];
      final otherTitle =
          'Other device ${DateTime.now().microsecondsSinceEpoch}';
      // Snackbars need Get.context, which GetMaterialApp provides only
      // outside test mode.
      final controller =
          Get.put<CreateTripController>(_SaveProbeController())
              as _SaveProbeController;
      addTearDown(Get.reset);
      final trip = await FirebaseTripService.getTripById(tripId: _tripId);
      expect(trip, isNotNull);
      try {
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            builder:
                (_, _) => GetMaterialApp(
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: const Scaffold(),
                  getPages: [
                    GetPage(
                      name: '/edit',
                      page: () => const CreateTripScreen(),
                    ),
                    GetPage(
                      name: kSpecificTripViewScreenRoute,
                      page:
                          () => const Scaffold(
                            body: Center(child: Text('Saved trip opened')),
                          ),
                    ),
                  ],
                ),
          ),
        );
        Get.toNamed('/edit', arguments: trip);
        await tester.pumpAndSettle();

        // Another writer changes the title while this editor also edits it.
        controller.tripNameController.text = 'Simulator title edit';
        await ref.update({'title': otherTitle});
        await tester.tap(find.byType(CustomElevatedButton));
        for (var i = 0; i < 40 && controller.isSaving.value; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        await tester.pump(const Duration(milliseconds: 300));
        expect(controller.isSaving.value, isFalse);
        expect(find.text('Please enter destination'), findsNothing);
        expect(controller.attempts, 1, reason: 'the real save path ran');
        // The conflict message itself is covered by trip_editor_test; the
        // integration binding gives GetX no overlay context for snackbars.
        // Preserved edits, the other writer's value and no navigation prove
        // the rejected save here.
        expect(controller.tripNameController.text, 'Simulator title edit');
        expect((await ref.get()).data()?['title'], otherTitle);
        expect(find.text('Saved trip opened'), findsNothing);

        // Reverting the overlapping field and changing an unrelated one
        // merges with the other writer's change.
        controller.tripNameController.text = previousTitle;
        controller.hotelNameController.text = 'Simulator hotel';
        await tester.pumpAndSettle(const Duration(seconds: 6));
        await tester.tap(find.byType(CustomElevatedButton));
        for (var i = 0; i < 60 && controller.isSaving.value; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        await tester.pumpAndSettle(const Duration(seconds: 3));
        final merged = (await ref.get()).data()!;
        expect(controller.attempts, 2);
        expect(merged['title'], otherTitle);
        expect(merged['hotelName'], 'Simulator hotel');
        expect(find.text('Saved trip opened'), findsOneWidget);
      } finally {
        // Trip-level lodging fields are revisioned by the rules.
        await firestore.runTransaction((transaction) async {
          final current = await transaction.get(ref);
          final revision = (current.data()?['lodgingRevision'] as int?) ?? 0;
          transaction.update(ref, {
            'title': previousTitle,
            'hotelName': previousHotel,
            'lodgingRevision': revision + 1,
          });
        });
      }
    },
  );
}
