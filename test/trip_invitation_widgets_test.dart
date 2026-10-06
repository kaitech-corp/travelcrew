import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/trip_invitation_service.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/invite_travelers_dialog.dart';
import 'package:travel_crew/views/notification/trip_invitation_dialog.dart';

Future<void> openDialog(WidgetTester tester, Widget dialog) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder:
            (context) => Scaffold(
              body: TextButton(
                onPressed:
                    () => showDialog<void>(
                      context: context,
                      builder: (_) => dialog,
                    ),
                child: const Text('Open'),
              ),
            ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'typing and backspacing wait for a pause without blocking the input',
    (tester) async {
      final queries = <String>[];
      final pending = Completer<List<TripInviteUser>>();
      await openDialog(
        tester,
        InviteTravelersDialog(
          search: (query) {
            queries.add(query);
            return pending.future;
          },
          send: (_, _) async {},
          sendEmail: (_) async => true,
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      final original = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      Future<void> edit(String text) async {
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          ),
        );
        await tester.pump();
        expect(original.widget.controller.text, text);
        expect(original.widget.focusNode.hasFocus, isTrue);
      }

      for (final value in ['Al', 'Ali', 'Alic', 'Alice']) {
        await edit(value);
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(queries, isEmpty);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      expect(queries, ['Alice']);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      for (final value in ['Alic', 'Ali', 'Al', 'A']) {
        await edit(value);
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pump(const Duration(milliseconds: 700));
      expect(queries, ['Alice']);
      pending.complete([
        const TripInviteUser(uid: 'alice', displayName: 'Alice'),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
      expect(
        tester.state<EditableTextState>(find.byType(EditableText)),
        same(original),
      );
      expect(original.widget.focusNode.hasFocus, isTrue);
    },
  );

  testWidgets(
    'clear search cancels a scheduled lookup and keeps the keyboard focused',
    (tester) async {
      final queries = <String>[];
      await openDialog(
        tester,
        InviteTravelersDialog(
          search: (query) async {
            queries.add(query);
            return [];
          },
          send: (_, _) async {},
          sendEmail: (_) async => true,
        ),
      );
      await tester.enterText(find.byType(TextField), 'Alice');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump(const Duration(milliseconds: 700));
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.controller.text, isEmpty);
      expect(field.focusNode.hasFocus, isTrue);
      expect(queries, isEmpty);
      expect(find.text('Enter at least 2 characters.'), findsOneWidget);
    },
  );

  testWidgets('search errors and subsequent edits preserve keyboard focus', (
    tester,
  ) async {
    await openDialog(
      tester,
      InviteTravelersDialog(
        search: (_) async => throw Exception('offline'),
        send: (_, _) async {},
        sendEmail: (_) async => true,
      ),
    );
    await tester.enterText(find.byType(TextField), 'Alice');
    final original = tester.state<EditableTextState>(find.byType(EditableText));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(
      tester.state<EditableTextState>(find.byType(EditableText)),
      same(original),
    );
    expect(original.widget.focusNode.hasFocus, isTrue);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'Alic',
        selection: TextSelection.collapsed(offset: 4),
      ),
    );
    await tester.pump();
    expect(
      tester.state<EditableTextState>(find.byType(EditableText)),
      same(original),
    );
    expect(original.widget.focusNode.hasFocus, isTrue);
    expect(original.widget.controller.text, 'Alic');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  });

  testWidgets('invitation search fits a small screen with the keyboard open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await openDialog(
      tester,
      InviteTravelersDialog(
        search: (_) async => [],
        send: (_, _) async {},
        sendEmail: (_) async => true,
      ),
    );
    await tester.enterText(find.byType(TextField), 'Al');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'recipient sees a failed response and can retry without closing',
    (tester) async {
      var attempts = 0;
      await openDialog(
        tester,
        TripInvitationDialog(
          preview: const {
            'title': 'Private trip',
            'destination': 'Tokyo',
            'inviterName': 'Owner',
            'status': 'pending',
          },
          respond: (_) async {
            if (++attempts == 1) throw Exception('offline');
          },
        ),
      );
      await tester.tap(find.text('Accept invitation'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not complete this request. Please try again.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Accept invitation'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.byType(TripInvitationDialog), findsNothing);
    },
  );

  testWidgets(
    'search ignores stale responses and prevents inviting current members or pending invitees',
    (tester) async {
      final first = Completer<List<TripInviteUser>>();
      await openDialog(
        tester,
        InviteTravelersDialog(
          search:
              (query) async =>
                  query == 'Al'
                      ? first.future
                      : [
                        const TripInviteUser(uid: 'bob', displayName: 'Bob'),
                        const TripInviteUser(
                          uid: 'ben',
                          displayName: 'Ben',
                          status: 'member',
                        ),
                        const TripInviteUser(
                          uid: 'bea',
                          displayName: 'Bea',
                          status: 'invited',
                        ),
                      ],
          send: (_, _) async {},
          sendEmail: (_) async => true,
        ),
      );
      await tester.enterText(find.byType(TextField), 'Al');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.enterText(find.byType(TextField), 'Bo');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      first.complete([
        const TripInviteUser(uid: 'alice', displayName: 'Alice'),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
      expect(find.text('Bob'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'In crew'))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Invited'))
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets(
    'failed invitations retry with the same request ID and successful sends disable the button',
    (tester) async {
      final attempts = <String>[];
      await openDialog(
        tester,
        InviteTravelersDialog(
          search:
              (_) async => [
                const TripInviteUser(uid: 'alice', displayName: 'Alice'),
              ],
          send: (uid, requestId) async {
            expect(uid, 'alice');
            attempts.add(requestId);
            if (attempts.length == 1) throw Exception('offline');
          },
          sendEmail: (_) async => true,
        ),
      );
      await tester.enterText(find.byType(TextField), 'Al');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Invite'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not complete this request. Please try again.'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Invite'));
      await tester.pumpAndSettle();
      expect(attempts.length, 2);
      expect(attempts[0], attempts[1]);
      expect(find.text('Invitation sent to Alice.'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Invited'))
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets('email remains available with validation and failure feedback', (
    tester,
  ) async {
    final emails = <String>[];
    await openDialog(
      tester,
      InviteTravelersDialog(
        search: (_) async => [],
        send: (_, _) async {},
        sendEmail: (email) async {
          emails.add(email);
          return true;
        },
      ),
    );
    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'invalid');
    await tester.tap(find.text('Send email invite'));
    await tester.pumpAndSettle();
    expect(emails, isEmpty);
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), ' friend@example.com ');
    await tester.tap(find.text('Send email invite'));
    await tester.pumpAndSettle();
    expect(emails, ['friend@example.com']);
    expect(
      find.text('Email invitation queued for friend@example.com.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'search failure is visible and closing before a search completes is safe',
    (tester) async {
      final result = Completer<List<TripInviteUser>>();
      await openDialog(
        tester,
        InviteTravelersDialog(
          search: (_) => result.future,
          send: (_, _) async {},
          sendEmail: (_) async => true,
        ),
      );
      await tester.enterText(find.byType(TextField), 'Al');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      result.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  for (final accept in [true, false]) {
    testWidgets(
      'recipient can ${accept ? 'accept' : 'decline'} and repeat taps are blocked while saving',
      (tester) async {
        final saved = Completer<void>();
        final answers = <bool>[];
        await openDialog(
          tester,
          TripInvitationDialog(
            preview: const {
              'title': 'Private trip',
              'destination': 'Tokyo',
              'inviterName': 'Owner',
              'status': 'pending',
            },
            respond: (value) {
              answers.add(value);
              return saved.future;
            },
          ),
        );
        await tester.tap(find.text(accept ? 'Accept invitation' : 'Decline'));
        await tester.pump();
        await tester.tap(find.text(accept ? 'Accept invitation' : 'Decline'));
        await tester.pump();
        expect(answers, [accept]);
        saved.complete();
        await tester.pumpAndSettle();
        expect(find.byType(TripInvitationDialog), findsNothing);
      },
    );
  }
}
