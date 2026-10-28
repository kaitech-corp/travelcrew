import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/services/activity_vote.dart';

void main() {
  test('activity schedule accepts no dates or an ordered pair', () {
    final start = DateTime(2027, 4, 10, 10);
    final end = DateTime(2027, 4, 10, 11);
    expect(ActivityModel.scheduleError(null, null), isNull);
    expect(ActivityModel.scheduleError(start, end), isNull);
    expect(ActivityModel.scheduleError(start, null), isNotNull);
    expect(ActivityModel.scheduleError(null, end), isNotNull);
    expect(ActivityModel.scheduleError(end, start), isNotNull);
  });

  test('activity author survives storage round trips', () {
    final activity = ActivityModel(
      id: 'museum',
      tripId: 'trip',
      createdBy: 'alice',
      title: 'Museum',
      description: '',
      likesCount: 0,
    );
    expect(ActivityModel.fromMap(activity.toMap()).createdBy, 'alice');
    expect(ActivityModel.fromMap(activity.toMap()).contentRevision, 1);
    expect(
      ActivityModel.fromMap({'id': 'old', 'tripId': 'trip'}).contentRevision,
      0,
    );
    expect(activity.toMap()['isDeleted'], isFalse);
    expect(activity.toMap().containsKey('startDateTime'), isFalse);
    expect(activity.toMap().containsKey('endDateTime'), isFalse);
    expect(ActivityModel.fromMap(activity.toMap()).startDateTime, isNull);
    final deleted = ActivityModel.fromMap({
      ...activity.toMap(),
      'isDeleted': true,
    });
    expect(deleted.isDeleted, isTrue);
    deleted.isLegacy = true;
    expect(deleted.copyWith(title: 'Cached').isLegacy, isTrue);
    expect(deleted.copyWith(title: 'Cached').contentRevision, 1);
    expect(deleted.toMap().containsKey('isLegacy'), isFalse);
  });

  test(
    'repeated like and unlike requests keep exactly one vote per traveler',
    () {
      var vote = ActivityVoteState.apply(
        const [],
        0,
        userId: 'alice',
        shouldLike: true,
      );
      expect(vote.likedBy, ['alice']);
      expect(vote.likesCount, 1);
      expect(vote.changed, isTrue);

      vote = ActivityVoteState.apply(
        vote.likedBy,
        vote.likesCount,
        userId: 'alice',
        shouldLike: true,
      );
      expect(vote.likedBy, ['alice']);
      expect(vote.likesCount, 1);
      expect(vote.changed, isFalse);

      vote = ActivityVoteState.apply(
        vote.likedBy,
        vote.likesCount,
        userId: 'alice',
        shouldLike: false,
      );
      expect(vote.likedBy, isEmpty);
      expect(vote.likesCount, 0);
      expect(vote.changed, isTrue);

      vote = ActivityVoteState.apply(
        vote.likedBy,
        vote.likesCount,
        userId: 'alice',
        shouldLike: false,
      );
      expect(vote.likesCount, 0);
      expect(vote.changed, isFalse);
    },
  );

  test(
    'repairs stale counts and duplicate voter IDs from existing records',
    () {
      final vote = ActivityVoteState.apply(
        const ['alice', 'alice', 'bob'],
        9,
        userId: 'bob',
        shouldLike: true,
      );
      expect(vote.likedBy, ['alice', 'bob']);
      expect(vote.likesCount, 2);
      expect(vote.changed, isTrue);
      expect(
        () =>
            ActivityVoteState.apply(const [], 0, userId: '', shouldLike: true),
        throwsFormatException,
      );
    },
  );
}
