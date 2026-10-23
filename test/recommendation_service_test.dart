import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/services/recommendation_service.dart';

Map<String, dynamic> page(
  List<String> ids, {
  String session = 'session',
  String? cursor,
  int offset = 0,
}) => {
  'sessionId': session,
  'nextCursor': cursor,
  'exhausted': cursor == null,
  'items': [
    for (var i = 0; i < ids.length; i++)
      {
        'id': ids[i],
        'destination': ids[i],
        'country': 'France',
        'createdBy': 'owner',
        'startDate': '2030-11-10',
        'endDate': '2030-11-14',
        'recommendation': {'sessionId': session, 'position': offset + i},
        'explanation': 'preferred_destination',
      },
  ],
};

void main() {
  test(
    'an explicit flush waits for an observation already being delivered',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      Map<String, dynamic>? event;
      final service = RecommendationService(
        currentUid: () => 'viewer',
        call: (name, data) async {
          if (name == 'getRecommendedTripsV3') return page(['trip']);
          event = Map<String, dynamic>.from(
            (data['events'] as List).single as Map,
          );
          return pending.future;
        },
      );
      addTearDown(service.dispose);
      await service.load();
      service.observe(service.items.single, 'impression');
      final first = service.flush();
      var finished = false;
      final second = service.flush().then((_) => finished = true);
      await Future<void>.delayed(Duration.zero);
      expect(finished, false);
      pending.complete({
        'results': [
          {'eventId': event!['eventId'], 'status': 'accepted'},
        ],
      });
      await Future.wait([first, second]);
      expect(finished, true);
    },
  );

  test(
    'retry after a failed refresh starts a new session even when the old pool was exhausted',
    () async {
      var calls = 0;
      final service = RecommendationService(
        currentUid: () => 'viewer',
        call: (_, data) async {
          expect(data.containsKey('cursor'), false);
          if (++calls == 2) throw const RecommendationException('unavailable');
          return page([calls == 1 ? 'old' : 'new'], session: 'session-$calls');
        },
      );
      addTearDown(service.dispose);
      await service.load();
      await service.load(refresh: true);
      expect(service.error, isNotNull);
      expect(service.items.single.id, 'old');
      await service.retry();
      expect(service.items.single.id, 'new');
      expect(service.error, isNull);
    },
  );

  test(
    'preserves backend relevance order, appends pages and removes duplicate IDs',
    () async {
      final calls = <Map<String, dynamic>>[];
      final service = RecommendationService(
        currentUid: () => 'viewer',
        call: (name, data) async {
          calls.add(data);
          return calls.length == 1
              ? page(['z', 'a'], cursor: 'next')
              : page(['a', 'b'], offset: 2);
        },
      );
      addTearDown(service.dispose);
      await service.load();
      expect(service.items.map((t) => t.id), ['z', 'a']);
      await service.load();
      expect(service.items.map((t) => t.id), ['z', 'a', 'b']);
      expect(calls.last['cursor'], 'next');
      expect(service.hasMore, false);
      expect(service.items.first.recommendation!.viewerUid, 'viewer');
      expect(service.items.first.toMap().containsKey('recommendation'), false);
    },
  );

  test(
    'load more keeps existing cards while pending or failed; retry uses the same cursor',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      var calls = 0;
      final service = RecommendationService(
        currentUid: () => 'viewer',
        call: (_, data) async {
          calls++;
          if (calls == 1) return page(['first'], cursor: 'next');
          expect(data['cursor'], 'next');
          if (calls == 2) return pending.future;
          return page(['second'], offset: 1);
        },
      );
      addTearDown(service.dispose);
      await service.load();
      final loading = service.load();
      expect(service.items.single.id, 'first');
      expect(service.loading, true);
      pending.completeError(const RecommendationException('unavailable'));
      await loading;
      expect(service.items.single.id, 'first');
      expect(service.error, isNotNull);
      await service.load();
      expect(service.items.map((t) => t.id), ['first', 'second']);
      expect(service.error, isNull);
    },
  );

  test(
    'refresh discards late responses and account changes clear cards and context',
    () async {
      var uid = 'alice';
      final first = Completer<Map<String, dynamic>>();
      var calls = 0;
      final service = RecommendationService(
        currentUid: () => uid,
        call: (_, _) async {
          calls++;
          if (calls == 1) return first.future;
          return page(['new'], session: 'new-session');
        },
      );
      addTearDown(service.dispose);
      final old = service.load();
      await service.load(refresh: true);
      first.complete(page(['old'], session: 'old-session'));
      await old;
      expect(service.items.single.id, 'new');
      uid = 'bob';
      service.bindAccount();
      expect(service.items, isEmpty);
      expect(service.sessionId, isNull);
      expect(service.loaded, false);
    },
  );

  test('an in-flight response cannot repopulate a different account', () async {
    var uid = 'alice';
    final pending = Completer<Map<String, dynamic>>();
    final service = RecommendationService(
      currentUid: () => uid,
      call: (_, _) => pending.future,
    );
    addTearDown(service.dispose);
    final loading = service.load();
    uid = 'bob';
    service.bindAccount();
    pending.complete(page(['private-to-alice']));
    await loading;
    expect(service.items, isEmpty);
    expect(service.loading, false);
  });

  test(
    'expired or changed sessions require refresh instead of silently mixing results',
    () async {
      var calls = 0;
      final service = RecommendationService(
        currentUid: () => 'viewer',
        call: (_, _) async {
          calls++;
          if (calls == 1) return page(['one'], cursor: 'next');
          if (calls == 2) {
            throw const RecommendationException('failed-precondition');
          }
          return page(['replacement'], session: 'replacement');
        },
      );
      addTearDown(service.dispose);
      await service.load();
      await service.load();
      expect(service.needsRefresh, true);
      expect(service.hasMore, false);
      await service.load();
      expect(calls, 2);
      await service.load(refresh: true);
      expect(service.items.single.id, 'replacement');
      expect(service.needsRefresh, false);
    },
  );

  test(
    'preferences from another device invalidate a pending continuation',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      var calls = 0;
      final service = RecommendationService(
        currentUid: () => 'viewer',
        call:
            (_, _) async =>
                ++calls == 1 ? page(['old'], cursor: 'next') : pending.future,
      );
      addTearDown(service.dispose);
      service.bindAccount();
      service.updatePreferences({
        'version': 'v1',
        'destinations': ['Paris'],
      });
      await service.load();
      final loading = service.load();
      service.updatePreferences({
        'version': 'v2',
        'destinations': ['Tokyo'],
      });
      pending.complete(page(['stale'], offset: 1));
      await loading;
      expect(service.items, isEmpty);
      expect(service.needsRefresh, true);
    },
  );

  test(
    'dismiss/undo and remote suppression preserve the ranking of remaining cards',
    () async {
      final service = RecommendationService(
        currentUid: () => 'viewer',
        call:
            (name, data) async =>
                name == 'getRecommendedTripsV3'
                    ? page(['one', 'two', 'three'])
                    : {},
      );
      addTearDown(service.dispose);
      await service.load();
      final first = service.items.first;
      await service.dismiss(first, true);
      expect(service.items.map((t) => t.id), ['two', 'three']);
      await service.dismiss(first, false);
      expect(service.items.map((t) => t.id), ['one', 'two', 'three']);
      service.updateDismissals({'two'});
      expect(service.items.map((t) => t.id), ['one', 'three']);
    },
  );

  testWidgets(
    'feedback retries preserve IDs, deduplicate impressions, and never cross accounts',
    (tester) async {
      var uid = 'alice';
      var attempts = 0;
      final sent = <List<Map>>[];
      final service = RecommendationService(
        currentUid: () => uid,
        call: (name, data) async {
          if (name == 'getRecommendedTripsV3') return page(['trip']);
          final events = (data['events'] as List).cast<Map>();
          sent.add(events);
          if (++attempts == 1) {
            throw const RecommendationException('unavailable');
          }
          return {
            'results': [
              for (final event in events)
                {'eventId': event['eventId'], 'status': 'accepted'},
            ],
          };
        },
      );
      await service.load();
      final trip = service.items.single;
      service.observe(trip, 'impression');
      service.observe(trip, 'impression');
      await tester.pump(const Duration(milliseconds: 500));
      expect(sent.single.length, 1);
      await tester.pump(const Duration(seconds: 2));
      expect(sent.length, 2);
      expect(sent[0][0]['eventId'], sent[1][0]['eventId']);
      service.observe(trip, 'open');
      uid = 'bob';
      service.bindAccount();
      service.observe(trip, 'open');
      await tester.pump(const Duration(seconds: 3));
      expect(sent.length, 2);
      service.dispose();
    },
  );

  test(
    'unattributed discovery cards do not manufacture recommendation events',
    () async {
      var calls = 0;
      final service = RecommendationService(
        currentUid: () => 'viewer',
        call: (_, _) async {
          calls++;
          return {};
        },
      );
      addTearDown(service.dispose);
      service.observe(
        TripDiscoveryModel.fromMap({'id': 'ordinary'}),
        'impression',
      );
      await service.flush();
      expect(calls, 0);
    },
  );
}
