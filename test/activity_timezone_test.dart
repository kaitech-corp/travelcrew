import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/services/trip_calendar_service.dart';

void main() {
  test('activities keep venue clocks and distinct instants across DST', () {
    for (final timestamp in [
      '2027-04-10T10:00:00+09:00',
      '2027-04-10T01:00:00Z',
      '2027-11-07T01:30:00-07:00',
      '2027-11-07T01:30:00-08:00',
      '2027-03-14T02:30:00+09:00',
    ]) {
      final activity = ActivityModel.fromMap({
        'startDateTime': timestamp,
        'endDateTime': timestamp,
      });
      expect(
        activity.startDateTime!.hour,
        int.parse(timestamp.substring(11, 13)),
      );
      expect(
        activity.startDateTime!.day,
        int.parse(timestamp.substring(8, 10)),
      );
      expect(activity.startInstant, DateTime.parse(timestamp));
      expect(activity.endInstant, DateTime.parse(timestamp));
      final saved = activity.copyWith(title: 'Edited').toMap();
      expect(
        DateTime.parse(saved['startDateTime'] as String),
        DateTime.parse(timestamp),
      );
      expect(ActivityModel.fromMap(saved).timeOffsets, activity.timeOffsets);
      expect(
        ActivityModel.fromMap(saved).startDateTime,
        activity.startDateTime,
      );
    }
  });

  test('calendar uses actual elapsed time across a DST jump', () {
    final activity = ActivityModel.fromMap({
      'startDateTime': '2027-03-14T01:30:00-08:00',
      'endDateTime': '2027-03-14T03:30:00-07:00',
    });
    final event = TripCalendarService.eventForActivity(activity);
    expect(
      (event['endMilliseconds'] as int) - (event['startMilliseconds'] as int),
      3600000,
    );
  });

  test('legacy floating times and missing ends remain unchanged', () {
    final activity = ActivityModel.fromMap({
      'startDateTime': '2027-04-10T10:00:00',
    });
    expect(activity.startDateTime, DateTime(2027, 4, 10, 10));
    expect(activity.timeOffsets, isEmpty);
    expect(activity.toMap()['startDateTime'], '2027-04-10T10:00:00.000');
    expect(activity.toMap().containsKey('endDateTime'), isFalse);
  });
}
