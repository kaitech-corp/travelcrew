import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/services/safety_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/views/messages/users/chat_screen.dart';
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';

class _RetryController extends UsersController {
  _RetryController() : super(fetchRooms: (_) async => []);

  int retries = 0;
  int pageRetries = 0;

  @override
  Future<void> listenToChat() async {
    retries++;
    chatOpenError.value = null;
  }

  @override
  Future<void> loadEarlierMessages() async {
    pageRetries++;
    earlierMessagesError.value = null;
  }
}

TripModel _trip() => TripModel.fromMap({
  'id': 'trip',
  'title': 'Tokyo trip',
  'createdBy': 'owner',
  'destination': 'Tokyo',
  'country': 'Japan',
  'startDate': '2027-01-01',
});

Widget _app({double textScale = 1}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder:
      (_, _) => GetMaterialApp(
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
        home: const MessagesScreen(),
      ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    GoogleFonts.config.allowRuntimeFetching = false;
    SafetyService.ready.value = true;
    GlobalVariables.loggedInUser.value = UserModel(
      uid: 'owner',
      email: 'owner@example.com',
    );
  });

  tearDown(() {
    Get.reset();
    SafetyService.ready.value = false;
    GlobalVariables.loggedInUser.value = null;
  });

  testWidgets('chat load failure shows Retry and keeps the trip context', (
    tester,
  ) async {
    final controller = Get.put<UsersController>(_RetryController());
    controller.currentTrip.value = _trip();
    controller.chatOpenError.value = 'Trip chat stopped updating.';

    await tester.pumpWidget(_app());
    await tester.pump();

    expect(find.text('Trip chat stopped updating.'), findsOneWidget);
    expect(find.text('Tokyo trip'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect((controller as _RetryController).retries, 1);
    expect(find.text('Trip chat stopped updating.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'older-message failure leaves visible messages and offers Retry',
    (tester) async {
      final controller = Get.put<UsersController>(_RetryController());
      controller.currentTrip.value = _trip();
      controller.roomId = 'trip';
      controller.chatRoom.value = ChatRoom(
        roomId: 'trip',
        updatedAt: Timestamp.now(),
        usersIds: const ['owner'],
        users: const [],
      );
      controller.messages.value = [
        ChatMessage(
          chateId: 'message',
          messageStatus: 'Sent',
          createdAt: Timestamp.now(),
          createdBy: 'owner',
          sentTo: 'trip',
          messageType: 'Text',
          data: 'Already loaded message',
        ),
      ];
      controller.hasEarlierMessages.value = true;
      controller.earlierMessagesError.value =
          'Unable to load earlier messages.';

      await tester.pumpWidget(_app());
      await tester.pump();
      expect(find.text('Already loaded message'), findsOneWidget);
      expect(find.text('Unable to load earlier messages.'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect((controller as _RetryController).pageRetries, 1);
      expect(find.text('Unable to load earlier messages.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'chat failure state stays readable and operable at phone width with 2x text',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = Get.put<UsersController>(_RetryController());
      controller.currentTrip.value = _trip();
      controller.chatOpenError.value = 'Trip chat stopped updating.';

      await tester.pumpWidget(_app(textScale: 2));
      await tester.pump();

      expect(find.text('Trip chat stopped updating.'), findsOneWidget);
      final retry = find.text('Retry');
      expect(retry, findsOneWidget);
      final semantics = tester.getSemantics(retry);
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
      final size = tester.getSize(
        find.ancestor(of: retry, matching: find.byType(InkWell)).first,
      );
      expect(size.height, greaterThanOrEqualTo(44));
      await tester.tap(retry);
      await tester.pump();
      expect((controller as _RetryController).retries, 1);
      expect(tester.takeException(), isNull, reason: 'no overflow at 2x');
    },
  );
}
