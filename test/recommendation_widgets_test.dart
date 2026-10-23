import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/recommendation_service.dart';
import 'package:travel_crew/services/safety_service.dart';
import 'package:travel_crew/views/home_page/widgets/recommendation_feed.dart';
import 'package:travel_crew/views/home_page/widgets/recommendation_impression.dart';

import 'recommendation_service_test.dart' show page;

void main() {
  setUp(() {
    SafetyService.ready.value = true;
    SafetyService.blockedIds.clear();
  });

  testWidgets(
    'only a half-visible card dwelling for a full second records an impression',
    (tester) async {
      final viewport = GlobalKey();
      final scroll = ScrollController();
      final seen = <String>[];
      Widget card(String id) => RecommendationImpression(
        key: ValueKey(id),
        viewportKey: viewport,
        active: true,
        onImpression: () => seen.add(id),
        child: SizedBox(height: 200, child: Text(id)),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                key: viewport,
                height: 300,
                width: 300,
                child: ListView(
                  controller: scroll,
                  children: [
                    card('first'),
                    const SizedBox(height: 500),
                    card('offscreen'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 900));
      expect(seen, isEmpty);
      await tester.pump(const Duration(milliseconds: 100));
      expect(seen, ['first']);
      await tester.pump(const Duration(seconds: 2));
      expect(seen, ['first']);
      scroll.jumpTo(600);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));
      expect(seen, ['first', 'offscreen']);
      await tester.pumpWidget(const SizedBox());
      scroll.dispose();
    },
  );

  testWidgets(
    'inactive tabs, background state and covered routes cannot finish a dwell',
    (tester) async {
      final viewport = GlobalKey();
      final active = ValueNotifier(false);
      final nav = GlobalKey<NavigatorState>();
      var impressions = 0;
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: nav,
          home: Scaffold(
            body: SizedBox(
              key: viewport,
              height: 300,
              width: 300,
              child: ValueListenableBuilder<bool>(
                valueListenable: active,
                builder:
                    (_, value, _) => RecommendationImpression(
                      viewportKey: viewport,
                      active: value,
                      onImpression: () => impressions++,
                      child: const SizedBox(height: 200),
                    ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(impressions, 0);
      active.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 2));
      expect(impressions, 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 200));
      unawaited(
        nav.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Trip details')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(impressions, 0);
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));
      expect(impressions, 1);
      await tester.pumpWidget(const SizedBox());
      active.dispose();
    },
  );

  testWidgets('brief visibility and below-half cards do not count', (
    tester,
  ) async {
    final viewport = GlobalKey();
    final scroll = ScrollController();
    var seen = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            key: viewport,
            height: 300,
            width: 300,
            child: ListView(
              controller: scroll,
              children: [
                const SizedBox(height: 250),
                RecommendationImpression(
                  viewportKey: viewport,
                  active: true,
                  onImpression: () => seen++,
                  child: const SizedBox(height: 200),
                ),
                const SizedBox(height: 600),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(seen, 0);
    scroll.jumpTo(200);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    scroll.jumpTo(500);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(seen, 0);
    scroll.jumpTo(200);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    expect(seen, 1);
    await tester.pumpWidget(const SizedBox());
    scroll.dispose();
  });

  for (final size in [const Size(390, 844), const Size(820, 1180)]) {
    testWidgets(
      'feed keeps ranked cards during pagination and hides blocked creators at $size',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final next = Completer<Map<String, dynamic>>();
        var calls = 0;
        final service = RecommendationService(
          currentUid: () => 'viewer',
          call: (name, _) async {
            if (name != 'getRecommendedTripsV3') return {'results': []};
            return ++calls == 1
                ? page(['z-first', 'a-second'], cursor: 'next')
                : next.future;
          },
        );
        await service.load();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationFeed(
                service: service,
                active: false,
                cardBuilder:
                    (_, trip) => SizedBox(height: 100, child: Text(trip.id)),
              ),
            ),
          ),
        );
        final first = tester.getTopLeft(find.text('z-first'));
        final second = tester.getTopLeft(find.text('a-second'));
        expect(
          size.width >= 720 ? first.dx < second.dx : first.dy < second.dy,
          true,
        );
        await tester.tap(find.text('Load more'));
        await tester.pump();
        expect(find.text('z-first'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        next.complete(page(['b-third'], offset: 2));
        await tester.pump();
        expect(service.items.map((trip) => trip.id), [
          'z-first',
          'a-second',
          'b-third',
        ]);
        SafetyService.blockedIds.add('owner');
        await tester.pump();
        expect(find.text('z-first'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        service.dispose();
      },
    );
  }

  testWidgets('preferences are optional and save failures remain recoverable', (
    tester,
  ) async {
    var fail = true;
    Map<String, dynamic>? saved;
    final service = RecommendationService(
      currentUid: () => 'viewer',
      call: (name, data) async {
        if (name == 'getRecommendedTripsV3') return page([]);
        if (fail) throw const RecommendationException('unavailable');
        saved = data;
        return {...data, 'version': 'v1'};
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => showDialog<void>(
                        context: context,
                        builder:
                            (_) => RecommendationPreferencesDialog(
                              service: service,
                            ),
                      ),
                  child: const Text('Edit'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Paris\nJapan');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not save preferences. Please try again.'),
      findsOneWidget,
    );
    fail = false;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved?['destinations'], ['Paris', 'Japan']);
    expect(find.text('Travel preferences'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    service.dispose();
  });
}
